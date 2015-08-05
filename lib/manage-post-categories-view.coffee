{$, View, TextEditorView} = require "atom-space-pen-views"
FrontMatter = require "./models/front-matter"
config = require "./config"
utils = require "./utils"

module.exports =
class ManagePostCategoriesView extends View
  @content: ->
    @div class: "markdown-writer markdown-writer-selection", =>
      @label "Manage Post Categories", class: "icon icon-book"
      @p class: "error", outlet: "error"
      @subview "categoriesEditor", new TextEditorView(mini: true)
      @ul class: "candidates", outlet: "candidates", =>
        @li "Loading..."

  initialize: ->
    @fetchSiteCategories()
    @candidates.on "click", "li", (e) => @appendCategory(e)

    atom.commands.add @element,
      "core:confirm": => @saveFrontMatter()
      "core:cancel":  => @detach()

  display: ->
    @editor = atom.workspace.getActiveTextEditor()
    @panel ?= atom.workspace.addModalPanel(item: this, visible: false)
    @previouslyFocusedElement = $(document.activeElement)

    @frontMatter = new FrontMatter(@editor)
    return @detach if @frontMatter.isEmpty

    @frontMatter.normalizeField("categories")
    @setEditorCategories(@frontMatter.getField("categories"))
    @panel.show()
    @categoriesEditor.focus()

  detach: ->
    return unless @panel.isVisible()
    @panel.hide()
    @previouslyFocusedElement?.focus()
    super

  saveFrontMatter: ->
    @frontMatter.setField("categories", @getEditorCategories())
    @frontMatter.save()
    @detach()

  setEditorCategories: (categories) ->
    @categoriesEditor.setText(categories.join(","))

  getEditorCategories: ->
    @categoriesEditor.getText().split(/\s*,\s*/).filter((c) -> !!c.trim())

  fetchSiteCategories: ->
    uri = config.get("urlForCategories")
    succeed = (body) =>
      @displaySiteCategories(body.categories || [])
    error = (err) =>
      @error.text(err?.message || "Error fetching categories from '#{uri}'")
    utils.getJSON(uri, succeed, error)

  displaySiteCategories: (siteCategories) ->
    categories = @frontMatter.getField("categories")
    tagElems = siteCategories.map (tag) ->
      if categories.indexOf(tag) < 0
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
