{CompositeDisposable} = require 'atom'
{$, View, TextEditorView} = require "atom-space-pen-views"
CSON = require "season"
fs = require "fs-plus"
guid = require "guid"

config = require "../config"
utils = require "../utils"
helper = require "../helpers/insert-link-helper"
templateHelper = require "../helpers/template-helper"

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
    utils.setTabIndex([@textEditor, @urlEditor, @titleEditor,
      @saveCheckbox, @searchEditor])

    @searchEditor.getModel().onDidChange =>
      @updateSearch(@searchEditor.getText()) if posts
    @searchResult.on "click", "li", (e) => @useSearchResult(e)

    @disposables = new CompositeDisposable()
    @disposables.add(atom.commands.add(
      @element, {
        "core:confirm": => @onConfirm(),
        "core:cancel":  => @detach()
      }))

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
    @panel ?= atom.workspace.addModalPanel(item: this, visible: false)
    @previouslyFocusedElement = $(document.activeElement)
    @editor = atom.workspace.getActiveTextEditor()
    @panel.show()
    # fetch remote and local links
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

  detached: ->
    @disposables?.dispose()
    @disposables = null

  _normalizeSelectionAndSetLinkFields: ->
    @range = utils.getTextBufferRange(@editor, "link")
    @currLink = @_findLinkInRange()

    @referenceId = @currLink.id
    @range = @currLink.linkRange || @range
    @definitionRange = @currLink.definitionRange

    @setLink(@currLink)
    @saveCheckbox.prop("checked", @isInSavedLink(@currLink))

  _findLinkInRange: ->
    link = utils.findLinkInRange(@editor, @range)
    if link?
      return link unless link.id
      # Check is link it an orphan reference link
      return link if link.id && link.linkRange && link.definitionRange
      #  Remove link.id if it is orphan
      link.id = null
      return link
    # Find selection in saved links, and auto-populate it
    selection = @editor.getTextInRange(@range)
    return @getSavedLink(selection) if @getSavedLink(selection)
    # Default fallback
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
      @insertInlineLink(link)

  insertInlineLink: (link) ->
    text = templateHelper.create("linkInlineTag", link)
    @editor.setTextInBufferRange(@range, text)

  updateReferenceLink: (link) ->
    if link.title # update the reference link
      link = @_referenceLink(link)
      inlineText = templateHelper.create("referenceInlineTag", link)
      definitionText = templateHelper.create("referenceDefinitionTag", link)

      if definitionText
        @editor.setTextInBufferRange(@range, inlineText)
        @editor.setTextInBufferRange(@definitionRange, definitionText)
      else
        @replaceReferenceLink(inlineText)
    else # replace by to inline link
      inlineLink = templateHelper.create("linkInlineTag", link)
      @replaceReferenceLink(inlineLink)

  insertReferenceLink: (link) ->
    link = @_referenceLink(link)
    inlineText = templateHelper.create("referenceInlineTag", link)
    definitionText = templateHelper.create("referenceDefinitionTag", link)

    @editor.setTextInBufferRange(@range, inlineText)
    if definitionText # insert only if definitionText exists
      if config.get("referenceInsertPosition") == "article"
        helper.insertAtEndOfArticle(@editor, definitionText)
      else
        helper.insertAfterCurrentParagraph(@editor, definitionText)

  _referenceLink: (link) ->
    link['indent'] = " ".repeat(config.get("referenceIndentLength"))
    link['title'] = if /^[-\*\!]$/.test(link.title) then "" else link.title
    link['label'] = @referenceId || guid.raw()[0..7]
    link

  removeLink: (text) ->
    if @referenceId
      @replaceReferenceLink(text) # replace with raw text
    else
      @editor.setTextInBufferRange(@range, text)

  replaceReferenceLink: (text) ->
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
