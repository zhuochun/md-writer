{$, View, TextEditorView} = require "atom-space-pen-views"
config = require "./config"
utils = require "./utils"
helper = require "./insert-link-helper"
CSON = require "season"
fs = require "fs-plus"

posts = null # to cache posts

module.exports =
class InsertLinkView extends View
  editor: null
  range: null
  links: null
  referenceId: false
  previouslyFocusedElement: null

  @content: ->
    @div class: "markdown-writer markdown-writer-dialog", =>
      @label "Insert Link", class: "icon icon-globe"
      @div =>
        @label "Text to be displayed", class: "message"
        @subview "textEditor", new TextEditorView(mini: true)
        @label "Web Address", class: "message"
        @subview "urlEditor", new TextEditorView(mini: true)
        @label "Title", class: "message"
        @subview "titleEditor", new TextEditorView(mini: true)
      @div class: "dialog-row", =>
        @label for: "markdown-writer-save-link-checkbox", =>
          @input id: "markdown-writer-save-link-checkbox",
            type:"checkbox", outlet: "saveCheckbox"
          @span "Automatically link to this text next time", class: "side-label"
      @div outlet: "searchBox", =>
        @label "Search Posts", class: "icon icon-search"
        @subview "searchEditor", new TextEditorView(mini: true)
        @ul class: "markdown-writer-list", outlet: "searchResult"

  initialize: ->
    @searchEditor.getModel().onDidChange =>
      @updateSearch(@searchEditor.getText()) if posts
    @searchResult.on "click", "li", (e) => @useSearchResult(e)

    atom.commands.add @element,
      "core:confirm": => @onConfirm()
      "core:cancel":  => @detach()

  onConfirm: ->
    text = @textEditor.getText()
    url = @urlEditor.getText().trim()
    title = @titleEditor.getText().trim()

    @editor.transact =>
      if url then @insertLink(text, title, url) else @removeLink(text)

    @updateSavedLink(text, title, url)
    @detach()

  display: ->
    @editor = atom.workspace.getActiveTextEditor()
    @panel ?= atom.workspace.addModalPanel(item: this, visible: false)
    @previouslyFocusedElement = $(document.activeElement)
    @panel.show()
    @fetchPosts()
    @loadSavedLinks =>
      @setFieldsFromSelection()
      if @textEditor.getText()
        @urlEditor.getModel().selectAll()
        @urlEditor.focus()
      else
        @textEditor.focus()

  detach: ->
    return unless @panel.isVisible()
    @panel.hide()
    @previouslyFocusedElement?.focus()
    super

  setFieldsFromSelection: ->
    @range = utils.getSelectedTextBufferRange(@editor, "link")
    selection = @editor.getTextInRange(@range)
    @_setFieldsFromSelection(selection) if selection

  _setFieldsFromSelection: (selection) ->
    if utils.isInlineLink(selection)
      link = utils.parseInlineLink(selection)
      @setLink(link.text, link.url, link.title)
      @saveCheckbox.prop("checked", true) if @isInSavedLink(link)
    else if utils.isReferenceLink(selection)
      link = utils.parseReferenceLink(selection, @editor.getText())
      @referenceId = link.id
      @setLink(link.text, link.url, link.title)
      @saveCheckbox.prop("checked", true) if @isInSavedLink(link)
    else if @getSavedLink(selection)
      link = @getSavedLink(selection)
      @setLink(selection, link.url, link.title)
      @saveCheckbox.prop("checked", true)
    else
      @setLink(selection, "", "")

  updateSearch: (query) ->
    return unless query and posts
    query = query.trim().toLowerCase()
    results = posts
      .filter((post) -> post.title.toLowerCase().indexOf(query) >= 0)
      .map((post) -> "<li data-url='#{post.url}'>#{post.title}</li>")
    @searchResult.empty().append(results.join(""))

  useSearchResult: (e) ->
    @titleEditor.setText(e.target.textContent)
    @urlEditor.setText(e.target.dataset.url)
    @textEditor.setText(e.target.textContent) unless @textEditor.getText()
    @titleEditor.focus()

  insertLink: (text, title, url) ->
    if @referenceId
      @updateReferenceLink(text, title, url)
    else if title
      @insertReferenceLink(text, title, url)
    else
      @editor.setTextInBufferRange(@range, "[#{text}](#{url})")

  updateReferenceLink: (text, title, url) ->
    if title # update the reference link
      position = @editor.getCursorBufferPosition()
      referenceTagRegex = ///
        ^\ *\[#{utils.regexpEscape(@referenceId)}\]:\ +([\S\ ]+)$
      ///
      @editor.buffer.scan referenceTagRegex, (match) =>
        @editor.setTextInBufferRange match.range, @_referenceLink(url, title)
      @editor.setCursorBufferPosition(position)
    else # change to inline link
      @removeReferenceLink("[#{text}](#{url})")

  insertReferenceLink: (text, title, url) ->
    @referenceId = require("guid").raw()[0..7] # create an unique id

    referenceText = "[#{text}][#{@referenceId}]"
    @editor.setTextInBufferRange(@range, referenceText)

    referenceLink = @_referenceLink(url, title)
    if config.get("referenceInsertPosition") == "article"
      helper.insertAtEndOfArticle(@editor, referenceLink)
    else
      helper.insertAfterCurrentParagraph(@editor, referenceLink)

  _referenceIndentLength: ->
    " ".repeat(config.get("referenceIndentLength"))
  _formattedReferenceTitle: (title) ->
    if /^[-\*\!]$/.test(title) then "" else " \"#{title}\""
  _referenceLink: (url, title) ->
    indent = @_referenceIndentLength()
    title = @_formattedReferenceTitle(title)
    "#{indent}[#{@referenceId}]: #{url}#{title}"

  removeLink: (text) ->
    if @referenceId
      @removeReferenceLink(text)
    else
      @editor.setTextInBufferRange(@range, text)

  removeReferenceLink: (text) ->
    @editor.setTextInBufferRange(@range, text)
    position = @editor.getCursorBufferPosition()
    referenceTagRegex = ///^\ *\[#{utils.regexpEscape(@referenceId)}\]:\ +///
    @editor.buffer.scan referenceTagRegex, (match) =>
      lineNum = match.range.getRows()[0]
      emptyLineAbove = @editor.lineTextForBufferRow(lineNum - 1).trim() == ""
      emptyLineBelow = @editor.lineTextForBufferRow(lineNum + 1).trim() == ""
      @editor.setSelectedBufferRange(match.range)
      @editor.deleteLine()
      @editor.deleteLine() if emptyLineAbove and emptyLineBelow
    @editor.setCursorBufferPosition(position)

  setLink: (text, url, title) ->
    @textEditor.setText(text)
    @urlEditor.setText(url)
    @titleEditor.setText(title)

  getSavedLink: (text) ->
    @links?[text.toLowerCase()]

  isInSavedLink: (link) ->
    savedLink = @getSavedLink(link.text)
    savedLink and savedLink.title == link.title and savedLink.url == link.url

  updateSavedLink: (text, title, url) ->
    if @saveCheckbox.prop("checked")
      @links[text.toLowerCase()] = title: title, url: url if url
    else if @isInSavedLink(text: text, title: title, url: url)
      delete @links[text.toLowerCase()]

    file = config.get("siteLinkPath")
    fs.exists file, (exists) =>
      CSON.writeFile(file, @links) if exists

  loadSavedLinks: (callback) ->
    setLinks = (data) => @links = data || {}; callback()
    readFile = (file) -> CSON.readFile file, (err, data) -> setLinks(data)

    file = config.get("siteLinkPath")
    fs.exists file, (exists) ->
      if exists then readFile(file) else setLinks()

  fetchPosts: ->
    if posts
      @searchBox.hide() if posts.length < 1
      return

    uri = config.get("urlForPosts")
    succeed = (body) =>
      posts = body.posts
      if posts.length > 0
        @searchBox.show()
        @searchEditor.setText(@textEditor.getText())
        @updateSearch(@textEditor.getText())
    error = (err) => @searchBox.hide()

    utils.getJSON(uri, succeed, error)
