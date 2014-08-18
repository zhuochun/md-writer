{$, View, EditorView} = require "atom"
utils = require "./utils"
remote = require "remote"
dialog = remote.require "dialog"
path = require "path"
fs = require "fs-plus"

imageExtensions = [".jpg", ".png", ".gif"]

module.exports =
class InsertImageView extends View
  imageOnPreview: ""
  editor: null
  previouslyFocusedElement: null

  @content: ->
    @div class: "markdown-writer markdown-writer-dialog overlay from-top", =>
      @label "Insert Image", class: "icon icon-device-camera"
      @div =>
        @label "Image Path", class: "message"
        @subview "imgEditor", new EditorView(mini: true)
        @div class: "dialog-row", =>
          @button "Choose Local Image", outlet: "openImg", class: "btn"
          @label outlet: "message", class: "side-label"
        @label "Title (Alt)", class: "message"
        @subview "titleEditor", new EditorView(mini: true)
        @label "Width", class: "message"
        @subview "widthEditor", new EditorView(mini: true)
        @label "Height", class: "message"
        @subview "heightEditor", new EditorView(mini: true)
      @div class: "image-container", =>
        @img outlet: 'imagePreview'

  initialize: ->
    @handleEvents()
    @on "core:confirm", => @onConfirm()
    @on "core:cancel", => @detach()

  handleEvents: ->
    @imgEditor.hiddenInput.on "focusout", =>
      @displayImagePreview(@imgEditor.getText().trim())
    @openImg.on "click", => @openImageDialog()

  onConfirm: ->
    img =
      src: @generateImageUrl(@imgEditor.getText().trim())
      alt: @titleEditor.getText()
      width: @widthEditor.getText()
      height: @heightEditor.getText()
    text = if img.src then @generateImageTag(img) else img.alt
    @editor.insertText(text)
    @detach()

  detach: ->
    return unless @hasParent()
    @previouslyFocusedElement?.focus()
    super

  display: ->
    @previouslyFocusedElement = $(':focus')
    @editor = atom.workspace.getActiveEditor()
    atom.workspaceView.append(this)
    @setFieldsFromSelection()
    @imgEditor.focus()

  setFieldsFromSelection: ->
    selection = @editor.getSelectedText()
    if utils.isImage(selection)
      img = utils.parseImage(selection)
      @imgEditor.setText(img.src)
      @titleEditor.setText(img.alt)
      @displayImagePreview(img.src)
    else if utils.isRawImage(selection)
      img = utils.parseRawImage(selection)
      @imgEditor.setText(img.src)
      @titleEditor.setText(img.alt)
      @widthEditor.setText(img.width || "")
      @heightEditor.setText(img.height || "")
      @displayImagePreview(img.src)
    else
      @titleEditor.setText(selection)

  displayImagePreview: (file) ->
    return if @imageOnPreview == file

    if @isValidImageFile(file)
      @imageOnPreview = file
      @message.text("Opening Image Preview ...")
      @imagePreview.attr("src", file)
      @imagePreview.load =>
        @message.text("")
        @widthEditor.setText("" + @imagePreview.context.naturalWidth)
        @heightEditor.setText("" + @imagePreview.context.naturalHeight)
      @imagePreview.error =>
        @message.text("Error: Failed to Load Image.")
    else
      @message.text("Error: Invalid Image File.") if file
      @imagePreview.attr("src", "")
      @widthEditor.setText("")
      @heightEditor.setText("")

  openImageDialog: ->
    files = dialog.showOpenDialog
      properties: ['openFile']
      defaultPath: atom.project.getPath()
    return unless files
    file = files[0]
    @imgEditor.setText(file)
    @displayImagePreview(file)
    @titleEditor.focus()

  isValidImageFile: (file) ->
    path.extname(file).toLowerCase() in imageExtensions

  generateImageUrl: (file) ->
    return file if utils.isUrl(file)

    localDir = atom.project.getPath()
    if file.startsWith(localDir) # resolve relative to root of site
      return file.replace(localDir, "").replace(/\\/g, "/")
    else
      template = atom.config.get("markdown-writer.siteImageUrl") || ""
      return utils.dirTemplate(template) + path.basename(file)

  generateImageTag: (data) ->
    template = atom.config.get("markdown-writer.imageTag") || "![<alt>](<src>)"
    return utils.template(template, data)
