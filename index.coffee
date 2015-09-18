#JSV = require('JSV').JSV.createEnvironment()
JSV = require('ajv')()
JSVD = require('json-schema-defaults')
glob = require('glob')
path = require('path')
validate_schema = require('./validate.coffee')
fs   = require 'fs'
extend = require 'extend'

module.exports = (server, models, lib) ->
  lib.extensions = {}
  me = @

  for urlprefix,model of models
    ( (urlprefix,model) ->
      model.replyschema.properties = model.replyschema.payload # properties needs to be set in order to parse jsonschema
      
      glob __dirname+"/../coffeerest-api-*", {}, (err,modules) ->
        modulenames = []
        modulenames.push path.basename extension for extension in modules
        # validate extension ( model )
        for modulename in modulenames
          extmodel = __dirname+'/../'+modulename+'/validate.coffee'
          ( console.error("cannot locate "+extmodel) && process.exit 1) if not fs.existsSync extmodel
          extend true, validate_schema, require(extmodel)
        if not JSV.validate validate_schema, model
           console.error "## Error in model: "+JSON.stringify( JSV.errors, null, 2)+"\n\n## Your Model JSON:\n\n"
           console.dir model
        # load extensions
        for modulename in modulenames
          console.log "loading extension: "+modulename
          module = require './../'+modulename
          lib.extensions[ modulename ] = module server, model, lib, urlprefix
        # init api
        for url,methods of model.resources
          for method,resource of methods
            fullurl = urlprefix+url
            console.log "registering REST resource: "+fullurl+" ("+method+")"
            server[method] fullurl, ( (resource) ->
              (req,res,next) ->
                reply = JSVD model.replyschema
                process = true
                if resource.payload?
                  payloadschema = { type: "object", properties: resource.payload }
                  payloadschema.required = resource.required if resource.required?
                  if not JSV.validate payloadschema, req.body
                    process = false
                    reply.code = 2
                    reply.errors = JSV.errors 
                if process
                  reply      = resource.function(req,res,next,lib,reply)
                  reply.message  = model.replyschema.messages[ reply.code ] if reply and reply.message == model.replyschema.payload.message.default
                res.send reply if reply
                next()
                return if not reply
            )(resource,urlprefix) 
    )(urlprefix,model)

  return (req,res,next) ->
    next()
