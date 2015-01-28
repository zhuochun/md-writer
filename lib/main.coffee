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
      default: config.getCurrentConfig("newPostFileName")
    fileExtension:
      type: "string"
      default: config.getCurrentConfig("fileExtension")

  activate: (state) ->
    commands = {}
    helpers = {}

    # new-posts
    ["draft", "post"].forEach (file) =>
      commands["markdown-writer:new-#{file}"] =
        @createCommand("./new-#{file}-view", optOutGrammars: true)

    # publishing
    commands["markdown-writer:publish-draft"] = @createCommand("./publish-draft")

    # front-matter
    ["tags", "categories"].forEach (attr) =>
      commands["markdown-writer:manage-post-#{attr}"] =
        @createCommand("./manage-post-#{attr}-view")

    # text
    ["code", "codeblock", "bold", "italic",
     "keystroke", "strikethrough"].forEach (style) =>
      commands["markdown-writer:toggle-#{style}-text"] =
        @createCommand("./style-text", args: style)

    # line-wise
    ["h1", "h2", "h3", "h4", "h5", "ul", "ol",
     "task", "taskdone", "blockquote"].forEach (style) =>
      commands["markdown-writer:toggle-#{style}"] =
        @createCommand("./style-line", args: style)

    # media
    ["link", "image", "table"].forEach (media) =>
      commands["markdown-writer:insert-#{media}"] =
        @createCommand("./insert-#{media}-view")

    # helpers
    ["open-cheat-sheet", "insert-new-line",
     "jump-between-reference-definition",
     "jump-to-previous-heading", "jump-to-next-heading",
     "jump-to-next-table-cell", "format-table"].forEach (command) =>
       helpers["markdown-writer:#{command}"] = @createHelper("./commands", command)

    atom.commands.add "atom-workspace", commands
    atom.commands.add "atom-text-editor", helpers

  createCommand: (path, options = {}) ->
    (e) =>
      unless options.optOutGrammars or @isMarkdown()
        return e.abortKeyBinding()

      CmdModule[path] ?= require(path)
      cmdInstance = new CmdModule[path](options.args)
      cmdInstance.display()

  createHelper: (path, cmd) ->
    (e) =>
      return e.abortKeyBinding() unless @isMarkdown()

      CmdModule[path] ?= require(path)
      CmdModule[path].trigger(cmd)

  isMarkdown: ->
    editor = atom.workspace.getActiveTextEditor()
    return false unless editor?
    return editor.getGrammar().scopeName in config.get("grammars")

  deactivate: ->
    CmdModule = {}

  serialize: ->
