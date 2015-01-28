{$, View, TextEditorView} = require "atom-space-pen-views"
config = require "./config"
utils = require "./utils"
path = require "path"
fs = require "fs-plus"

module.exports =
class NewPostView extends View
  previouslyFocusedElement: null

  @content: ->
    @div class: "markdown-writer overlay from-top", =>
      @label "Add New Post", class: "icon icon-file-add"
      @div =>
        @label "Directory", class: "message"
        @subview "pathEditor", new TextEditorView(mini: true)
        @label "Date", class: "message"
        @subview "dateEditor", new TextEditorView(mini: true)
        @label "Title", class: "message"
        @subview "titleEditor", new TextEditorView(mini: true)
      @p class: "message", outlet: "message"
      @p class: "error", outlet: "error"

  initialize: ->
    @titleEditor.hiddenInput.on 'keyup', => @updatePath()
    @pathEditor.hiddenInput.on 'keyup', => @updatePath()
    @dateEditor.hiddenInput.on 'keyup', => @updatePath()

    @on "core:confirm", => @createPost()
    @on "core:cancel", => @detach()

  detach: ->
    return unless @hasParent()
    @previouslyFocusedElement?.focus()
    super

  updatePath: ->
    @message.text "Create Post: #{@getPostPath()}"

  display: ->
    @previouslyFocusedElement = $(':focus')
    atom.workspaceView.append(this)
    @titleEditor.focus()
    @dateEditor.setText(utils.getDateStr())
    @pathEditor.setText(utils.dirTemplate(config.get("sitePostsDir")))

  createPost: () ->
    try
      post = @getFullPath()

      if fs.existsSync(post)
        @error.text("Post #{@getFullPath()} already exists!")
      else
        fs.writeFileSync(post, @generateFrontMatter(@getFrontMatter()))
        atom.workspaceView.open(post)
        @detach()
    catch error
      @error.text("#{error.message}")

  getFullPath: -> path.join(config.get("siteLocalDir"), @getPostPath())

  getPostPath: -> path.join(@pathEditor.getText(), @getFileName())

  getFileName: ->
    template = config.get("newPostFileName")
    date = utils.parseDateStr(@dateEditor.getText())
    info =
      title: utils.dasherize(@titleEditor.getText() || "new post")
      extension: config.get("fileExtension")
    return utils.template(template, $.extend(info, date))

  getFrontMatter: ->
    layout: "post"
    published: true
    slug: utils.dasherize(@titleEditor.getText() || "new post")
    title: @titleEditor.getText()
    date: "#{@dateEditor.getText()} #{utils.getTimeStr()}"

  generateFrontMatter: (data) ->
    utils.template(config.get("frontMatter"), data)
