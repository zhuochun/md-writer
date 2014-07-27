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
  hour: ("0" + date.getHours()).slice(-2)
  minute: ("0" + date.getMinutes()).slice(-2)
  seconds: ("0" + date.getSeconds()).slice(-2)

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

IMG_REGEX  = /!\[(.+?)\]\(([^\)\s]+)\s?[\"\']?([^)]*?)[\"\']?\)/
INLINE_LINK_REGEX = /\[(.+?)\]\(([^\)\s]+)\s?[\"\']?([^)]*?)[\"\']?\)/
REFERENCE_LINK_REGEX = /\[(.+?)\]\s?\[(.*)\]/

reference_def_regex = (id, opts = {}) ->
  id = regexpEscape(id) unless opts.noEscape
  /// ^ \[#{id}\]: \ + ([^\s]*?) (?:\ +"?(.+?)"?)? $ ///m

isImage = (input) -> IMG_REGEX.test(input)
parseImage = (input) ->
  image = IMG_REGEX.exec(input)
  return text: image[1], url: image[2], title: image[3]

isInlineLink = (input) -> INLINE_LINK_REGEX.test(input) and !isImage(input)
parseInlineLink = (input) ->
  link = INLINE_LINK_REGEX.exec(input)
  return text: link[1], url: link[2], title: link[3]

isReferenceLink = (input) -> REFERENCE_LINK_REGEX.test(input)
isReferenceDefinition = (input) ->
  reference_def_regex(".+?", noEscape: true).test(input)
parseReferenceLink = (input, content) ->
  refn = REFERENCE_LINK_REGEX.exec(input)
  id = refn[2] || refn[1]
  link = reference_def_regex(id).exec(content)
  return id: id, text: refn[1], url: link[1], title: link[2] || ""

regexpEscape = (s) -> s and s.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&')

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
  isInlineLink: isInlineLink
  parseInlineLink: parseInlineLink
  isReferenceLink: isReferenceLink
  isReferenceDefinition: isReferenceDefinition
  parseReferenceLink: parseReferenceLink
  regexpEscape: regexpEscape
