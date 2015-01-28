{$, View, TextEditorView} = require "atom-space-pen-views"
config = require "./config"
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
        @subview "titleEditor", new TextEditorView(mini: true)
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
    localDir = config.get("siteLocalDir")
    return path.join(localDir, @getPostPath())

  getPostPath: ->
    draftsDir = config.get("siteDraftsDir")
    return path.join(draftsDir, @getFileName())

  getFileName: ->
    title = utils.dasherize(@titleEditor.getText() || "new draft")
    extension = config.get("fileExtension")
    return "#{title}#{extension}"

  getFrontMatter: ->
    layout: "post"
    published: false
    slug: utils.dasherize(@titleEditor.getText() || "new draft")
    title: @titleEditor.getText()
    date: "#{utils.getDateStr()} #{utils.getTimeStr()}"

  generateFrontMatter: (data) ->
    utils.template(config.get("frontMatter"), data)
