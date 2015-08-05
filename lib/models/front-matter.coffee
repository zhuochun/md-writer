os = require "os"
yaml = require "js-yaml"

FRONT_MATTER_REGEX = ///
  ^(?:---\s*)?  # match open --- (if any)
  (
    [^:]+:      # match at least 1 open key
    [\s\S]*?    # match the rest
  )
  ---\s*$       # match ending ---
  ///m

module.exports =
class FrontMatter
  constructor: (editor) ->
    @editor = editor
    @content = {}
    @leadingFence = true
    @isEmpty = true

    # find and parse front matter
    @_findFrontMatter (match) =>
      @content = yaml.safeLoad(match.match[1].trim())
      @leadingFence = match.matchText.startsWith("---")
      @isEmpty = false

  _findFrontMatter: (onMatch) ->
    @editor.buffer.scan(FRONT_MATTER_REGEX, onMatch)

  normalizeField: (field) ->
    if !@content[field]
      @content[field] = []
    else if typeof @content[field] == "string"
      @content[field] = [@content[field]]

  has: (field) -> @content[field]?

  get: (field) -> @content[field]

  set: (field, content) -> @content[field] = content

  setIfExists: (field, content) ->
    @content[field] = content if @has(field)

  getContentText: ->
    text = yaml.safeDump(@content)
    if @leadingFence
      ["---", "#{text}---", ""].join(os.EOL)
    else
      ["#{text}---", ""].join(os.EOL)

  save: ->
    @_findFrontMatter (match) => match.replace(@getContentText())
