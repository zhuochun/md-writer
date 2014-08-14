{$, View, EditorView} = require "atom"
utils = require "./utils"
remote = require "remote"
dialog = remote.require "dialog"
path = require "path"
fs = require "fs-plus"

imageExtensions = [".jpg", ".png", ".gif", ".bmp"]

module.exports =
class InsertImageView extends View
  imageOnPreview: null
  editor: null
  previouslyFocusedElement: null

  @content: ->
    @div class: "markdown-writer markdown-writer-dialog overlay from-top", =>
      @label "Insert Image", class: "icon icon-link"
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
      @displayImagePreview(@imgEditor.getText())
    @openImg.on "click", => @openImageDialog()

  onConfirm: ->
    img =
      src: @imgEditor.getText()
      alt: @titleEditor.getText()
      width: @widthEditor.getText()
      height: @heightEditor.getText()

    @editor.insertText(@generateImageTag(img))
    @detach()

  detach: ->
    return unless @hasParent()
    @previouslyFocusedElement?.focus()
    super

  display: ->
    @previouslyFocusedElement = $(':focus')
    @editor = atom.workspace.getActiveEditor()
    atom.workspaceView.append(this)
    @titleEditor.setText(@editor.getSelectedText())
    @imgEditor.focus()

  displayImagePreview: (file) ->
    return unless file and file.trim()
    return if @imageOnPreview == file

    if @isValidImageFile(file)
      @imageOnPreview = file
      @message.text("Open Preview ...")
      @imagePreview.attr("src", file)
      @imagePreview.load =>
        @message.text("")
        @widthEditor.setText("" + @imagePreview.context.naturalWidth)
        @heightEditor.setText("" + @imagePreview.context.naturalHeight)
    else
      @message.text("Error: Invalid Image File.")
      @imagePreview.attr("src", "")
      @widthEditor.setText("")
      @heightEditor.setText("")

  openImageDialog: ->
    files = dialog.showOpenDialog(properties: ['openFile'])
    return unless files
    file = files[0]
    @imgEditor.setText(file)
    @displayImagePreview(file)

  isValidImageFile: (file) ->
    path.extname(file).toLowerCase() in imageExtensions

  generateImageTag: (data) ->
    template = atom.config.get("markdown-writer.imageTag") || "![<alt>](<src>)"
    return utils.template(template, data)
