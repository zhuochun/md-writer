{$, View, TextEditorView} = require "atom-space-pen-views"
path = require "path"
fs = require "fs-plus"

config = require "../config"
utils = require "../utils"

module.exports =
class NewFileView extends View
  @fileType = "File" # override
  @pathConfig = "siteFilesDir" # override
  @fileNameConfig = "newFileFileName" # override

  @content: ->
    @div class: "markdown-writer", =>
      @label "Add New #{@fileType}", class: "icon icon-file-add"
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
    utils.setTabIndex([@titleEditor, @pathEditor, @dateEditor])

    @pathEditor.getModel().onDidChange => @updatePath()
    @dateEditor.getModel().onDidChange => @updatePath()
    @titleEditor.getModel().onDidChange => @updatePath()

    atom.commands.add @element,
      "core:confirm": => @createPost()
      "core:cancel": => @detach()

  display: ->
    @panel ?= atom.workspace.addModalPanel(item: this, visible: false)
    @previouslyFocusedElement = $(document.activeElement)
    @dateEditor.setText(utils.getDateStr())
    @pathEditor.setText(utils.dirTemplate(config.get(@constructor.pathConfig)))
    @panel.show()
    @titleEditor.focus()

  detach: ->
    if @panel.isVisible()
      @panel.hide()
      @previouslyFocusedElement?.focus()
    super

  createPost: ->
    try
      post = @getFullPath()

      if fs.existsSync(post)
        @error.text("File #{@getFullPath()} already exists!")
      else
        fs.writeFileSync(post, @generateFrontMatter(@getFrontMatter()))
        atom.workspace.open(post)
        @detach()
    catch error
      @error.text("#{error.message}")

  updatePath: ->
    @message.html """
    <b>Site Directory:</b> #{config.get("siteLocalDir") || utils.getProjectPath()}/<br/>
    <b>Create #{@constructor.fileType} At:</b> #{@getPostPath()}
    """

  getFullPath: -> path.join(config.get("siteLocalDir") || utils.getProjectPath(), @getPostPath())

  getPostPath: -> path.join(@pathEditor.getText(), @getFileName())

  getFileName: ->
    template = config.get(@constructor.fileNameConfig)
    info =
      title: @getTitleSlug()
      slug: @getTitleSlug()
      extension: config.get("fileExtension")
    utils.template(template, $.extend(info, @getDate()))

  getTitle: -> @titleEditor.getText() || "New #{@constructor.fileType}"

  getTitleSlug: -> utils.slugize(@getTitle(), config.get('slugSeparator'))

  getDate: -> utils.parseDateStr(@dateEditor.getText())

  getPublished: -> @constructor.fileType == 'Post'

  generateFrontMatter: (data) ->
    utils.template(config.get("frontMatter"), data)

  getFrontMatter: ->
    layout: "post"
    published: @getPublished()
    title: @getTitle()
    slug: @getTitleSlug()
    date: "#{@dateEditor.getText()} #{utils.getTimeStr()}"
    dateTime: @getDate()
