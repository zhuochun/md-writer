path = require "path"

getPostsDir = (directory) ->
  date = getDate()
  tokens = directory.match(/{(.*?)}/g)
  tokens?.forEach (token) ->
    directory = directory.replace(token, date[token[1...-1]])
  return directory

getDateStr = ->
  date = getDate()
  return "#{date.year}-#{date.month}-#{date.day}"

getTimeStr = ->
  date = getDate()
  return "#{date.hour}:#{date.minute}"

getDate = ->
  date = new Date()
  year: "" + date.getFullYear()
  month: ("0" + (date.getMonth() + 1)).slice(-2)
  day: ("0" + date.getDate()).slice(-2)
  hour: "" + date.getHours()
  minute: "" + date.getMinutes()
  seconds: "" + date.getSeconds()

module.exports =
  getPostsDir: getPostsDir
  getDate: getDate
  getDateStr: getDateStr
  getTimeStr: getTimeStr
