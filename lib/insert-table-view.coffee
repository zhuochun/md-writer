{$, View, TextEditorView} = require "atom-space-pen-views"

module.exports =
class InsertTableView extends View
  editor: null
  previouslyFocusedElement: null

  @content: ->
    @div class: "markdown-writer markdown-writer-dialog", =>
      @label "Insert Table", class: "icon icon-diff-added"
      @div =>
        @label "Rows", class: "message"
        @subview "rowEditor", new TextEditorView(mini: true)
        @label "Columns", class: "message"
        @subview "columnEditor", new TextEditorView(mini: true)

  initialize: ->
    atom.commands.add @element,
      "core:confirm": => @onConfirm()
      "core:cancel":  => @detach()

  onConfirm: ->
    row = parseInt(@rowEditor.getText(), 10)
    col = parseInt(@columnEditor.getText(), 10)

    @insertTable(row, col)
    @detach()

  display: ->
    @editor = atom.workspace.getActiveTextEditor()
    @panel ?= atom.workspace.addModalPanel(item: this, visible: false)
    @previouslyFocusedElement = $(document.activeElement)
    @rowEditor.setText("3")
    @columnEditor.setText("3")
    @panel.show()
    @rowEditor.focus()

  detach: ->
    return unless @panel.isVisible()
    @panel.hide()
    @previouslyFocusedElement?.focus()
    super

  insertTable: (row, col) ->
    return unless @isValidRange(row, col)
    cursor = @editor.getCursorBufferPosition()
    @editor.insertText(@createTable(row, col))
    @editor.setCursorBufferPosition(cursor)

  createTable: (row, col) ->
    table = []

    # insert header
    table.push(@createTableRow(col, beg: " |", mid: " |", end: ""))
    table.push(@createTableRow(col, beg: "-|", mid: "-|", end: "-"))
    # insert rest
    while row -= 1 && row > 0
      table.push(@createTableRow(col, beg: " |", mid: " |", end: ""))

    table.join("\n")

  createTableRow: (colNum, {beg, mid, end}) ->
    beg + mid.repeat(colNum - 2) + end

  # at least 2 row + 2 columns
  isValidRange: (row, col) ->
    if isNaN(row) or isNaN(col)
      false
    if row < 2 or col < 2
      false
    else
      true
