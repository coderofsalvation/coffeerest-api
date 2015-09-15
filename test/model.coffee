module.exports = {
  doc:
    version: 1
    projectname: "Foo"
    logo: "https://github.com/coderofsalvation/coffeerest-api/raw/master/coffeerest.png"
    host: "http://mydomain.com"
    homepage: "http://mydomain.com/about"
    security: "Requests are authorized by adding a 'X-FOO-TOKEN: YOURTOKEN' http header"
    description: "Welcome to the Core API Documentation. The Core API is the heart of Project foo and should never be confused with the public api."
    request: 
      curl: "curl -X {{method}} -H 'Content-Type: application/json' -H 'X-FOO-TOKEN: YOURTOKEN' '{{url}}' --data '{{payload}}' "
      jquery: "jQuery.ajax({ url: '{{url}}', method: {{method}}, data: {{payload}} }).done(function(res){ alert(res); });"
      php: "$client->{{method}}('{{url}}', '{{payload}}');"
      coffeescript: "request.{{method}}\n\theaders: {'X-FOO-TOKEN': apikey }\n\turl: '{{url}}'\n\tjson: true\n\tbody: {{payload}}\n,(error,reponse,body) ->\n\tok = !error and response.statusCode == 200 and response.body"
      nodejs: "request.post({\n\theaders: {\n\t\t'X-FOO-TOKEN': apikey\n\t},\n\turl: '{{url}}',\n\tjson:true,\n\tbody: {{payload}}\n}, function(error, reponse, body) {\n\tvar ok;\n\treturn ok = !error && response.statusCode === 200 && response.body;\n});"
      php: "$json = '{{payload}}';\n$ch = curl_init( '{{url}}' );\ncurl_setopt($ch, CURLOPT_CUSTOMREQUEST, strtoupper('{{method}}') );\ncurl_setopt($ch, CURLOPT_POSTFIELDS, $json);\ncurl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);\ncurl_setopt($ch, CURLOPT_RETURNTRANSFER, true);\ncurl_setopt($ch, CURLOPT_HTTPHEADER, array(\n\t'Content-Type: application/json',\n\t'Content-Length: ' . strlen($json))\n);\n$result = curl_exec($ch);\n// HINT: use a REST client like https://github.com/bproctor/rest\n//       or install one using composer: http://getcomposer.org"
      python: "import requests, json\nurl = '{{url}}'\ndata = json.dumps( {{payload}} )\nr = requests.post( url, data, auth=('user', '*****'))\nprint r.json"

  db: 
    type: "redis"
    config:
      port: 6379
    acl:
      header_token: "X-FOO-TOKEN" 
      roles:
        default: { create: ["*"]     , read:   ["*"]     , update: ["*"]       , delete: ["*"] }
        user:    { create: ["user"]  , read:   ["user"]  , update: ["user"]    , delete: ["user"] }
        admin:   { create: ["admin"] , update: ["admin"] , delete: ["admin"] }

    resources:
      article:
        schema:
          taggable: true
          authenticate: true
          description: "this foo bar"
          payload:
            title: 
              type: "string"
              length: 255
              default: "title not set"
              required: true
              index: true
            content:
              type: "string"
              default: "Lorem ipsum"
              typehint: "content"
              required: true
            date:
              type: "string"
              typehint: "date"
              default: "Date.now"
                
        belongsTo:
          user:      { as: 'user', foreignKey: 'user_id' }
      user:
        schema:
          taggable: true
          authenticate: true
          description: "author"
          payload:
            email:   { type: "string",  required:true,  default: 'John Doe', pattern: "[@\.]" }
            apikey:  { type: "string",  required:true, default: "john@doe.com", index:true }
        hasMany:
          article: { as: 'articles', foreignKey: 'user_id' }

  resources:
    '/do/:action':
      get:
        description: 'do something where ":action" can be "process" or "cancel"'
        function: (req, res, next,lib, reply) ->
          lib[ req.params.action ]() if lib[ req.params.action ]?
          return reply 
  
    '/book/:id':
      get:
        description: "show book"
        function: (req, res, next,lib, reply) ->
          reply.data = [1,2,3]
          return reply 
      post:
        description: 'adds a book'
        notes: 'duplicates are not allowed'
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
      3: 'data error'
      4: 'access denied'
    payload:
      code:       { type: 'integer', default: 0 }
      message:    { type: 'string',  default: 'feeling groovy' }
      kind:       { type: 'string',  default: 'default', enum: ['book','default'] }
      data:       { type: 'object',  default: {} }
      errors:     { type: 'object',  default: [] }

}
