{$, View, EditorView} = require "atom"
utils = require "./utils"
path = require "path"
fs = require "fs-plus"

module.exports =
class NewPostView extends View
  previouslyFocusedElement: null

  @content: ->
    @div class: "md-writer md-writer-new-post overlay from-top", =>
      @label "Add New Post", class: "icon icon-file-add"
      @div =>
        @label "Directory", class: "message"
        @subview "pathEditor", new EditorView(mini: true)
        @label "Date", class: "message"
        @subview "dateEditor", new EditorView(mini: true)
        @label "Title", class: "message"
        @subview "titleEditor", new EditorView(mini: true)
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
    @pathEditor.setText(utils.getPostsDir(
      atom.config.get("md-writer.sitePostsDir")))

  createPost: () ->
    try
      post = @getFullPath()

      if fs.existsSync(post)
        @error.text("Post #{@getFullPath()} already exists!")
      else
        fs.writeFileSync(post, @generateFrontMatters())
        atom.workspaceView.open(post)
        @detach()
    catch error
      @error.text("#{error.message}")

  getFullPath: ->
    localDir = atom.config.get("md-writer.siteLocalDir")
    return path.join(localDir, @getPostPath())

  getPostPath: ->
    return path.join(@pathEditor.getText(), @getFileName())

  getFileName: ->
    date = @dateEditor.getText()
    title = @convertTitle(@titleEditor.getText())
    extension = atom.config.get("md-writer.fileExtension")
    return "#{date}-#{title}#{extension}"

  generateFrontMatters: ->
    """
---
layout: post
title: '#{@titleEditor.getText()}'
date: '#{@dateEditor.getText()} #{utils.getTimeStr()}'
---
    """

  convertTitle: (title) ->
    title.trim().toLowerCase().replace(/[^\w\s]|_/g, "").replace(/\s/g,"-")
