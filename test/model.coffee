module.exports = {
  name: "project foo"
  resources:
    '/books/:action':
      get:
        description: 'do something with a book'
        function: (req, res, next,lib, reply) ->
          lib[ req.params.action ]() if lib[ req.params.action ]?
          return reply 
  
    '/book':
      post:
        description: 'adds a book'
        payload:
          foo: { type: "string", minLength: 5, required: true, default: "bar" }
        function: (req, res, next,lib, reply) ->
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

}
