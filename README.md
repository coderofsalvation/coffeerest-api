coffeerest-api
==============
Unfancy rest apis

<img alt="" src="https://github.com/coderofsalvation/coffeerest-api/raw/master/coffeerest.png" width="20%" />

## Ouch! Is it that simple?

Your `model.coffee` specification 

    module.exports = 
      name: "project foo"
      resources:
        '/book/:category':
          post:
            description: 'adds a book'
            payload:
              foo: { type: "string", minLength: 5, required: true }
            function: (req, res, next,lib, reply) ->
              category = req.params.category
              reply.data = [1,2,3]
              return reply 
              
      replyschema:
        type: 'object'
        required: ['code','message','kind','data']
        messages:
          0: 'feeling groovy'
          1: 'unknown error'
          2: 'your payload is invalid (is object? content-type is application/json?)'
        properties:
          code:       { type: 'integer', default: 0 }
          message:    { type: 'string',  default: 'feeling groovy' }
          kind:       { type: 'string',  default: 'default', enum: ['book','default'] }
          data:       { type: 'object' }
          errors:     { type: 'object' }
## Extensions 

* [coffeerest-api-doc](https://www.npmjs.com/package/coffeerest-api-doc): automatic html and markdown REST-documentation
* coffeerest-api-clients:  automatic REST clients) *TODO*
* coffeerest-api-db: ORM to connect any database (using waterline) which automatically generates collection-to-restapi-endpoints 

## Example servercode 

    restify    = require('restify')        # here we use restify but express should be fine too
    coffeerest = require('coffeerest-api')
    model      = require('./model.coffee')
    lib        = require('./lib.coffee')

    server = restify.createServer { name:model.name }
    server.use restify.queryParser()
    server.use restify.bodyParser()
    server.use coffeerest server, { "/v1":model }, lib  # multiversion support
    server.listen process.env.PORT || 8080, () ->
      console.log '%s listening at %s', server.name, server.url

Done!

    $ coffee server.coffee
    registering REST resource: /v1/books/:action (post)
    registering REST resource: /v1/book (post)
    project foo listening at http://0.0.0.0:4455

    $ curl -H 'Content-Type: application/json' http://localhost:$PORT/v1/book -X POST --data '{"foo":"foobar"}'
    {"code":0,"message":"feeling groovy","kind":"default","data":[1,2,3],"errors":{}}

    $ curl -H 'Content-Type: application/json' http://localhost:$PORT/v1/book -X POST --data '{"foo":"foo"}'
    {"code":2,"message":"your payload is invalid (is object? content-type is application/json?)","kind":"default","data":{},"errors":[{"uri":"/foo","message":"String is less than the required minimum length","attribute":"minLength","details":5}]}
    
    $ curl -H 'Content-Type: application/json' http://localhost:$PORT/v1/book -X POST --data '{}'
    "code":2,"message":"your payload is invalid (is object? content-type is application/json?)","kind":"default","data":{},"errors":[{"uri":"/foo","message":"Property is required","attribute":"required","details":true}]}

    

