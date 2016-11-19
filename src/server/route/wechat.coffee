express = require "express"
Promise = require "bluebird"
_ = require "underscore"
url = require 'url'
queryString = require 'queryString'
fs = require 'fs'
path = require "path"
request = require 'superagent'

WechatAPI = require "wechat-api"
OAuth = require "wechat-oauth"
config = require "../config/weixinConfig"

logger = require('tracer').colorConsole()

router = express.Router()

fileBasePath = "cache/openId/"
baseUrl = "http://192.168.29.102/Repository/"

client = new OAuth config.appid, config.appsecret, (openid, callback) ->
  # 传入一个根据openid获取对应的全局token的方法
  # 在getUser时会通过该方法来获取token
  fs.readFile "#{fileBasePath}#{openid}:access_token.txt", "utf8", (err, txt) ->
    if err
      return callback(err)
    callback null, JSON.parse(txt)
, (openid, token, callback) ->
  # 请将token存储到全局，跨进程、跨机器级别的全局，比如写到数据库、redis等
  # 这样才能在cluster模式及多机情况下使用，以下为写入到文件的示例
  # 持久化时请注意，每个openid都对应一个唯一的token!
  fs.writeFile "#{fileBasePath}#{openid}:access_token.txt"
    , JSON.stringify(token), callback

# 主页,主要是负责OAuth认证
router.get "/", (req, res) ->
  authUrl = client.getAuthorizeURL "http://zh5wd.free.natapp.cc/weixinmp/callback"
    , "", "snsapi_userinfo"
  console.log authUrl
  res.redirect authUrl

# callback 同步注册用户数
router.get "/callback", (req, res) ->
  logger.info "----weixin callback -----"
  code = req.query.code
  client.getAccessToken code, (err, result) ->
    if not _.isEmpty err
      logger.error err
    accessToken = result.data.access_token
    openid = result.data.openid
    client.getUser openid, (err, result) ->
      if not _.isEmpty err
        return res.send "认证错误，请重新授权。"
      userInfo = result
      postData =
        wxId: result.openid
        wxName: result.nickname
        sex: result.sex
        language: result.language
        city: result.city
        country: result.country
        province: result.province
        wxPhoto: result.headimgurl
        privilege: if _.isEmpty result.privilege then [''] else result.privilege

      # post fromdata
      formData = queryString.stringify postData
      reqUrl = "#{baseUrl}WxBus/register"
      request.post reqUrl
      .send formData
      .then (success) ->
        resObj =
          title: "首页"
          data: JSON.parse success.text
        res.render "wechat/index" ,resObj
      .catch (err) ->
        logger.error err

module.exports = router
