{$, View, EditorView} = require "atom"
utils = require "./utils"
path = require "path"
fs = require "fs-plus"

module.exports =
class NewDraftView extends View
  previouslyFocusedElement: null

  @content: ->
    @div class: "markdown-writer overlay from-top", =>
      @label "Add New Draft", class: "icon icon-file-add"
      @div =>
        @label "Title", class: "message"
        @subview "titleEditor", new EditorView(mini: true)
      @p class: "message", outlet: "message"
      @p class: "error", outlet: "error"

  initialize: ->
    @titleEditor.hiddenInput.on 'keyup', => @updatePath()
    @on "core:confirm", => @createPost()
    @on "core:cancel", => @detach()

  detach: ->
    return unless @hasParent()
    @previouslyFocusedElement?.focus()
    super

  updatePath: ->
    @message.text "Create Draft: #{@getPostPath()}"

  display: ->
    @previouslyFocusedElement = $(':focus')
    atom.workspaceView.append(this)
    @titleEditor.focus()

  createPost: () ->
    try
      post = @getFullPath()

      if fs.existsSync(post)
        @error.text("Draft #{@getFullPath()} already exists!")
      else
        fs.writeFileSync(post, @generateFrontMatter(@getFrontMatter()))
        atom.workspaceView.open(post)
        @detach()
    catch error
      @error.text("#{error.message}")

  getFullPath: ->
    localDir = atom.config.get("markdown-writer.siteLocalDir")
    return path.join(localDir, @getPostPath())

  getPostPath: ->
    draftsDir = atom.config.get("markdown-writer.siteDraftsDir")
    return path.join(draftsDir, @getFileName())

  getFileName: ->
    title = utils.dasherize(@titleEditor.getText() || "new draft")
    extension = atom.config.get("markdown-writer.fileExtension")
    return "#{title}#{extension}"

  getFrontMatter: ->
    layout: "post"
    published: false
    title: @titleEditor.getText()
    date: "#{utils.getDateStr()} #{utils.getTimeStr()}"

  generateFrontMatter: (data) ->
    frontMatter = atom.config.get("markdown-writer.frontMatter") || """
  ---
  layout: <layout>
  title: "<title>"
  date: "<date>"
  ---
    """

    return utils.template(frontMatter, data)
