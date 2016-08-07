# source-map-support
require('source-map-support').install()

# hapi
Hapi = require "hapi"
Good = require "good"

# lodash
_ = require "lodash"

server = new Hapi.Server()
# 设置端口
server.connection
  host:"localhost"
  port:3000

# 路由
server.route
  method:"GET"
  path:"/"
  handler:(req,res)->
    res("hello world!!");

server.route
  method:"GET"
  path:"/{name}"
  handler:(req,res)->
    res "hello #{req.params.name}!!"

server.route
  method:"get"
  path:"/hello/{user*2}"
  handler:(req,res)->
    userParts = req.params.user.split("/")
    res "hello #{encodeURIComponent userParts[0]} #{encodeURIComponent userParts[1]}"

# register
server.register
  register:Good
  options:
    reporters:
      console: [
        module: 'good-squeeze'
        name: 'Squeeze'
        args: [
          response: '*'
          log: '*'
        ]
      module: 'good-console'
      'stdout'
      ]
  ,(err) ->
    if err
      # body...
      throw err

    server.start (err)->
      if err
        # body...
        throw err
      console.log "Server is running at:",server.info.uri
