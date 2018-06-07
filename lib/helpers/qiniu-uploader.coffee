utility = require "utility"
qiniu = require "qiniu"

config = require "../config"
utils = require "../utils"


complete = (respErr, respBody, respInfo, callback) ->
  if respErr
    callback({success: false, message: respErr.message})
  else if respInfo.statusCode == 200
    domain = config.get("qiniuDomain")
    domain = if domain.endsWith("/") then domain else domain + "/"
    src = "#{domain}#{respBody.key}"
    separtor = config.get("qiniuSepartor")
    style = config.get("qiniuStyle")
    src = if style then "#{src}#{separtor}#{style}" else src
    param = config.get("qiniuParam")
    src = if param then "#{src}?#{param}" else src
    callback({success: true, src: src})
  else
    callback({success: false, message: respBody.error})


getToken = (accessKey, secretKey, bucket) ->
  mac = new qiniu.auth.digest.Mac(accessKey, secretKey)
  putPolicy = new qiniu.rs.PutPolicy({
     scope : bucket,
     expires : 60
  });
  return putPolicy.uploadToken(mac)


getKey = (title, extname, dateTime) ->
  YYYYMMDD = "#{dateTime['year']}#{dateTime['month']}#{dateTime['day']}"
  HHmmss= "#{dateTime['hour']}#{dateTime['minute']}#{dateTime['second']}"
  rs = utility.randomString("3", utility.md5("#{title}#{HHmmss}"))
  keyPrefix = config.get("qiniuKeyPrefix") || ""
  key = "#{keyPrefix}/#{YYYYMMDD}/#{HHmmss}#{rs}#{extname}"
  key = utils.normalizeFilePath(key)
  return if key.startsWith("/") then key.substring(1) else key


upload = (body, title, extname, dateTime, callback) ->
  accessKey = config.get("qiniuAccessKey")
  secretKey = config.get("qiniuSecretKey")
  bucket = config.get("qiniuBucket")
  domain = config.get("qiniuDomain")

  if !accessKey && !secretKey && !bucket && !domain
    return callback({
      success: false,
      message: "Qiniu upload config is empty !"
    })

  uToken = getToken(accessKey, secretKey, bucket)
  key = getKey(title, extname, dateTime)

  formUploader = new qiniu.form_up.FormUploader(
    new qiniu.conf.Config()
  )
  putExtra = new qiniu.form_up.PutExtra()

  if typeof body is 'string'
    formUploader.putFile uToken, key , body, putExtra,
      (respErr, respBody, respInfo) =>
        complete(respErr, respBody, respInfo, callback)
  else
    formUploader.put uToken, key , body, putExtra,
      (respErr, respBody, respInfo) =>
        complete(respErr, respBody, respInfo, callback)


module.exports = upload: upload
