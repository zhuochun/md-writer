{CompositeDisposable} = require 'atom'
{$, View, TextEditorView} = require "atom-space-pen-views"
path = require "path"
fs = require "fs-plus"
clipboard = require 'clipboard'

config = require "../config"
utils = require "../utils"
templateHelper = require "../helpers/template-helper"
qiniu = require "../helpers/qiniu-uploader"

module.exports =
class InsertImageClipboardView extends View
  @content: ->
    @div class: "markdown-writer markdown-writer-dialog", =>
      @label "Insert Image from Clipboard", class: "icon icon-clippy"
      @div =>
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
      @div class: "dialog-row", =>
        @label for: "markdown-writer-copy-image-checkbox", =>
          @input id: "markdown-writer-copy-image-checkbox",
            type:"checkbox", outlet: "copyImageCheckbox"
        @span "Save Image To: Missing Title (alt)", class: "side-label", outlet: "copyImageMessage"
      @div class: "image-container", =>
        @img outlet: 'imagePreview'

  initialize: ->
    utils.setTabIndex([@titleEditor, @widthEditor, @heightEditor, @alignEditor])

    @titleEditor.on "keyup", => @updateCopyImageDest()

    @disposables = new CompositeDisposable()
    @disposables.add(atom.commands.add(
      @element, {
        "core:confirm": => @onConfirm(),
        "core:cancel":  => @detach()
      }))

  onConfirm: ->
    callback = (src) =>
      @editor.transact => @insertImageTag(src)
      @detach()

    pngBody = if @clipboardImage.toPNG then @clipboardImage.toPNG() else @clipboardImage.toPng()
    
    if !@copyImageCheckbox.hasClass('hidden') && @copyImageCheckbox.prop("checked")
      title = @titleEditor.getText().trim()
      return unless title
      @copyImage(pngBody, title, callback)
    else
      @uploadImage(pngBody, title, callback)

  display: (e) ->
    # read image from clipboard
    @clipboardImage = clipboard.readImage()
    # skip and return
    if @clipboardImage.isEmpty()
      e.abortKeyBinding()
      return
    # display view
    @panel ?= atom.workspace.addModalPanel(item: this, visible: false)
    @previouslyFocusedElement = $(document.activeElement)
    @editor = atom.workspace.getActiveTextEditor()
    @frontMatter = templateHelper.getEditor(@editor)
    @dateTime = templateHelper.getDateTime()
    # initialize view
    @setImageContext()
    @displayImagePreview()
    # show view
    @panel.show()
    @titleEditor.focus()

  detach: ->
    if @panel.isVisible()
      @panel.hide()
      @previouslyFocusedElement?.focus()

    super()

  detached: ->
    @disposables?.dispose()
    @disposables = null

  setImageContext: ->
    { width, height } = @clipboardImage.getSize()
    @widthEditor.setText("" + width)
    @heightEditor.setText("" + height)

    position = if width > 300 then "center" else "right"
    @alignEditor.setText(position)

  updateCopyImageDest: ->
    title = @titleEditor.getText().trim()
    if title
      destFile = @getCopiedImageDestPath(title)
      @copyImageMessage.text("Save Image To: #{destFile}")
    else
      @copyImageMessage.text("Save Image To: Missing Title (alt)")

  displayImagePreview: ->
    @imagePreview.attr("src", @clipboardImage.toDataURL())
    @imagePreview.error -> console.log("Error: Failed to Load Image.")

  insertImageTag: (imgSource) ->
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

    @editor.insertText(text)

  uploadImage: (pngBody, title, callback) ->
    errorConfirm= (errorMessage) =>
      atom.confirm
        message: "[Markdown Writer] Error!"
        detailedMessage: "Uploading Image:\n#{errorMessage}"
        buttons: ['OK']
    try
      qiniu.upload(pngBody, title, ".png",  @dateTime,
        (data) =>
          if data.success
            callback(data.src)
          else
            errorConfirm(data.message)
      )
    catch error
      errorConfirm(error.message)

  copyImage: (pngBody, title, callback) ->
    try
      destFile = @getCopiedImageDestPath(title)

      if fs.existsSync(destFile)
        confirmation = atom.confirm
          message: "File already exists!"
          detailedMessage: "Another file already exists at:\n#{destFile}\nDo you want to overwrite it?"
          buttons: ["No", "Yes"]
        # abort overwrite and edit title
        if confirmation == 0
          @titleEditor.focus()
          return

      fs.writeFileSync(destFile, pngBody)
      # write dest path to clipboard
      clipboard.writeText(destFile)
      # insertImageTag
      callback(destFile)
    catch error
      atom.confirm
        message: "[Markdown Writer] Error!"
        detailedMessage: "Saving Image:\n#{error.message}"
        buttons: ['OK']

  # get user's site local directory
  siteLocalDir: -> utils.getSitePath(config.get("siteLocalDir"), @editor?.getPath())
  # get user's site images directory
  siteImagesDir: -> templateHelper.create("siteImagesDir", @frontMatter, @dateTime)
  # get current open file directory
  currentFileDir: -> path.dirname(@editor.getPath() || "")
  # check the file is in the site directory
  isInSiteDir: (file) -> file && file.startsWith(@siteLocalDir())

  # get copy image destination file path
  getCopiedImageDestPath: (title) ->
    extension = ".png"
    title = (new Date()).toISOString().replace(/[:\.]/g, "-") unless title
    title = utils.slugize(title, config.get('slugSeparator'))
    filename = "#{title}#{extension}"
    path.join(@siteLocalDir(), @siteImagesDir(), filename)

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
