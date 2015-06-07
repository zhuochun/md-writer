{$, View, TextEditorView} = require "atom-space-pen-views"
config = require "./config"
utils = require "./utils"

module.exports =
class ManagePostTagsView extends View
  editor: null
  frontMatter: null
  tags: null
  previouslyFocusedElement: null

  @content: ->
    @div class: "markdown-writer markdown-writer-selection", =>
      @label "Manage Post Tags", class: "icon icon-tag"
      @p class: "error", outlet: "error"
      @subview "tagsEditor", new TextEditorView(mini: true)
      @ul class: "candidates", outlet: "candidates", =>
        @li "Loading..."

  initialize: ->
    @fetchTags()
    @candidates.on "click", "li", (e) => @appendTag(e)

    atom.commands.add @element,
      "core:confirm": => @updateFrontMatter()
      "core:cancel":  => @detach()

  updateFrontMatter: ->
    @frontMatter.tags = @getEditorTags()
    utils.updateFrontMatter(@editor, @frontMatter)
    @detach()

  display: ->
    @editor = atom.workspace.getActiveTextEditor()
    @panel ?= atom.workspace.addModalPanel(item: this, visible: false)
    @previouslyFocusedElement = $(document.activeElement)

    if utils.hasFrontMatter(@editor.getText())
      @setFrontMatter()
      @setEditorTags(@frontMatter.tags)
      @panel.show()
      @tagsEditor.focus()
    else
      @detach()

  detach: ->
    return unless @panel.isVisible()
    @panel.hide()
    @previouslyFocusedElement?.focus()
    super

  setFrontMatter: ->
    @frontMatter = utils.getFrontMatter(@editor.getText())

    if !@frontMatter.tags
      @frontMatter.tags = []
    else if typeof @frontMatter.tags == "string"
      @frontMatter.tags = [@frontMatter.tags]

  setEditorTags: (tags) ->
    @tagsEditor.setText(tags.join(","))

  getEditorTags: ->
    @tagsEditor.getText().split(/\s*,\s*/).filter((t) -> !!t.trim())

  fetchTags: ->
    uri = config.get("urlForTags")
    succeed = (body) =>
      @tags = body.tags.map((tag) -> name: tag)
      @rankTags(@tags, @editor.getText())
      @displayTags(@tags)
    error = (err) =>
      @error.text(err?.message || "Error fetching tags from '#{uri}'")
    utils.getJSON(uri, succeed, error)

  # rank tags based on the number of times they appear in content
  rankTags: (tags, content) ->
    tags.forEach (tag) ->
      tagRegex = /// #{utils.regexpEscape(tag.name)} ///ig
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
