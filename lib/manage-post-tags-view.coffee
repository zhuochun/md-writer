{$, View, EditorView} = require "atom"
utils = require "./utils"
request = require "request"

module.exports =
class ManagePostTagsView extends View
  editor: null
  frontMatter: null
  tags: null
  previouslyFocusedElement: null

  @content: ->
    @div class: "md-writer md-writer-selection overlay from-top", =>
      @label "Manage Post Tags", class: "icon icon-tags"
      @p class: "error", outlet: "error"
      @subview "tagsEditor", new EditorView(mini: true)
      @ul class: "candidates", outlet: "candidates"

  initialize: ->
    @candidates.on "click", "li", (e) => @appendTag(e)
    @on "core:confirm", => @updateFrontMatter()
    @on "core:cancel", => @detach()

  updateFrontMatter: ->
    content = utils.replaceFrontMatter(@editor.getText(), @frontMatter)
    @editor.setText(content)
    @detach()

  detach: ->
    return unless @hasParent()
    @previouslyFocusedElement?.focus()
    super

  display: ->
    @previouslyFocusedElement = $(':focus')
    @editor = atom.workspace.getActiveEditor()

    if @isValidMarkdown(@editor.getText())
      @setFrontMatter()
      @setTagsInFrontMatter()
      @fetchTags()
      atom.workspaceView.append(this)
      @tagsEditor.focus()
    else
      @detach()

  isValidMarkdown: (content) ->
    return !!content and utils.hasFrontMatter(content)

  setFrontMatter: ->
    @frontMatter = utils.getFrontMatter(@editor.getText())
    @frontMatter.tags = [] unless @frontMatter.tags

  setTagsInFrontMatter: ->
    @tagsEditor.setText(@frontMatter.tags.join(","))

  fetchTags: ->
    uri = atom.config.get("md-writer.tagUrl")
    data = uri: uri, json: true, encoding: 'utf-8', gzip: true
    request data, (error, response, body) =>
      if !error and response.statusCode == 200
        @tags = body.tags
        @displayTags(@tags)
      else
        @error.text("Error accessing the tags!")

  displayTags: (tags) ->
    # TODO filter tags based on markdown content
    tagElems = tags.map (tag) =>
      if @frontMatter.tags.indexOf(tag) > 0
        "<li class='selected'>#{tag}</li>"
      else
        "<li>#{tag}</li>"
    @candidates.append(tagElems.join(""))

  appendTag: (e) ->
    tag = e.target.textContent
    idx = @frontMatter.tags.indexOf(tag)
    if idx < 0
      @frontMatter.tags.push(tag)
      e.target.classList.add("selected")
    else
      @frontMatter.tags.splice(idx, 1)
      e.target.classList.remove("selected")
    @setTagsInFrontMatter()
    @tagsEditor.focus()
