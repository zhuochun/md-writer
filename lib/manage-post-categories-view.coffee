{$, View, TextEditorView} = require "atom-space-pen-views"
config = require "./config"
utils = require "./utils"
request = require "request"

module.exports =
class ManagePostCategoriesView extends View
  editor: null
  frontMatter: null
  categories: null
  previouslyFocusedElement: null

  @content: ->
    @div class: "markdown-writer markdown-writer-selection overlay from-top", =>
      @label "Manage Post Categories", class: "icon icon-book"
      @p class: "error", outlet: "error"
      @subview "categoriesEditor", new TextEditorView(mini: true)
      @ul class: "candidates", outlet: "candidates"

  initialize: ->
    @fetchCategories()
    @candidates.on "click", "li", (e) => @appendCategory(e)
    @on "core:confirm", => @updateFrontMatter()
    @on "core:cancel", => @detach()

  updateFrontMatter: ->
    @frontMatter.categories = @getEditorCategories()
    @editor.buffer.scan utils.frontMatterRegex, (match) =>
      noLeadingFence = !match.matchText.startsWith("---")
      match.replace utils.getFrontMatterText(@frontMatter, noLeadingFence)
    @detach()

  detach: ->
    return unless @hasParent()
    @previouslyFocusedElement?.focus()
    super

  display: ->
    @previouslyFocusedElement = $(':focus')
    @editor = atom.workspace.getActiveTextEditor()

    if @isValidMarkdown(@editor.getText())
      @setFrontMatter()
      @setEditorCategories(@frontMatter.categories)
      atom.workspaceView.append(this)
      @categoriesEditor.focus()
    else
      @detach()

  isValidMarkdown: (content) ->
    return !!content and utils.hasFrontMatter(content)

  setFrontMatter: ->
    @frontMatter = utils.getFrontMatter(@editor.getText())
    if !@frontMatter.categories
      @frontMatter.categories = []
    else if typeof @frontMatter.categories == "string"
      @frontMatter.categories = [@frontMatter.categories]

  setEditorCategories: (categories) ->
    @categoriesEditor.setText(categories.join(","))

  getEditorCategories: ->
    @categoriesEditor.getText().split(/\s*,\s*/).filter((c) -> !!c.trim())

  fetchCategories: ->
    uri = config.get("urlForCategories")
    succeed = (body) =>
      @categories = body.categories
      @displayCategories(@categories)
    error = (err) =>
      @error.text(err?.message || "Categories are not available")
    utils.getJSON(uri, succeed, error)

  displayCategories: (categories) ->
    tagElems = categories.map (tag) =>
      if @frontMatter.categories.indexOf(tag) < 0
        "<li>#{tag}</li>"
      else
        "<li class='selected'>#{tag}</li>"
    @candidates.empty().append(tagElems.join(""))

  appendCategory: (e) ->
    category = e.target.textContent
    categories = @getEditorCategories()
    idx = categories.indexOf(category)
    if idx < 0
      categories.push(category)
      e.target.classList.add("selected")
    else
      categories.splice(idx, 1)
      e.target.classList.remove("selected")
    @setEditorCategories(categories)
    @categoriesEditor.focus()
