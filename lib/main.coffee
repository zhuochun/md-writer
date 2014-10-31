config = require "./config"

CmdModule = {}

module.exports =
  config:
    siteEngine:
      type: "string"
      default: config.getDefault("siteEngine")
      enum: [config.getDefault("siteEngine"), config.engineNames()...]
    siteUrl:
      type: "string"
      default: config.getDefault("siteUrl")
    siteLocalDir:
      type: "string"
      default: config.getDefault("siteLocalDir")
    siteDraftsDir:
      type: "string"
      default: config.getDefault("siteDraftsDir")
    sitePostsDir:
      type: "string"
      default: config.getDefault("sitePostsDir")
    urlForTags:
      title: "URL to Tags JSON definitions"
      type: "string"
      default: config.getDefault("urlForTags")
    urlForPosts:
      title: "URL to Posts JSON definitions"
      type: "string"
      default: config.getDefault("urlForPosts")
    urlForCategories:
      title: "URL to Categories JSON definitions"
      type: "string"
      default: config.getDefault("urlForCategories")
    newPostFileName:
      type: "string"
      default: config.getDefault("newPostFileName")
    fileExtension:
      type: "string"
      default: config.getDefault("fileExtension")

  activate: (state) ->
    # general
    ["draft", "post"].forEach (file) =>
      @registerCommand "new-#{file}", "./new-#{file}-view", optOutGrammars: true
    @registerCommand "publish-draft", "./publish-draft"

    # front-matter
    ["tags", "categories"].forEach (attr) =>
      @registerCommand "manage-post-#{attr}", "./manage-post-#{attr}-view"

    # text
    ["code", "codeblock", "bold", "italic",
     "keystroke", "strikethrough"].forEach (style) =>
      @registerCommand "toggle-#{style}-text", "./style-text", args: style

    # line-wise
    ["h1", "h2", "h3", "h4", "h5", "ul", "ol",
     "task", "taskdone", "blockquote"].forEach (style) =>
      @registerCommand "toggle-#{style}", "./style-line", args: style

    # media
    ["link", "image", "table"].forEach (media) =>
      @registerCommand "insert-#{media}", "./insert-#{media}-view"

    # helpers
    ["open-cheat-sheet", "insert-new-line",
     "jump-between-reference-definition",
     "jump-to-previous-heading", "jump-to-next-heading",
     "jump-to-next-table-cell", "format-table"].forEach (command) =>
      @registerHelper command, "./commands"

  registerCommand: (cmd, path, options = {}) ->
    atom.workspaceView.command "markdown-writer:#{cmd}", (e) =>
      unless options.optOutGrammars or @isMarkdown()
        return e.abortKeyBinding()

      CmdModule[path] ?= require(path)
      cmdInstance = new CmdModule[path](options.args)
      cmdInstance.display()

  registerHelper: (cmd, path) ->
    atom.workspaceView.command "markdown-writer:#{cmd}", (e) =>
      return e.abortKeyBinding() unless @isMarkdown()

      CmdModule[path] ?= require(path)
      CmdModule[path].trigger(cmd)

  isMarkdown: ->
    editor = atom.workspace.getActiveEditor()
    return false unless editor?
    return editor.getGrammar().scopeName in config.get("grammars")

  deactivate: ->
    CmdModule = {}

  serialize: ->
