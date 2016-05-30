yaml = require "js-yaml"

FRONT_MATTER_REGEX = ///
  ^(?:---\s*$)?  # match open --- (if any)
  (
    [^:]+:      # match at least 1 open key
    [\s\S]*?    # match the rest
  )
  ^---\s*$       # match ending ---
  ///m

module.exports =
class FrontMatter
  # options:
  #   silient = true/false
  constructor: (editor, options = {}) ->
    @editor = editor
    @options = options
    @content = {}
    @leadingFence = true
    @isEmpty = true
    @parseError = null

    # find and parse front matter
    @_findFrontMatter (match) =>
      try
        @content = yaml.safeLoad(match.match[1].trim()) || {}
        @leadingFence = match.matchText.startsWith("---")
        @isEmpty = false
      catch error
        @parseError = error
        @content = {}
        unless options["silent"] == true
          atom.confirm
            message: "[Markdown Writer] Error!"
            detailedMessage: "Invalid Front Matter:\n#{error.message}"
            buttons: ['OK']

  _findFrontMatter: (onMatch) ->
    @editor.buffer.scan(FRONT_MATTER_REGEX, onMatch)

  # normalize the field to an array
  normalizeField: (field) ->
    if Object.prototype.toString.call(@content[field]) == "[object Array]"
      @content[field]
    else if typeof @content[field] == "string"
      @content[field] = [@content[field]]
    else
      @content[field] = []

  has: (field) -> field && @content[field]?

  get: (field) -> @content[field]

  getArray: (field) ->
    @normalizeField(field)
    @content[field]

  set: (field, content) -> @content[field] = content

  setIfExists: (field, content) ->
    @content[field] = content if @has(field)

  getContent: -> JSON.parse(JSON.stringify(@content))

  getContentText: ->
    text = yaml.safeDump(@content)
    if @leadingFence
      ["---", "#{text}---", ""].join("\n")
    else
      ["#{text}---", ""].join("\n")

  save: ->
    @_findFrontMatter (match) => match.replace(@getContentText())
