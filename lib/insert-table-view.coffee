{$, View, EditorView} = require "atom"

module.exports =
class InsertTableView extends View
  editor: null
  previouslyFocusedElement: null

  @content: ->
    @div class: "markdown-writer markdown-writer-dialog overlay from-top", =>
      @label "Insert Table", class: "icon icon-diff-added"
      @div =>
        @label "Rows", class: "message"
        @subview "rowEditor", new EditorView(mini: true)
        @label "Columns", class: "message"
        @subview "columnEditor", new EditorView(mini: true)

  initialize: ->
    @on "core:confirm", => @onConfirm()
    @on "core:cancel", => @detach()

  onConfirm: ->
    row = parseInt(@rowEditor.getText(), 10)
    col = parseInt(@columnEditor.getText(), 10)
    @insertTable(row, col)
    @detach()

  display: ->
    @previouslyFocusedElement = $(':focus')
    @editor = atom.workspace.getActiveEditor()
    atom.workspaceView.append(this)
    @rowEditor.setText("3")
    @columnEditor.setText("3")
    @rowEditor.focus()

  detach: ->
    return unless @hasParent()
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

  createTableRow: (col, {beg, mid, end}) ->
    tr = new Array(col).fill(mid)
    [tr[0], tr[col]] = [beg, end]
    tr.join("")

  # at least 2 rows, 1 column
  isValidRange: (row, col) ->
    if isNaN(row) or isNaN(col)
      false
    if row <= 1 or col <= 0
      false
    else
      true
