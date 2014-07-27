{$, View, EditorView} = require "atom"
utils = require "./utils"
request = require "request"

### TODO
- merge categories view and tags view to front matter view
###

module.exports =
class ManagePostCategoriesView extends View
  editor: null
  frontMatter: null
  categories: null
  previouslyFocusedElement: null

  @content: ->
    @div class: "md-writer md-writer-selection overlay from-top", =>
      @label "Manage Post Categories", class: "icon icon-book"
      @p class: "error", outlet: "error"
      @subview "categoriesEditor", new EditorView(mini: true)
      @ul class: "candidates", outlet: "candidates"

  initialize: ->
    @candidates.on "click", "li", (e) => @appendCategory(e)
    @on "core:confirm", => @updateFrontMatter()
    @on "core:cancel", => @detach()

  updateFrontMatter: ->
    @frontMatter.categories = @getEditorCategories()
    @editor.buffer.scan utils.frontMatterRegex, (match) =>
      match.replace utils.getFrontMatterText(@frontMatter)
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
      @setEditorCategories(@frontMatter.categories)
      @fetchCategories()
      atom.workspaceView.append(this)
      @categoriesEditor.focus()
    else
      @detach()

  isValidMarkdown: (content) ->
    return !!content and utils.hasFrontMatter(content)

  setFrontMatter: ->
    @frontMatter = utils.getFrontMatter(@editor.getText())
    @frontMatter.categories = [] unless @frontMatter.categories

  setEditorCategories: (categories) ->
    @categoriesEditor.setText(categories.join(","))

  getEditorCategories: ->
    @categoriesEditor.getText().split(/\s*,\s*/).filter((c) -> !!c.trim())

  fetchCategories: ->
    uri = atom.config.get("md-writer.urlForCategories")
    succeed = (body) =>
      @categories = body.categories
      @displayCategories(@categories)
    error = (err) => @error.text(err.message)
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
