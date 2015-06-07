{$, View, TextEditorView} = require "atom-space-pen-views"
config = require "./config"
utils = require "./utils"

module.exports =
class ManagePostCategoriesView extends View
  editor: null
  frontMatter: null
  categories: null
  previouslyFocusedElement: null

  @content: ->
    @div class: "markdown-writer markdown-writer-selection", =>
      @label "Manage Post Categories", class: "icon icon-book"
      @p class: "error", outlet: "error"
      @subview "categoriesEditor", new TextEditorView(mini: true)
      @ul class: "candidates", outlet: "candidates", =>
        @li "Loading..."

  initialize: ->
    @fetchCategories()
    @candidates.on "click", "li", (e) => @appendCategory(e)

    atom.commands.add @element,
      "core:confirm": => @updateFrontMatter()
      "core:cancel":  => @detach()

  updateFrontMatter: ->
    @frontMatter.categories = @getEditorCategories()
    utils.updateFrontMatter(@editor, @frontMatter)
    @detach()

  display: ->
    @editor = atom.workspace.getActiveTextEditor()
    @panel ?= atom.workspace.addModalPanel(item: this, visible: false)
    @previouslyFocusedElement = $(document.activeElement)

    if utils.hasFrontMatter(@editor.getText())
      @setFrontMatter()
      @setEditorCategories(@frontMatter.categories)
      @panel.show()
      @categoriesEditor.focus()
    else
      @detach()

  detach: ->
    return unless @panel.isVisible()
    @panel.hide()
    @previouslyFocusedElement?.focus()
    super

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
      @error.text(err?.message || "Error fetching categories from '#{uri}'")
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
