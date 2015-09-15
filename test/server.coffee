restify    = require('restify')
coffeerest = require('coffeerest-api')
acl        = require('coffeerest-api-db-user-acl')
model      = require('./model.coffee')
lib        = require('./lib.coffee')

server = restify.createServer { name:model.name }
server.use restify.queryParser()
server.use restify.bodyParser()
server.use acl server, model, lib, "/v1"
server.use coffeerest server, { "/v1":model }, lib # multiversion support
server.listen process.env.PORT, () ->
 console.log '%s listening at %s', server.name, server.url

