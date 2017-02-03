{CompositeDisposable} = require 'atom'
{$, View, TextEditorView} = require "atom-space-pen-views"
guid = require "guid"

config = require "../config"
utils = require "../utils"
helper = require "../helpers/insert-link-helper"
templateHelper = require "../helpers/template-helper"

module.exports =
class InsertFootnoteView extends View
  @content: ->
    @div class: "markdown-writer markdown-writer-dialog", =>
      @label "Insert Footnote", class: "icon icon-pin"
      @div =>
        @label "Label", class: "message"
        @subview "labelEditor", new TextEditorView(mini: true)
      @div outlet: "contentBox", =>
        @label "Content", class: "message"
        @subview "contentEditor", new TextEditorView(mini: true)

  initialize: ->
    utils.setTabIndex([@labelEditor, @contentEditor])

    @disposables = new CompositeDisposable()
    @disposables.add(atom.commands.add(
      @element, {
        "core:confirm": => @onConfirm(),
        "core:cancel":  => @detach()
      }))

  onConfirm: ->
    footnote =
      label: @labelEditor.getText()
      content: @contentEditor.getText()

    @editor.transact =>
      if @footnote
        @updateFootnote(footnote)
      else
        @insertFootnote(footnote)

    @detach()

  display: ->
    @panel ?= atom.workspace.addModalPanel(item: this, visible: false)
    @previouslyFocusedElement = $(document.activeElement)
    @editor = atom.workspace.getActiveTextEditor()
    @_normalizeSelectionAndSetFootnote()
    @panel.show()
    @labelEditor.getModel().selectAll()
    @labelEditor.focus()

  detach: ->
    if @panel.isVisible()
      @panel.hide()
      @previouslyFocusedElement?.focus()
    super

  detached: ->
    @disposables?.dispose()
    @disposables = null

  _normalizeSelectionAndSetFootnote: ->
    @range = utils.getTextBufferRange(@editor, "link", selectBy: "nope")
    @selection = @editor.getTextInRange(@range) || ""

    if utils.isFootnote(@selection)
      @footnote = utils.parseFootnote(@selection)
      @contentBox.hide()
      @labelEditor.setText(@footnote["label"])
    else
      @labelEditor.setText(guid.raw()[0..7])

  updateFootnote: (footnote) ->
    referenceText = templateHelper.create("footnoteReferenceTag", footnote)
    definitionText = templateHelper.create("footnoteDefinitionTag", footnote).trim()

    if @footnote["isDefinition"]
      updateText = definitionText
      findText = templateHelper.create("footnoteReferenceTag", @footnote).trim()
      replaceText = referenceText
    else
      updateText = referenceText
      findText = templateHelper.create("footnoteDefinitionTag", @footnote).trim()
      replaceText = definitionText

    @editor.setTextInBufferRange(@range, updateText)
    @editor.buffer.scan /// #{utils.escapeRegExp(findText)} ///, (match) ->
      match.replace(replaceText)
      match.stop()

  insertFootnote: (footnote) ->
    referenceText = templateHelper.create("footnoteReferenceTag", footnote)
    definitionText = templateHelper.create("footnoteDefinitionTag", footnote).trim()

    @editor.setTextInBufferRange(@range, @selection + referenceText)

    if config.get("footnoteInsertPosition") == "article"
      helper.insertAtEndOfArticle(@editor, definitionText)
    else
      helper.insertAfterCurrentParagraph(@editor, definitionText)
