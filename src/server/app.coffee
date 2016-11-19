# source-map-support
require("source-map-support").install()

express = require "express"
useragent = require "express-useragent"
errorhandler = require 'errorhandler'
fs = require 'fs'
path = require 'path'
WechatAPI = require 'wechat-api'
webot = require 'weixin-robot'
logger = require "morgan"

# customer module

# express
app = express()
router = express.Router()

# development logger
NODE_ENV = process.env.NODE_ENV
isDev = NODE_ENV is "development"
if isDev
  app.use logger "dev"
  app.use errorhandler()

# routes
# frontend pages
app.use '/', require './route/index'
# wechat todo
app.use '/weixinmp', require './route/wechat'

# 静态文件
app.use "/static", express.static "static"
# 模板
app.set "view engine", "pug"
# useragent
app.use useragent.express()

server = app.listen 3000, () ->
  host = server.address().address
  port = server.address().port

  console.log "Nodejs Example app listening at http://:#{host}#{port}"
