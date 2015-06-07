{$} = require "atom-space-pen-views"
os = require "os"
path = require "path"
yaml = require "js-yaml"

getJSON = (uri, succeed, error) ->
  return error() if uri.length == 0
  $.getJSON(uri).done(succeed).fail(error)

DATE_REGEX = /// ^
  (\d{4})[-\/]     # year
  (\d{1,2})[-\/]   # month
  (\d{1,2})        # day
  $ ///g

parseDateStr = (str) ->
  date = new Date()
  matches = DATE_REGEX.exec(str)
  if matches
    date.setYear(parseInt(matches[1], 10))
    date.setMonth(parseInt(matches[2], 10) - 1)
    date.setDate(parseInt(matches[3], 10))
  return getDate(date)

getDateStr = (date)->
  date = getDate(date)
  return "#{date.year}-#{date.month}-#{date.day}"

getTimeStr = (date) ->
  date = getDate(date)
  return "#{date.hour}:#{date.minute}"

getDate = (date = new Date()) ->
  year: "" + date.getFullYear()
  i_month: "" + (date.getMonth() + 1)
  month: ("0" + (date.getMonth() + 1)).slice(-2)
  i_day: "" + date.getDate()
  day: ("0" + date.getDate()).slice(-2)
  hour: ("0" + date.getHours()).slice(-2)
  minute: ("0" + date.getMinutes()).slice(-2)
  seconds: ("0" + date.getSeconds()).slice(-2)

FRONT_MATTER_REGEX = ///
  ^(?:---\s*)?  # match open --- (if any)
  ([^:]+:       # match at least 1 open key
  [\s\S]*?)\s*  # match the rest
  ---\s*$       # match ending ---
  ///m

hasFrontMatter = (content) ->
  !!content && FRONT_MATTER_REGEX.test(content)

getFrontMatter = (content) ->
  matches = content.match(FRONT_MATTER_REGEX)
  return {} unless matches
  yamlText = matches[1].trim()
  return yaml.safeLoad(yamlText) || {}

getFrontMatterText = (obj, noLeadingFence) ->
  yamlText = yaml.safeDump(obj)
  if noLeadingFence
    return ["#{yamlText}---", ""].join(os.EOL)
  else
    return ["---", "#{yamlText}---", ""].join(os.EOL)

updateFrontMatter = (editor, frontMatter) ->
  editor.buffer.scan FRONT_MATTER_REGEX, (match) ->
    noLeadingFence = !match.matchText.startsWith("---")
    match.replace getFrontMatterText(frontMatter, noLeadingFence)

IMG_TAG_REGEX = /// <img (.*?)\/?> ///i
IMG_TAG_ATTRIBUTE = /// ([a-z]+?) = ('|")(.*?)\2 ///ig
IMG_REGEX  = ///
  !\[(.+?)\]               # ![text]
  \(                       # open (
  ([^\)\s]+)\s?            # a image path
  [\"\']?([^)]*?)[\"\']?   # any description
  \)                       # close )
  ///

isImageTag = (input) -> IMG_TAG_REGEX.test(input)
parseImageTag = (input) ->
  img = {}
  attributes = IMG_TAG_REGEX.exec(input)[1].match(IMG_TAG_ATTRIBUTE)
  pattern = /// #{IMG_TAG_ATTRIBUTE.source} ///i
  attributes.forEach (attr) ->
    elem = pattern.exec(attr)
    img[elem[1]] = elem[3] if elem
  return img

isImage = (input) -> IMG_REGEX.test(input)
parseImage = (input) ->
  image = IMG_REGEX.exec(input)
  return alt: image[1], src: image[2], title: image[3]

INLINE_LINK_REGEX = ///
  \[(.+?)\]                # [text]
  \(                       # open (
  ([^\)\s]+)\s?            # a url
  [\"\']?([^)]*?)[\"\']?   # any title
  \)                       # close )
  ///
REFERENCE_LINK_REGEX = ///
  \[(.+?)\]\s?             # [text]
  \[(.*)\]                 # [id] or []
  ///

reference_def_regex = (id, opts = {}) ->
  id = regexpEscape(id) unless opts.noEscape
  /// ^ \ * \[#{id}\]: \ + ([^\s]*?) (?:\ +"?(.+?)"?)? $ ///m

isInlineLink = (input) -> INLINE_LINK_REGEX.test(input) and !isImage(input)
parseInlineLink = (input) ->
  link = INLINE_LINK_REGEX.exec(input)

  if link && link.length >= 2
    text: link[1], url: link[2], title: link[3] || ""
  else
    throw new Error("Invalid or incomplete inline link")

isReferenceLink = (input) -> REFERENCE_LINK_REGEX.test(input)
isReferenceDefinition = (input) ->
  reference_def_regex(".+?", noEscape: true).test(input)
parseReferenceLink = (input, content) ->
  refn = REFERENCE_LINK_REGEX.exec(input)
  id = refn[2] || refn[1]
  link = reference_def_regex(id).exec(content)

  if link && link.length >= 2
    id: id, text: refn[1], url: link[1], title: link[2] || ""
  else
    throw new Error("Cannot find reference tag for specified link")

URL_REGEX = ///
  ^(?:\w+:)?\/\/
  ([^\s\.]+\.\S{2}|localhost[\:?\d]*)
  \S*$
  ///i

isUrl = (url) -> URL_REGEX.test(url)

TABLE_LINE_SEPARATOR_REGEX = ///
  ^ \|?             # starts with an optional |
  (\s*:?-+:?\s*\|)+ # one or more table cell
  (\s*:?-+:?\s*)    # last table cell
  \|? $             # ends with an optional |
  ///

isTableSeparator = (line) ->
  TABLE_LINE_SEPARATOR_REGEX.test(line)

regexpEscape = (str) -> str and str.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&')

dasherize = (str) ->
  str.trim().toLowerCase().replace(/[^-\w\s]|_/g, "").replace(/\s+/g,"-")

SLUG_REGEX = ///
  ^
  (\d{1,4}-\d{1,2}-\d{1,4}-)
  (.+)
  $
  ///

getTitleSlug = (str) ->
  str = path.basename(str, path.extname(str))

  if matches = SLUG_REGEX.exec(str)
    matches[2]
  else
    str

dirTemplate = (directory, date) ->
  template(directory, getDate(date))

template = (text, data, matcher = /[<{]([\w-]+?)[>}]/g) ->
  text.replace matcher, (match, attr) ->
    if data[attr]? then data[attr] else match

hasCursorScope = (editor, scope) ->
  editor.getLastCursor().getScopeDescriptor()
    .getScopesArray().indexOf(scope) != -1

getCursorScopeRange = (editor, wordRegex) ->
  if wordRegex
    editor.getLastCursor().getCurrentWordBufferRange(wordRegex: wordRegex)
  else
    editor.getLastCursor().getCurrentWordBufferRange()

getSelectedTextBufferRange = (editor, scope) ->
  if editor.getSelectedText()
    editor.getSelectedBufferRange()
  else if hasCursorScope(editor, scope)
    editor.bufferRangeForScopeAtCursor(scope)
  else
    getCursorScopeRange(editor)

module.exports =
  getJSON: getJSON
  getDate: getDate
  parseDateStr: parseDateStr
  getDateStr: getDateStr
  getTimeStr: getTimeStr
  hasFrontMatter: hasFrontMatter
  getFrontMatter: getFrontMatter
  getFrontMatterText: getFrontMatterText
  updateFrontMatter: updateFrontMatter
  frontMatterRegex: FRONT_MATTER_REGEX
  isImageTag: isImageTag
  parseImageTag: parseImageTag
  isImage: isImage
  parseImage: parseImage
  isInlineLink: isInlineLink
  parseInlineLink: parseInlineLink
  isReferenceLink: isReferenceLink
  isReferenceDefinition: isReferenceDefinition
  parseReferenceLink: parseReferenceLink
  isUrl: isUrl
  isTableSeparator: isTableSeparator
  regexpEscape: regexpEscape
  dasherize: dasherize
  getTitleSlug: getTitleSlug
  dirTemplate: dirTemplate
  template: template
  hasCursorScope: hasCursorScope
  getCursorScopeRange: getCursorScopeRange
  getSelectedTextBufferRange: getSelectedTextBufferRange
