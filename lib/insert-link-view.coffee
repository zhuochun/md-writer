{$, View, TextEditorView} = require "atom-space-pen-views"
config = require "./config"
utils = require "./utils"
helper = require "./insert-link-helper"
CSON = require "season"
fs = require "fs-plus"

posts = null # to cache posts

module.exports =
class InsertLinkView extends View
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
      "core:cancel": => @detach()

  onConfirm: ->
    link =
      text: @textEditor.getText()
      url: @urlEditor.getText().trim()
      title: @titleEditor.getText().trim()

    @editor.transact =>
      if link.url then @insertLink(link) else @removeLink(link.text)

    @updateSavedLinks(link)
    @detach()

  display: ->
    @editor = atom.workspace.getActiveTextEditor()
    @panel ?= atom.workspace.addModalPanel(item: this, visible: false)
    @previouslyFocusedElement = $(document.activeElement)
    @panel.show()
    @fetchPosts()
    @loadSavedLinks =>
      @_normalizeSelectionAndSetLinkFields()

      if @textEditor.getText()
        @urlEditor.getModel().selectAll()
        @urlEditor.focus()
      else
        @textEditor.focus()

  detach: ->
    if @panel.isVisible()
      @panel.hide()
      @previouslyFocusedElement?.focus()
    super

  _normalizeSelectionAndSetLinkFields: ->
    @range = utils.getTextBufferRange(@editor, "link")
    link = @_findLinkInRange()

    @referenceId = link.id
    @range = link.linkRange || @range
    @definitionRange = link.definitionRange

    @setLink(link)
    @saveCheckbox.prop("checked", @isInSavedLink(link))

  _findLinkInRange: ->
    selection = @editor.getTextInRange(@range)

    if utils.isInlineLink(selection)
      return utils.parseInlineLink(selection)

    if utils.isReferenceLink(selection)
      return utils.parseReferenceLink(selection, @editor)

    if utils.isReferenceDefinition(selection)
      # HACK correct the definition range, Atom's link scope does not include
      # definition's title, so normalize to be the range start row
      selection = @editor.lineTextForBufferRow(@range.start.row)
      @range = @editor.bufferRangeForBufferRow(@range.start.row)

      link = utils.parseReferenceDefinition(selection, @editor)
      link.definitionRange = @range

      # when link.linkRange is undefined, the definition is an orphan,
      # will just ignore it and take it as normal text instead
      return link if link.linkRange

    if @getSavedLink(selection)
      return @getSavedLink(selection)

    text: selection, url: "", title: ""

  updateSearch: (query) ->
    return unless query && posts
    query = query.trim().toLowerCase()
    results = posts
      .filter((post) -> post.title.toLowerCase().indexOf(query) >= 0)
      .map((post) -> "<li data-url='#{post.url}'>#{post.title}</li>")
    @searchResult.empty().append(results.join(""))

  useSearchResult: (e) ->
    @textEditor.setText(e.target.textContent) unless @textEditor.getText()
    @titleEditor.setText(e.target.textContent)
    @urlEditor.setText(e.target.dataset.url)
    @titleEditor.focus()

  insertLink: (link) ->
    if @definitionRange
      @updateReferenceLink(link)
    else if link.title
      @insertReferenceLink(link)
    else
      @editor.setTextInBufferRange(@range, "[#{link.text}](#{link.url})")

  updateReferenceLink: (link) ->
    if link.title # update the reference link
      linkText = "[#{link.text}][#{@referenceId}]"
      @editor.setTextInBufferRange(@range, linkText)

      definitionText = @_referenceDefinition(link.url, link.title)
      @editor.setTextInBufferRange(@definitionRange, definitionText)
    else # change to inline link
      @removeReferenceLink("[#{link.text}](#{link.url})")

  insertReferenceLink: (link) ->
    @referenceId = require("guid").raw()[0..7] # create an unique id

    linkText = "[#{link.text}][#{@referenceId}]"
    @editor.setTextInBufferRange(@range, linkText)

    definitionText = @_referenceDefinition(link.url, link.title)
    if config.get("referenceInsertPosition") == "article"
      helper.insertAtEndOfArticle(@editor, definitionText)
    else
      helper.insertAfterCurrentParagraph(@editor, definitionText)

  _referenceIndentLength: ->
    " ".repeat(config.get("referenceIndentLength"))

  _formattedReferenceTitle: (title) ->
    if /^[-\*\!]$/.test(title) then "" else " \"#{title}\""

  _referenceDefinition: (url, title) ->
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
    helper.removeDefinitionRange(@editor, @definitionRange)
    @editor.setCursorBufferPosition(position)

  setLink: (link) ->
    @textEditor.setText(link.text)
    @titleEditor.setText(link.title)
    @urlEditor.setText(link.url)

  getSavedLink: (text) ->
    link = @links?[text.toLowerCase()]
    return link unless link

    link["text"] = text unless link.text
    return link

  isInSavedLink: (link) ->
    savedLink = @getSavedLink(link.text)
    !!savedLink && !(["text", "title", "url"].some (k) -> savedLink[k] != link[k])

  updateToLinks: (link) ->
    linkUpdated = false
    inSavedLink = @isInSavedLink(link)

    if @saveCheckbox.prop("checked")
      if !inSavedLink && link.url
        @links[link.text.toLowerCase()] = link
        linkUpdated = true
    else if inSavedLink
      delete @links[link.text.toLowerCase()]
      linkUpdated = true

    return linkUpdated

  # save the new link to CSON file if the link has updated @links
  updateSavedLinks: (link) ->
    CSON.writeFile(config.get("siteLinkPath"), @links) if @updateToLinks(link)

  # load saved links from CSON files
  loadSavedLinks: (callback) ->
    CSON.readFile config.get("siteLinkPath"), (err, data) =>
      @links = data || {}
      callback()

  # fetch remote posts in JSON format
  fetchPosts: ->
    return (@searchBox.hide() if posts.length < 1) if posts

    succeed = (body) =>
      posts = body.posts
      if posts.length > 0
        @searchBox.show()
        @searchEditor.setText(@textEditor.getText())
        @updateSearch(@textEditor.getText())
    error = (err) => @searchBox.hide()

    utils.getJSON(config.get("urlForPosts"), succeed, error)
