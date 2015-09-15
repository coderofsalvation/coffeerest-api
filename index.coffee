JSV = require('JSV').JSV.createEnvironment()
JSVD = require('json-schema-defaults')
glob = require('glob')
path = require('path')

module.exports = (server, models, lib) ->
  lib.coffeerest = @

  @.extensions = {}

  me = @

  for urlprefix,model of models
    ( (urlprefix,model) ->
      model.replyschema.properties = model.replyschema.payload # properties needs to be set in order to parse jsonschema
      # load extensions
      glob __dirname+"/../coffeerest-api-*", {}, (err,modules) ->
        for extension in modules
          console.log "loading extension: "+path.basename extension
          me.extensions[ path.basename(extension) ] = module = require './../'+path.basename extension 
          module server, model, lib, urlprefix
        # init api
        for url,methods of model.resources
          for method,resource of methods
            fullurl = urlprefix+url
            console.log "registering REST resource: "+fullurl+" ("+method+")"
            server[method] fullurl, ( (resource) ->
              (req,res,next) ->
                reply = JSVD model.replyschema
                process = true
                if resource.payload
                  err = JSV.validate req.body, { type: "object", properties: resource.payload }
                  if err.errors.length != 0
                    process = false
                    reply.code = 2
                    reply.errors = []
                    reply.errors.push { uri: e.uri.replace(/.*#/,''), message: e.message, attribute: e.attribute, details: e.details } for e in err.errors
                if process
                  reply      = resource.function(req,res,next,lib,reply)
                  reply.message  = model.replyschema.messages[ reply.code ] if reply.message == model.replyschema.payload.message.default
                res.send reply if reply
                next()
                return if not reply
            )(resource,urlprefix) 
    )(urlprefix,model)
  return (req,res,next) ->
    next()
