{CompositeDisposable} = require 'atom'
{$, View, TextEditorView} = require "atom-space-pen-views"

config = require "../config"
utils = require "../utils"

module.exports =
class InsertTableView extends View
  @content: ->
    @div class: "markdown-writer markdown-writer-dialog", =>
      @label "Insert Table", class: "icon icon-diff-added"
      @div =>
        @label "Rows", class: "message"
        @subview "rowEditor", new TextEditorView(mini: true)
        @label "Columns", class: "message"
        @subview "columnEditor", new TextEditorView(mini: true)

  initialize: ->
    utils.setTabIndex([@rowEditor, @columnEditor])

    @disposables = new CompositeDisposable()
    @disposables.add(atom.commands.add(
      @element, {
        "core:confirm": => @onConfirm(),
        "core:cancel":  => @detach()
      }))

  onConfirm: ->
    row = parseInt(@rowEditor.getText(), 10)
    col = parseInt(@columnEditor.getText(), 10)

    @insertTable(row, col) if @isValidRange(row, col)

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
    if @panel.isVisible()
      @panel.hide()
      @previouslyFocusedElement?.focus()
    super

  detached: ->
    @disposables?.dispose()
    @disposables = null

  insertTable: (row, col) ->
    cursor = @editor.getCursorBufferPosition()
    @editor.insertText(@createTable(row, col))
    @editor.setCursorBufferPosition(cursor)

  createTable: (row, col) ->
    options =
      numOfColumns: col
      extraPipes: config.get("tableExtraPipes")
      columnWidth: 1
      alignment: config.get("tableAlignment")

    table = []

    # insert header
    table.push(utils.createTableRow([], options))
    # insert separator
    table.push(utils.createTableSeparator(options))
    # insert body rows
    table.push(utils.createTableRow([], options)) for [0..row - 2]

    table.join("\n")

  # at least 2 row + 2 columns
  isValidRange: (row, col) ->
    return false if isNaN(row) || isNaN(col)
    return false if row < 2 || col < 1
    return true
