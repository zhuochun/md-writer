utils = require "./utils"

styles =
  h1: before: "# ", after: ""
  h2: before: "## ", after: ""
  h3: before: "### ", after: ""
  h4: before: "#### ", after: ""
  h5: before: "##### ", after: ""
  blockquote: before: "> ", after: ""

module.exports =
class StyleHeading
  editor: null
  style: null

  constructor: (style) ->
    @style = styles[style]

  display: ->
    @editor = atom.workspace.getActiveEditor()
    @editor.getCursors().forEach (cursor) =>
      if line = @getLine(cursor)
        @toggleStyle(cursor, line)
      else
        @insertEmptyStyle(cursor)

  getLine: (cursor) ->
    cursor.moveToBeginningOfLine()
    cursor.selection.selectToEndOfLine()
    return cursor.selection.getText()

  toggleStyle: (cursor, text) ->
    if @isStyleOn(text)
      text = @removeStyle(text)
    else
      text = @addStyle(text)
    cursor.selection.insertText(text)

  insertEmptyStyle: (cursor) ->
    cursor.selection.insertText(@addStyle(""))
    pos = cursor.getBufferPosition()
    cursor.setBufferPosition([pos.row, pos.column - @style.after.length])

  isStyleOn: (text) ->
    @getStylePattern().test(text)

  addStyle: (text) ->
    text = /// ^ #{@style.before[0]}* \s? (.*) $ ///.exec(text)[1]
    "#{@style.before}#{text}#{@style.after}"

  removeStyle: (text) ->
    matches = @getStylePattern().exec(text)
    return matches[1..].join("")

  getStylePattern: ->
    before = utils.regexpEscape(@style.before)
    after = utils.regexpEscape(@style.after)
    /// ^#{before} (.*?) #{after}$ ///
