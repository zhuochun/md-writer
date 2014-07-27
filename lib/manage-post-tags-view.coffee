{$, View, EditorView} = require "atom"
utils = require "./utils"

module.exports =
class ManagePostTagsView extends View
  editor: null
  frontMatter: null
  tags: null
  previouslyFocusedElement: null

  @content: ->
    @div class: "md-writer md-writer-selection overlay from-top", =>
      @label "Manage Post Tags", class: "icon icon-tag"
      @p class: "error", outlet: "error"
      @subview "tagsEditor", new EditorView(mini: true)
      @ul class: "candidates", outlet: "candidates"

  initialize: ->
    @candidates.on "click", "li", (e) => @appendTag(e)
    @on "core:confirm", => @updateFrontMatter()
    @on "core:cancel", => @detach()

  updateFrontMatter: ->
    @frontMatter.tags = @getEditorTags()
    content = utils.replaceFrontMatter(@editor.getText(), @frontMatter)
    @editor.setText(content)
    @editor.moveCursorToTop()
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
      @setEditorTags(@frontMatter.tags)
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

  setEditorTags: (tags) ->
    @tagsEditor.setText(tags.join(","))

  getEditorTags: ->
    @tagsEditor.getText().split(/\s*,\s*/).filter((t) -> !!t.trim())

  fetchTags: ->
    uri = atom.config.get("md-writer.urlForTags")
    succeed = (body) =>
      @tags = body.tags.map((tag) -> name: tag)
      @rankTags(@tags, @editor.getText())
      @displayTags(@tags)
    error = (err) => @error.text(err.message)
    utils.getJSON(uri, succeed, error)

  # rank tags based on the number of times they appear in content
  rankTags: (tags, content) ->
    tags.forEach (tag) ->
      # TODO handle word boundary across multi-languages
      tagRegex = new RegExp(tag.name, "ig")
      tag.count = content.match(tagRegex)?.length || 0
    tags.sort (t1, t2) -> t2.count - t1.count

  displayTags: (tags) ->
    tagElems = tags.map ({name}) =>
      if @frontMatter.tags.indexOf(name) < 0
        "<li>#{name}</li>"
      else
        "<li class='selected'>#{name}</li>"
    @candidates.empty().append(tagElems.join(""))

  appendTag: (e) ->
    tag = e.target.textContent
    tags = @getEditorTags()
    idx = tags.indexOf(tag)
    if idx < 0
      tags.push(tag)
      e.target.classList.add("selected")
    else
      tags.splice(idx, 1)
      e.target.classList.remove("selected")
    @setEditorTags(tags)
    @tagsEditor.focus()
