{$, View, EditorView} = require "atom"
utils = require "./utils"
CSON = require "season"
path = require "path"
fs = require "fs-plus"

### TODO
- Able to remove existing link
- Support link with id
###

module.exports =
class AddLinkView extends View
  editor: null
  posts: null
  links: null
  previouslyFocusedElement: null

  @content: ->
    @div class: "md-writer md-writer-dialog overlay from-top", =>
      @label "Create Link", class: "icon icon-link"
      @div =>
        @label "Text to be displayed", class: "message"
        @subview "textEditor", new EditorView(mini: true)
        @label "Web Address", class: "message"
        @subview "urlEditor", new EditorView(mini: true)
        @label "Title", class: "message"
        @subview "titleEditor", new EditorView(mini: true)
      @p =>
        @input type: "checkbox", outlet: "saveCheckbox"
        @span "Automatically link to this text", class: "cb-label"
      @div outlet: "searchBox", =>
        @label "Search Posts", class: "icon icon-search"
        @subview "searchEditor", new EditorView(mini: true)
        @ul class: "md-writer-list", outlet: "searchResult"

  initialize: ->
    @fetchPosts()
    @loadLinks()
    @handleEvents()
    @on "core:confirm", => @onConfirm()
    @on "core:cancel", => @detach()

  handleEvents: ->
    @searchEditor.hiddenInput.on "keyup", => @updateSearch()
    @searchResult.on "click", "li", (e) => @useSearchResult(e)

  onConfirm: ->
    text = @textEditor.getText()
    title = @titleEditor.getText()
    url = @urlEditor.getText()
    @insertLinkToEditor(text, title, url)
    @saveLink(text, title, url) if @saveCheckbox.prop("checked")
    @detach()

  display: ->
    @previouslyFocusedElement = $(':focus')
    @editor = atom.workspace.getActiveEditor()
    @setLinkFromSelection()
    atom.workspaceView.append(this)
    @searchBox.hide()
    if @textEditor.getText()
      @urlEditor.focus()
    else
      @textEditor.focus()

  detach: ->
    return unless @hasParent()
    @previouslyFocusedElement?.focus()
    super

  setLinkFromSelection: ->
    selection = @editor.getSelectedText()
    return unless selection
    if utils.isLink(selection)
      link = utils.parseLink(selection)
      @textEditor.setText(link.text)
      @urlEditor.setText(link.url)
      @titleEditor.setText(link.title)
    else
      @textEditor.setText(selection)
      @setLinkUsingText(selection.toLowerCase())

  setLinkUsingText: (text) ->
    if @links and @links[text]
      @titleEditor.setText(@links[text].title)
      @urlEditor.setText(@links[text].url)

  updateSearch: ->
    return unless @posts
    query = @searchEditor.getText().trim()
    results = @posts.filter (post) -> query and post.title.contains(query)
    results = results.map (post) ->
      "<li data-url='#{post.url}'>#{post.title}</li>"
    @searchResult.empty().append(results.join(""))

  useSearchResult: (e) ->
    @titleEditor.setText(e.target.textContent)
    @urlEditor.setText(e.target.dataset.url)

  insertLinkToEditor: (text, title, url) ->
    if title
      @editor.insertText("[#{text}](#{url} '#{title}')")
    else
      @editor.insertText("[#{text}](#{url})")

  saveLink: (text, title, url) ->
    try
      @links[text.toLowerCase()] = title: title, url: url
      CSON.writeFileSync(@getLinkPath(), @links)
    catch error
      console.log(error.message)

  loadLinks: ->
    try
      file = @getLinkPath()
      if fs.existsSync(file)
        @links = CSON.readFileSync(file)
      else
        @links = {}
    catch error
      console.log(error.message)

  getLinkPath: ->
    atom.project.resolve(atom.config.get("md-writer.siteLinkPath"))

  fetchPosts: ->
    uri = atom.config.get("md-writer.urlForPosts")
    succeed = (body) =>
      @searchBox.show()
      @posts = body.posts
    error = (err) => @searchBox.hide()
    utils.getJSON(uri, succeed, error)
