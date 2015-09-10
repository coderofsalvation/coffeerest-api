JSV = require('JSV').JSV.createEnvironment()
JSVD = require('json-schema-defaults')

module.exports = (server, model, lib) ->
  for url,methods of model.resources
    for method,resource of methods
      console.log "registering REST resource: "+url+" ("+method+")"
      server[method] url, ( (resource) ->
        (req,res,next) ->
          reply = JSVD model.replyschema
          if resource.payload
            err = JSV.validate req.body, { type: "object", properties: resource.payload }
            if err.errors.length == 0
              reply      = resource.function(req,res,next,lib,reply)
            else
              reply.code = 2
              reply.errors = []
              reply.errors.push { uri: e.uri.replace(/.*#/,''), message: e.message, attribute: e.attribute, details: e.details } for e in err.errors
            reply.message  = model.replyschema.messages[ reply.code ]
            res.send reply 
            next()
      )(resource) 
  return (req,res,next) ->
        next()
