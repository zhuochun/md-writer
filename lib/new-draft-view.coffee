{$, View, EditorView} = require "atom"
utils = require "./utils"
path = require "path"
fs = require "fs-plus"

module.exports =
class NewDraftView extends View
  previouslyFocusedElement: null

  @content: ->
    @div class: "md-writer overlay from-top", =>
      @label "Add New Draft", class: "icon icon-file-add"
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
        fs.writeFileSync(post, @generateFrontMatters())

        rootDir = atom.config.get("md-writer.siteLocalDir")
        if atom.project.path == rootDir
          atom.workspaceView.open(post)
        else
          atom.open(pathsToOpen: [post])

        @detach()
    catch error
      @error.text("#{error.message}")

  getFullPath: ->
    localDir = atom.config.get("md-writer.siteLocalDir")
    return path.join(localDir, @getPostPath())

  getPostPath: ->
    draftsDir = atom.config.get("md-writer.siteDraftsDir")
    return path.join(draftsDir, @getFileName())

  getFileName: ->
    title = utils.dashlize(@titleEditor.getText() || 'draft')
    extension = atom.config.get("md-writer.fileExtension")
    return "#{title}#{extension}"

  generateFrontMatters: ->
    """
---
layout: post
title: '#{@titleEditor.getText()}'
date: '#{utils.getDateStr()} #{utils.getTimeStr()}'
---
    """
