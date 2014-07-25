{$, View, EditorView} = require "atom"
utils = require "./utils"
request = require "request"

# TODO merge categories view and tags view to front matter

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
      @setCategoriesInFrontMatter()
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

  setCategoriesInFrontMatter: ->
    @categoriesEditor.setText(@frontMatter.categories.join(","))

  fetchCategories: ->
    uri = atom.config.get("md-writer.urlForCategories")
    data = uri: uri, json: true, encoding: 'utf-8', gzip: true
    request data, (error, response, body) =>
      if !error and response.statusCode == 200
        @categories = body.categories
        @displayCategories(@categories)
      else
        @error.text("Error accessing the categories!")

  displayCategories: (categories) ->
    tagElems = categories.map (tag) =>
      if @frontMatter.categories.indexOf(tag) < 0
        "<li>#{tag}</li>"
      else
        "<li class='selected'>#{tag}</li>"
    @candidates.append(tagElems.join(""))

  appendCategory: (e) ->
    tag = e.target.textContent
    idx = @frontMatter.categories.indexOf(tag)
    if idx < 0
      @frontMatter.categories.push(tag)
      e.target.classList.add("selected")
    else
      @frontMatter.categories.splice(idx, 1)
      e.target.classList.remove("selected")
    @setCategoriesInFrontMatter()
    @categoriesEditor.focus()
