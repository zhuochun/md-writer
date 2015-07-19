{$} = require "atom-space-pen-views"
os = require "os"
path = require "path"
yaml = require "js-yaml"

# ==================================================
# General Utils
#

getJSON = (uri, succeed, error) ->
  return error() if uri.length == 0
  $.getJSON(uri).done(succeed).fail(error)

regexpEscape = (str) ->
  str && str.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&')

dasherize = (str) ->
  str.trim().toLowerCase().replace(/[^-\w\s]|_/g, "").replace(/\s+/g,"-")

# ==================================================
# Template
#

dirTemplate = (directory, date) ->
  template(directory, getDate(date))

template = (text, data, matcher = /[<{]([\w-]+?)[>}]/g) ->
  text.replace matcher, (match, attr) ->
    if data[attr]? then data[attr] else match

# ==================================================
# Date and Time
#

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

# ==================================================
# Front Matters
#

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

# ==================================================
# Title and Slug
#

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

# ==================================================
# Image HTML Tag
#

IMG_TAG_REGEX = /// <img (.*?)\/?> ///i
IMG_TAG_ATTRIBUTE = /// ([a-z]+?)=('|")(.*?)\2 ///ig

# Detect it is a HTML image tag
isImageTag = (input) -> IMG_TAG_REGEX.test(input)
parseImageTag = (input) ->
  img = {}
  attributes = IMG_TAG_REGEX.exec(input)[1].match(IMG_TAG_ATTRIBUTE)
  pattern = /// #{IMG_TAG_ATTRIBUTE.source} ///i
  attributes.forEach (attr) ->
    elem = pattern.exec(attr)
    img[elem[1]] = elem[3] if elem
  return img

# ==================================================
# Image
#

IMG_REGEX  = ///
  !\[(.+?)\]               # ![text]
  \(                       # open (
  ([^\)\s]+)\s?            # a image path
  [\"\']?([^)]*?)[\"\']?   # any description
  \)                       # close )
  ///

isImage = (input) -> IMG_REGEX.test(input)
parseImage = (input) ->
  image = IMG_REGEX.exec(input)

  if image && image.length >= 3
    return alt: image[1], src: image[2], title: image[3]
  else
    return alt: input, src: "", title: ""

# ==================================================
# Inline link
#

INLINE_LINK_REGEX = ///
  \[(.+?)\]                # [text]
  \(                       # open (
  ([^\)\s]+)\s?            # a url
  [\"\']?([^)]*?)[\"\']?   # any title
  \)                       # close )
  ///

isInlineLink = (input) -> INLINE_LINK_REGEX.test(input) and !isImage(input)
parseInlineLink = (input) ->
  link = INLINE_LINK_REGEX.exec(input)

  if link && link.length >= 2
    text: link[1], url: link[2], title: link[3] || ""
  else
    text: input, url: "", title: ""

# ==================================================
# Reference link
#

REFERENCE_LINK_REGEX_OF = (id, opts = {}) ->
  id = regexpEscape(id) unless opts.noEscape
  ///
  \[(#{id})\]\s?           # [text]
  \[(.*)\]                 # [id] or []
  ///

REFERENCE_LINK_REGEX = REFERENCE_LINK_REGEX_OF(".+?", noEscape: true)

REFERENCE_DEF_REGEX_OF = (id, opts = {}) ->
  id = regexpEscape(id) unless opts.noEscape
  ///
  ^ \ *                    # start of line with any spaces
  \[(#{id})\]:\ +          # [id]: followed by spaces
  ([^\s]*?)                # link
  (?:\ +"?(.+?)"?)?        # any "link title"
  $ ///m

REFERENCE_DEF_REGEX = REFERENCE_DEF_REGEX_OF(".+?", noEscape: true)

isReferenceLink = (input) -> REFERENCE_LINK_REGEX.test(input)
parseReferenceLink = (input, content) ->
  refn = REFERENCE_LINK_REGEX.exec(input)
  id = refn[2] || refn[1]
  link = REFERENCE_DEF_REGEX_OF(id).exec(content)

  if link && link.length >= 3
    id: id, text: refn[1], url: link[2], title: link[3] || ""
  else
    throw new Error("Cannot find reference tag for specified link")

isReferenceDefinition = (input) -> REFERENCE_DEF_REGEX.test(input)

# ==================================================
# Table
#

TABLE_LINE_SEPARATOR_REGEX = ///
  ^ \|?             # starts with an optional |
  (\s*:?-+:?\s*\|)+ # one or more table cell
  (\s*:?-+:?\s*)    # last table cell
  \|? $             # ends with an optional |
  ///

isTableSeparator = (line) ->
  TABLE_LINE_SEPARATOR_REGEX.test(line)

# ==================================================
# URL
#

URL_REGEX = ///
  ^(?:\w+:)?\/\/
  ([^\s\.]+\.\S{2}|localhost[\:?\d]*)
  \S*$
  ///i

isUrl = (url) -> URL_REGEX.test(url)

# ==================================================
# Atom TextEditor
#

# Return scopeSelector if there is an exact match,
# else return any scope descriptor contains scopeSelector
getScopeDescriptor = (cursor, scopeSelector) ->
  scopes = cursor.getScopeDescriptor()
    .getScopesArray()
    .filter((scope) -> scope.indexOf(scopeSelector) >= 0)

  if scopes.indexOf(scopeSelector) >= 0
    return scopeSelector
  else if scopes.length > 0
    return scopes[0]

# Atom has a bug returning the correct buffer range when cursor is
# at the end of scope, refer https://github.com/atom/atom/issues/7961
#
# This provides a temporary fix for the bug.
getBufferRangeForScope = (editor, cursor, scopeSelector) ->
  pos = cursor.getBufferPosition()

  range = editor.displayBuffer.bufferRangeForScopeAtPosition(scopeSelector, pos)
  return range if range

  # HACK if range is undefined, move the cursor position one char forward, and
  # try to get the buffer range for scope again
  pos = [pos.row, Math.max(0, pos.column - 1)]
  editor.displayBuffer.bufferRangeForScopeAtPosition(scopeSelector, pos)

# Get the text buffer range if selection is not empty, or get the
# buffer range if it is inside a scope selector, or the current word.
#
# selection is optional, when not provided, use the last selection
getTextBufferRange = (editor, scopeSelector, selection) ->
  selection ?= editor.getLastSelection()
  cursor = selection.cursor

  if selection.getText()
    selection.getBufferRange()
  else if (scope = getScopeDescriptor(cursor, scopeSelector))
    getBufferRangeForScope(editor, cursor, scope)
  else
    wordRegex = cursor.wordRegExp(includeNonWordCharacters: false)
    cursor.getCurrentWordBufferRange(wordRegex: wordRegex)

# ==================================================
# Exports
#

module.exports =
  getJSON: getJSON
  regexpEscape: regexpEscape
  dasherize: dasherize

  dirTemplate: dirTemplate
  template: template

  getDate: getDate
  parseDateStr: parseDateStr
  getDateStr: getDateStr
  getTimeStr: getTimeStr

  hasFrontMatter: hasFrontMatter
  getFrontMatter: getFrontMatter
  getFrontMatterText: getFrontMatterText
  updateFrontMatter: updateFrontMatter

  getTitleSlug: getTitleSlug

  isImageTag: isImageTag
  parseImageTag: parseImageTag
  isImage: isImage
  parseImage: parseImage

  isInlineLink: isInlineLink
  parseInlineLink: parseInlineLink
  isReferenceLink: isReferenceLink
  parseReferenceLink: parseReferenceLink
  isReferenceDefinition: isReferenceDefinition

  isUrl: isUrl
  isTableSeparator: isTableSeparator

  getTextBufferRange: getTextBufferRange
