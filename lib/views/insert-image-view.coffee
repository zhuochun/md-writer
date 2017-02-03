{CompositeDisposable} = require 'atom'
{$, View, TextEditorView} = require "atom-space-pen-views"
path = require "path"
fs = require "fs-plus"
remote = require "remote"
dialog = remote.dialog || remote.require "dialog"

config = require "../config"
utils = require "../utils"
templateHelper = require "../helpers/template-helper"

lastInsertImageDir = null # remember last inserted image directory

module.exports =
class InsertImageView extends View
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
      @div outlet: "copyImagePanel", class: "hidden dialog-row", =>
        @label for: "markdown-writer-copy-image-checkbox", =>
          @input id: "markdown-writer-copy-image-checkbox",
            type:"checkbox", outlet: "copyImageCheckbox"
          @span "Copy Image to Site Image Directory", class: "side-label", outlet: "copyImageMessage"
      @div class: "image-container", =>
        @img outlet: 'imagePreview'

  initialize: ->
    utils.setTabIndex([@imageEditor, @openImageButton, @titleEditor,
      @widthEditor, @heightEditor, @alignEditor, @copyImageCheckbox])

    @imageEditor.on "blur", =>
      file = @imageEditor.getText().trim()
      @updateImageSource(file)
      @updateCopyImageDest(file)
    @titleEditor.on "blur", =>
      @updateCopyImageDest(@imageEditor.getText().trim())
    @openImageButton.on "click", => @openImageDialog()

    @disposables = new CompositeDisposable()
    @disposables.add(atom.commands.add(
      @element, {
        "core:confirm": => @onConfirm(),
        "core:cancel":  => @detach()
      }))

  onConfirm: ->
    imgSource = @imageEditor.getText().trim()
    return unless imgSource

    callback = =>
      @editor.transact => @insertImageTag()
      @detach()

    if !@copyImageCheckbox.hasClass('hidden') && @copyImageCheckbox.prop("checked")
      @copyImage(@resolveImagePath(imgSource), callback)
    else
      callback()

  display: ->
    @panel ?= atom.workspace.addModalPanel(item: this, visible: false)
    @previouslyFocusedElement = $(document.activeElement)
    @editor = atom.workspace.getActiveTextEditor()
    @frontMatter = templateHelper.getEditor(@editor)
    @dateTime = templateHelper.getDateTime()
    @setFieldsFromSelection()
    @panel.show()
    @imageEditor.focus()

  detach: ->
    if @panel.isVisible()
      @panel.hide()
      @previouslyFocusedElement?.focus()
    super

  detached: ->
    @disposables?.dispose()
    @disposables = null

  setFieldsFromSelection: ->
    @range = utils.getTextBufferRange(@editor, "link")
    selection = @editor.getTextInRange(@range)
    return unless selection

    if utils.isImage(selection)
      img = utils.parseImage(selection)
    else if utils.isImageTag(selection)
      img = utils.parseImageTag(selection)
    else
      img = { alt: selection }

    @titleEditor.setText(img.alt || "")
    @widthEditor.setText(img.width || "")
    @heightEditor.setText(img.height || "")
    @imageEditor.setText(img.src || "")

    @updateImageSource(img.src)

  openImageDialog: ->
    files = dialog.showOpenDialog
      properties: ['openFile']
      defaultPath: lastInsertImageDir || @siteLocalDir()
    return unless files && files.length > 0

    @imageEditor.setText(files[0])
    @updateImageSource(files[0])

    lastInsertImageDir = path.dirname(files[0]) unless utils.isUrl(files[0])
    @titleEditor.focus()

  updateImageSource: (file) ->
    return unless file
    @displayImagePreview(file)

    if utils.isUrl(file) || @isInSiteDir(@resolveImagePath(file))
      @copyImagePanel.addClass("hidden")
    else
      @copyImagePanel.removeClass("hidden")

  updateCopyImageDest: (file) ->
    return unless file
    destFile = @copyImageDestPath(file, @titleEditor.getText())
    @copyImageMessage.text("Copy Image to #{destFile}")

  displayImagePreview: (file) ->
    return if @imageOnPreview == file

    if utils.isImageFile(file)
      @message.text("Opening Image Preview ...")
      @imagePreview.attr("src", @resolveImagePath(file))
      @imagePreview.load =>
        @message.text("")
        @setImageContext()
      @imagePreview.error =>
        @message.text("Error: Failed to Load Image.")
        @imagePreview.attr("src", "")
    else
      @message.text("Error: Invalid Image File.") if file
      @imagePreview.attr("src", "")
      @widthEditor.setText("")
      @heightEditor.setText("")
      @alignEditor.setText("")

    @imageOnPreview = file # cache preview image src

  setImageContext: ->
    { naturalWidth, naturalHeight } = @imagePreview.context
    @widthEditor.setText("" + naturalWidth)
    @heightEditor.setText("" + naturalHeight)

    position = if naturalWidth > 300 then "center" else "right"
    @alignEditor.setText(position)

  insertImageTag: ->
    imgSource = @imageEditor.getText().trim()
    img =
      rawSrc: imgSource,
      src: @generateImageSrc(imgSource)
      relativeFileSrc: @generateRelativeImageSrc(imgSource, @currentFileDir())
      relativeSiteSrc: @generateRelativeImageSrc(imgSource, @siteLocalDir())
      alt: @titleEditor.getText()
      width: @widthEditor.getText()
      height: @heightEditor.getText()
      align: @alignEditor.getText()

    # insert image tag when img.src exists, otherwise consider the image was removed
    if img.src
      text = templateHelper.create("imageTag", @frontMatter, @dateTime, img)
    else
      text = img.alt

    @editor.setTextInBufferRange(@range, text)

  copyImage: (file, callback) ->
    return callback() if utils.isUrl(file) || !fs.existsSync(file)

    try
      destFile = @copyImageDestPath(file, @titleEditor.getText())
      performWrite = true

      if fs.existsSync(destFile)
        confirmation = atom.confirm
          message: "File already exists!"
          detailedMessage: "Another file already exists at:\n#{destFile}\nDo you want to overwrite it?"
          buttons: ["No", "Yes"]
        performWrite = (confirmation == 1)

      if performWrite
        fs.copy file, destFile, =>
          @imageEditor.setText(destFile)
          callback()
    catch error
      atom.confirm
        message: "[Markdown Writer] Error!"
        detailedMessage: "Copy Image:\n#{error.message}"
        buttons: ['OK']

  # get user's site local directory
  siteLocalDir: -> utils.getSitePath(config.get("siteLocalDir"))

  # get user's site images directory
  siteImagesDir: -> templateHelper.create("siteImagesDir", @frontMatter, @dateTime)

  # get current open file directory
  currentFileDir: -> path.dirname(@editor.getPath() || "")

  # check the file is in the site directory
  isInSiteDir: (file) -> file && file.startsWith(@siteLocalDir())

  # get copy image destination file path
  copyImageDestPath: (file, title) ->
    filename = path.basename(file)

    if config.get("renameImageOnCopy") && title
      extension = path.extname(file)
      title = utils.slugize(title, config.get('slugSeparator'))
      filename = "#{title}#{extension}"

    path.join(@siteLocalDir(), @siteImagesDir(), filename)

  # try to resolve file to a valid src that could be displayed
  resolveImagePath: (file) ->
    return "" unless file
    return file if utils.isUrl(file) || fs.existsSync(file)
    absolutePath = path.join(@siteLocalDir(), file)
    return absolutePath if fs.existsSync(absolutePath)
    relativePath = path.join(@currentFileDir(), file)
    return relativePath if fs.existsSync(relativePath)
    return file # fallback to not resolve

  # generate a src that is used in markdown file based on user configuration or file location
  generateImageSrc: (file) ->
    utils.normalizeFilePath(@_generateImageSrc(file))

  _generateImageSrc: (file) ->
    return "" unless file
    return file if utils.isUrl(file)
    return path.relative(@currentFileDir(), file) if config.get('relativeImagePath')
    return path.relative(@siteLocalDir(), file) if @isInSiteDir(file)
    return path.join("/", @siteImagesDir(), path.basename(file))

  # generate a relative src from the base path or from user's home directory
  generateRelativeImageSrc: (file, basePath) ->
    utils.normalizeFilePath(@_generateRelativeImageSrc(file, basePath))

  _generateRelativeImageSrc: (file, basePath) ->
    return "" unless file
    return file if utils.isUrl(file)
    return path.relative(basePath || "~", file)
