{$} = require "atom-space-pen-views"
os = require "os"
path = require "path"
wcswidth = require "wcwidth"

# ==================================================
# General Utils
#

getJSON = (uri, succeed, error) ->
  return error() if uri.length == 0
  $.getJSON(uri).done(succeed).fail(error)

escapeRegExp = (str) ->
  return "" unless str
  str.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&')

# https://github.com/epeli/underscore.string/blob/master/cleanDiacritics.js
cleanDiacritics = (str) ->
  return "" unless str

  from = "ąàáäâãåæăćčĉęèéëêĝĥìíïîĵłľńňòóöőôõðøśșšŝťțŭùúüűûñÿýçżźž"
  to = "aaaaaaaaaccceeeeeghiiiijllnnoooooooossssttuuuuuunyyczzz"

  from += from.toUpperCase()
  to += to.toUpperCase()

  to = to.split("")

  # for tokens requireing multitoken output
  from += "ß"
  to.push('ss')

  str.replace /.{1}/g, (c) ->
    index = from.indexOf(c)
    if index == -1 then c else to[index]

SLUGIZE_CONTROL_REGEX = /[\u0000-\u001f]/g
SLUGIZE_SPECIAL_REGEX = /[\s~`!@#\$%\^&\*\(\)\-_\+=\[\]\{\}\|\\;:"'<>,\.\?\/]+/g

# https://github.com/hexojs/hexo-util/blob/master/lib/slugize.js
slugize = (str, separator = '-') ->
  return "" unless str

  escapedSep = escapeRegExp(separator)

  cleanDiacritics(str).trim().toLowerCase()
    # Remove control characters
    .replace(SLUGIZE_CONTROL_REGEX, '')
    # Replace special characters
    .replace(SLUGIZE_SPECIAL_REGEX, separator)
    # Remove continous separators
    .replace(new RegExp(escapedSep + '{2,}', 'g'), separator)
    # Remove prefixing and trailing separtors
    .replace(new RegExp('^' + escapedSep + '+|' + escapedSep + '+$', 'g'), '')

getPackagePath = (segments...) ->
  segments.unshift(atom.packages.resolvePackagePath("markdown-writer"))
  path.join.apply(null, segments)

getProjectPath = ->
  paths = atom.project.getPaths()
  if paths && paths.length > 0
    paths[0]
  else # Give the user a path if there's no project paths.
    atom.config.get("core.projectHome")

getSitePath = (configPath) ->
  getAbsolutePath(configPath || getProjectPath())

# https://github.com/sindresorhus/os-homedir/blob/master/index.js
getHomedir = ->
  return os.homedir() if typeof(os.homedir) == "function"

  env = process.env
  home = env.HOME
  user = env.LOGNAME || env.USER || env.LNAME || env.USERNAME

  if process.platform == "win32"
    env.USERPROFILE || env.HOMEDRIVE + env.HOMEPATH || home
  else if process.platform == "darwin"
    home || ("/Users/" + user if user)
  else if process.platform == "linux"
    home || ("/root" if process.getuid() == 0) || ("/home/" + user if user)
  else
    home

# Basically expand ~/ to home directory
# https://github.com/sindresorhus/untildify/blob/master/index.js
getAbsolutePath = (path) ->
  home = getHomedir()
  if home then path.replace(/^~($|\/|\\)/, home + '$1') else path

# ==================================================
# General View Helpers
#

setTabIndex = (elems) ->
  elem[0].tabIndex = i + 1 for elem, i in elems

# ==================================================
# Template
#

TEMPLATE_REGEX = ///
  [\<\{]        # start with < or {
  ([\w\.\-]+?)  # any reasonable words, - or .
  [\>\}]        # end with > or }
  ///g

UNTEMPLATE_REGEX = ///
  (?:\<|\\\{)   # start with < or \{
  ([\w\.\-]+?)  # any reasonable words, - or .
  (?:\>|\\\})   # end with > or \}
  ///g

template = (text, data, matcher = TEMPLATE_REGEX) ->
  text.replace matcher, (match, attr) ->
    if data[attr]? then data[attr] else match

# Return a function that reverse parse the template, e.g.
#
# Pass `untemplate("{year}-{month}")` returns a function `fn`, that `fn("2015-11") # => { _: "2015-11", year: 2015, month: 11 }`
#
untemplate = (text, matcher = UNTEMPLATE_REGEX) ->
  keys = []

  text = escapeRegExp(text).replace matcher, (match, attr) ->
    keys.push(attr)
    if ["year"].indexOf(attr) != -1 then "(\\d{4})"
    else if ["month", "day", "hour", "minute", "second"].indexOf(attr) != -1 then "(\\d{2})"
    else if ["i_month", "i_day", "i_hour", "i_minute", "i_second"].indexOf(attr) != -1 then "(\\d{1,2})"
    else if ["extension"].indexOf(attr) != -1 then "(\\.\\w+)"
    else "([\\s\\S]+)"

  createUntemplateMatcher(keys, /// ^ #{text} $ ///)

createUntemplateMatcher = (keys, regex) ->
  (str) ->
    return unless str

    matches = regex.exec(str)
    return unless matches

    results = { "_" : matches[0] }
    keys.forEach (key, idx) -> results[key] = matches[idx + 1]
    results

# ==================================================
# Date and Time
#

parseDate = (hash) ->
  date = new Date()

  map =
    setYear: ["year"]
    setMonth: ["month", "i_month"]
    setDate: ["day", "i_day"]
    setHours: ["hour", "i_hour"]
    setMinutes: ["minute", "i_minute"]
    setSeconds: ["second", "i_second"]

  for key, values of map
    value = values.find (val) -> !!hash[val]
    if value
      value = parseInt(hash[value], 10)
      value = value - 1 if key == 'setMonth'
      date[key](value)

  getDate(date)

getDate = (date = new Date()) ->
  year: "" + date.getFullYear()
  # with prepended 0
  month: ("0" + (date.getMonth() + 1)).slice(-2)
  day: ("0" + date.getDate()).slice(-2)
  hour: ("0" + date.getHours()).slice(-2)
  minute: ("0" + date.getMinutes()).slice(-2)
  second: ("0" + date.getSeconds()).slice(-2)
  # without prepend 0
  i_month: "" + (date.getMonth() + 1)
  i_day: "" + date.getDate()
  i_hour: "" + date.getHours()
  i_minute: "" + date.getMinutes()
  i_second: "" + date.getSeconds()

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

IMG_EXTENSIONS = [".jpg", ".jpeg", ".png", ".gif", ".ico"]

isImageFile = (file) ->
  file && (path.extname(file).toLowerCase() in IMG_EXTENSIONS)

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
  id = escapeRegExp(id) unless opts.noEscape
  ///
  \[(#{id})\]\ ?\[\]            # [text][]
  |                             # or
  \[([^\[\]]+?)\]\ ?\[(#{id})\] # [text][id]
  ///

# REFERENCE_LINK_REGEX.exec("[text][id]")
# => ["[text][id]", undefined, "text", "id"]
#
# REFERENCE_LINK_REGEX.exec("[text][]")
# => ["[text][]", "text", undefined, undefined]
REFERENCE_LINK_REGEX = REFERENCE_LINK_REGEX_OF(".+?", noEscape: true)

REFERENCE_DEF_REGEX_OF = (id, opts = {}) ->
  id = escapeRegExp(id) unless opts.noEscape
  /// ^\ *                      # start of line with any spaces
  \[(#{id})\]:\ +               # [id]: followed by spaces
  (\S*?)                        # link
  (?:\ +['"\(]?(.+?)['"\)]?)?   # any "link title"
  $ ///m

REFERENCE_DEF_REGEX = REFERENCE_DEF_REGEX_OF(".+?", noEscape: true)

isReferenceLink = (input) -> REFERENCE_LINK_REGEX.test(input)
parseReferenceLink = (input, editor) ->
  link = REFERENCE_LINK_REGEX.exec(input)
  text = link[2] || link[1]
  id   = link[3] || link[1]
  def  = undefined
  editor.buffer.scan REFERENCE_DEF_REGEX_OF(id), (match) -> def = match

  if def
    id: id, text: text, url: def.match[2], title: def.match[3] || "",
    definitionRange: def.computedRange
  else
    id: id, text: text, url: "", title: "", definitionRange: null

isReferenceDefinition = (input) -> REFERENCE_DEF_REGEX.test(input)
parseReferenceDefinition = (input, editor) ->
  def  = REFERENCE_DEF_REGEX.exec(input)
  id   = def[1]
  link = undefined
  editor.buffer.scan REFERENCE_LINK_REGEX_OF(id), (match) -> link = match

  if link
    id: id, text: link.match[2] || link.match[1], url: def[2],
    title: def[3] || "", linkRange: link.computedRange
  else
    id: id, text: "", url: def[2], title: def[3] || "", linkRange: null

# ==================================================
# Table
#

TABLE_SEPARATOR_REGEX = /// ^
  (\|)?                # starts with an optional |
  (
   (?:\s*(?:-+|:-*:|:-*|-*:)\s*\|)+ # one or more table cell
   (?:\s*(?:-+|:-*:|:-*|-*:)\s*)    # last table cell
  )
  (\|)?                # ends with an optional |
  $ ///

TABLE_ONE_COLUMN_SEPARATOR_REGEX = /// ^ (\|)(\s*:?-+:?\s*)(\|) $ ///

isTableSeparator = (line) ->
  line = line.trim()
  TABLE_SEPARATOR_REGEX.test(line) ||
  TABLE_ONE_COLUMN_SEPARATOR_REGEX.test(line)

parseTableSeparator = (line) ->
  line = line.trim()
  matches = TABLE_SEPARATOR_REGEX.exec(line) ||
    TABLE_ONE_COLUMN_SEPARATOR_REGEX.exec(line)
  columns = matches[2].split("|").map (col) -> col.trim()

  return {
    separator: true
    extraPipes: !!(matches[1] || matches[matches.length - 1])
    columns: columns
    columnWidths: columns.map (col) -> col.length
    alignments: columns.map (col) ->
      head = col[0] == ":"
      tail = col[col.length - 1] == ":"

      if head && tail
        "center"
      else if head
        "left"
      else if tail
        "right"
      else
        "empty"
  }

TABLE_ROW_REGEX = /// ^
  (\|)?                # starts with an optional |
  (.+?\|.+?)           # any content with at least 2 columns
  (\|)?                # ends with an optional |
  $ ///

TABLE_ONE_COLUMN_ROW_REGEX = /// ^ (\|)([^\|]+?)(\|) $ ///

isTableRow = (line) ->
  line = line.trimRight()
  TABLE_ROW_REGEX.test(line) || TABLE_ONE_COLUMN_ROW_REGEX.test(line)

parseTableRow = (line) ->
  return parseTableSeparator(line) if isTableSeparator(line)

  line = line.trimRight()
  matches = TABLE_ROW_REGEX.exec(line) || TABLE_ONE_COLUMN_ROW_REGEX.exec(line)
  columns = matches[2].split("|").map (col) -> col.trim()

  return {
    separator: false
    extraPipes: !!(matches[1] || matches[matches.length - 1])
    columns: columns
    columnWidths: columns.map (col) -> wcswidth(col)
  }

# defaults:
#   numOfColumns: 3
#   columnWidth: 3
#   columnWidths: []
#   extraPipes: true
#   alignment: "left" | "right" | "center" | "empty"
#   alignments: []
createTableSeparator = (options) ->
  options.columnWidths ?= []
  options.alignments ?= []

  row = []
  for i in [0..options.numOfColumns - 1]
    columnWidth = options.columnWidths[i] || options.columnWidth

    # empty spaces will be inserted when join pipes, so need to compensate here
    if !options.extraPipes && (i == 0 || i == options.numOfColumns - 1)
      columnWidth += 1
    else
      columnWidth += 2

    switch options.alignments[i] || options.alignment
      when "center"
        row.push(":" + "-".repeat(columnWidth - 2) + ":")
      when "left"
        row.push(":" + "-".repeat(columnWidth - 1))
      when "right"
        row.push("-".repeat(columnWidth - 1) + ":")
      else
        row.push("-".repeat(columnWidth))

  row = row.join("|")
  if options.extraPipes then "|#{row}|" else row

# columns: [values]
# defaults:
#   numOfColumns: 3
#   columnWidth: 3
#   columnWidths: []
#   extraPipes: true
#   alignment: "left" | "right" | "center" | "empty"
#   alignments: []
createTableRow = (columns, options) ->
  options.columnWidths ?= []
  options.alignments ?= []

  row = []
  for i in [0..options.numOfColumns - 1]
    columnWidth = options.columnWidths[i] || options.columnWidth

    if !columns[i]
      row.push(" ".repeat(columnWidth))
      continue

    len = columnWidth - wcswidth(columns[i])
    throw new Error("Column width #{columnWidth} - wcswidth('#{columns[i]}') cannot be #{len}") if len < 0

    switch options.alignments[i] || options.alignment
      when "center"
        row.push(" ".repeat(len / 2) + columns[i] + " ".repeat((len + 1) / 2))
      when "left"
        row.push(columns[i] + " ".repeat(len))
      when "right"
        row.push(" ".repeat(len) + columns[i])
      else
        row.push(columns[i] + " ".repeat(len))

  row = row.join(" | ")
  if options.extraPipes then "| #{row} |" else row

# ==================================================
# URL
#

URL_REGEX = ///
  ^(?:\w+:)?\/\/
  ([^\s\.]+\.\S{2}|localhost[\:?\d]*)
  \S*$
  ///i

isUrl = (url) -> URL_REGEX.test(url)

# Normalize a file path to URL separator
normalizeFilePath = (path) -> path.split(/[\\\/]/).join('/')

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
  escapeRegExp: escapeRegExp
  slugize: slugize
  normalizeFilePath: normalizeFilePath

  getPackagePath: getPackagePath
  getProjectPath: getProjectPath
  getSitePath: getSitePath
  getHomedir: getHomedir
  getAbsolutePath: getAbsolutePath

  setTabIndex: setTabIndex

  template: template
  untemplate: untemplate

  getDate: getDate
  parseDate: parseDate

  isImageTag: isImageTag
  parseImageTag: parseImageTag
  isImage: isImage
  parseImage: parseImage

  isInlineLink: isInlineLink
  parseInlineLink: parseInlineLink
  isReferenceLink: isReferenceLink
  parseReferenceLink: parseReferenceLink
  isReferenceDefinition: isReferenceDefinition
  parseReferenceDefinition: parseReferenceDefinition

  isTableSeparator: isTableSeparator
  parseTableSeparator: parseTableSeparator
  createTableSeparator: createTableSeparator
  isTableRow: isTableRow
  parseTableRow: parseTableRow
  createTableRow: createTableRow

  isUrl: isUrl
  isImageFile: isImageFile

  getTextBufferRange: getTextBufferRange
