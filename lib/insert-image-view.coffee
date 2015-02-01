{$, View, TextEditorView} = require "atom-space-pen-views"
config = require "./config"
utils = require "./utils"
remote = require "remote"
dialog = remote.require "dialog"
path = require "path"
fs = require "fs-plus"

imageExtensions = [".jpg", ".jpeg", ".png", ".gif", ".ico"]

module.exports =
class InsertImageView extends View
  imageOnPreview: ""
  editor: null
  previouslyFocusedElement: null

  @content: ->
    @div class: "markdown-writer markdown-writer-dialog", =>
      @label "Insert Image", class: "icon icon-device-camera"
      @div =>
        @label "Image Path (src)", class: "message"
        @subview "imageEditor", new TextEditorView(mini: true)
        @div class: "dialog-row", =>
          @button "Choose Local Image", outlet: "openImageButton", class: "btn"
          @label outlet: "message", class: "side-label"
        @label "Title (alt)", class: "message"
        @subview "titleEditor", new TextEditorView(mini: true)
        @div class: "col-1", =>
          @label "Width (px)", class: "message"
          @subview "widthEditor", new TextEditorView(mini: true)
        @div class: "col-1", =>
          @label "Height (px)", class: "message"
          @subview "heightEditor", new TextEditorView(mini: true)
        @div class: "col-2", =>
          @label "Alignment", class: "message"
          @subview "alignEditor", new TextEditorView(mini: true)
      @div class: "image-container", =>
        @img outlet: 'imagePreview'

  initialize: ->
    @imageEditor.on "blur", =>
      @displayImagePreview(@imageEditor.getText().trim())
    @openImageButton.on "click", => @openImageDialog()

    atom.commands.add @element,
      "core:confirm": => @onConfirm()
      "core:cancel":  => @detach()

  onConfirm: ->
    img =
      src: @generateImageUrl(@imageEditor.getText().trim())
      alt: @titleEditor.getText()
      width: @widthEditor.getText()
      height: @heightEditor.getText()
      align: @alignEditor.getText()
      slug: utils.getTitleSlug(@editor.getPath())
      site: config.get("siteUrl")
    text = if img.src then @generateImageTag(img) else img.alt
    @editor.insertText(text)
    @detach()

  display: ->
    @panel ?= atom.workspace.addModalPanel(item: this, visible: false)
    @previouslyFocusedElement = $(document.activeElement)
    @editor = atom.workspace.getActiveTextEditor()
    @setFieldsFromSelection()
    @panel.show()
    @imageEditor.focus()

  detach: ->
    return unless @panel.isVisible()
    @panel.hide()
    @previouslyFocusedElement?.focus()
    super

  setFieldsFromSelection: ->
    selection = @editor.getSelectedText()
    if utils.isImage(selection)
      img = utils.parseImage(selection)
      @imageEditor.setText(img.src)
      @titleEditor.setText(img.alt)
      @displayImagePreview(img.src)
    else if utils.isRawImage(selection)
      img = utils.parseRawImage(selection)
      @imageEditor.setText(img.src)
      @titleEditor.setText(img.alt)
      @widthEditor.setText(img.width || "")
      @heightEditor.setText(img.height || "")
      @displayImagePreview(img.src)
    else
      @titleEditor.setText(selection)

  openImageDialog: ->
    files = dialog.showOpenDialog
      properties: ['openFile']
      defaultPath: atom.project.getPaths()[0]
    return unless files
    @imageEditor.setText(files[0])
    @displayImagePreview(files[0])
    @titleEditor.focus()

  displayImagePreview: (file) ->
    return if @imageOnPreview == file

    if @isValidImageFile(file)
      @imageOnPreview = file
      @message.text("Opening Image Preview ...")
      @imagePreview.attr("src", @resolveImageUrl(file))
      @imagePreview.load =>
        @message.text("")
        { naturalWidth, naturalHeight } = @imagePreview.context
        @widthEditor.setText("" + naturalWidth)
        @heightEditor.setText("" + naturalHeight)
        position = if naturalWidth > 300 then "center" else "right"
        @alignEditor.setText(position)
      @imagePreview.error =>
        @message.text("Error: Failed to Load Image.")
    else
      @message.text("Error: Invalid Image File.") if file
      @imagePreview.attr("src", "")
      @widthEditor.setText("")
      @heightEditor.setText("")
      @alignEditor.setText("")

  isValidImageFile: (file) ->
    path.extname(file).toLowerCase() in imageExtensions

  resolveImageUrl: (file) ->
    if utils.isUrl(file)
      file
    else if fs.existsSync(file)
      file
    else
      "#{atom.project.getPaths()[0]}#{file}"

  generateImageUrl: (file) ->
    return file if utils.isUrl(file)

    localDir = atom.project.getPaths()[0]
    if file.startsWith(localDir) # resolve relative to root of site
      file.replace(localDir, "").replace(/\\/g, "/")
    else
      utils.dirTemplate(config.get("siteImageUrl")) + path.basename(file)

  generateImageTag: (data) ->
    utils.template(config.get("imageTag"), data)
