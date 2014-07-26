os = require "os"
path = require "path"
yaml = require "js-yaml"
request = require "request"

getJSON = (uri, succeed, error) ->
  data = uri: uri, json: true, encoding: 'utf-8', gzip: true
  request data, (err, res, body) ->
    if !err and res.statusCode == 200
      succeed(body)
    else
      error(err)

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

FRONT_MATTER_REGEX = /^---\s*\r?\n([^.]*?)---\s*\r?\n/m

hasFrontMatter = (content) ->
  FRONT_MATTER_REGEX.test(content)

getFrontMatter = (content) ->
  yamlText = content.match(FRONT_MATTER_REGEX)[1].trim()
  return yaml.safeLoad(yamlText) || {}

replaceFrontMatter = (content, newFrontMatter) ->
  yamlText = yaml.safeDump(newFrontMatter)
  newFrontMatter = ["---", "#{yamlText}---", "", ""].join(os.EOL)
  return content.replace(FRONT_MATTER_REGEX, newFrontMatter)

IMG_REGEX  = /!\[(.*?)\]\(([^\)\s]+)\s?[\"\']?([^)]*?)[\"\']?\)/
LINK_REGEX = /\[(.*?)\]\(([^\)\s]+)\s?[\"\']?([^)]*?)[\"\']?\)/

isImage = (text) -> IMG_REGEX.test(text)
parseImage = (text) ->
  image = text.match(IMG_REGEX)
  return text: link[1], url: link[2], title: link[3]

isLink = (text) -> LINK_REGEX.test(text) and !isImage(text)
parseLink = (text) ->
  link = text.match(LINK_REGEX)
  return text: link[1], url: link[2], title: link[3]

module.exports =
  getJSON: getJSON
  getPostsDir: getPostsDir
  getDate: getDate
  getDateStr: getDateStr
  getTimeStr: getTimeStr
  hasFrontMatter: hasFrontMatter
  getFrontMatter: getFrontMatter
  replaceFrontMatter: replaceFrontMatter
  isImage: isImage
  parseImage: parseImage
  isLink: isLink
  parseLink: parseLink
