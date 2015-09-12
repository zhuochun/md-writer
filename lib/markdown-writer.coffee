basicConfig = require "./config-basic"

CmdModule = {} # To cache required modules

module.exports =
  config: basicConfig

  activate: (state) ->
    workspaceCommands = {}
    editorCommands = {}

    # new-posts
    ["draft", "post"].forEach (file) =>
      workspaceCommands["markdown-writer:new-#{file}"] =
        @createCommand("./new-#{file}-view", optOutGrammars: true)

    # publishing
    workspaceCommands["markdown-writer:publish-draft"] =
      @createCommand("./publish-draft")

    # front-matter
    ["tags", "categories"].forEach (attr) =>
      editorCommands["markdown-writer:manage-post-#{attr}"] =
        @createCommand("./manage-post-#{attr}-view")

    # text
    ["code", "codeblock", "bold", "italic",
     "keystroke", "strikethrough"].forEach (style) =>
      editorCommands["markdown-writer:toggle-#{style}-text"] =
        @createCommand("./style-text", args: style)

    # line-wise
    ["h1", "h2", "h3", "h4", "h5", "ul", "ol",
     "task", "taskdone", "blockquote"].forEach (style) =>
      editorCommands["markdown-writer:toggle-#{style}"] =
        @createCommand("./style-line", args: style)

    # media
    ["link", "image", "table"].forEach (media) =>
      editorCommands["markdown-writer:insert-#{media}"] =
        @createCommand("./insert-#{media}-view")

    # helpers
    ["insert-new-line", "indent-list-line", "correct-order-list-numbers",
     "jump-to-previous-heading", "jump-to-next-heading",
     "jump-between-reference-definition", "jump-to-next-table-cell",
     "format-table"].forEach (command) =>
      editorCommands["markdown-writer:#{command}"] =
        @createHelper("./commands", command)

    # additional workspace helpers
    ["open-cheat-sheet", "create-default-keymaps"].forEach (command) =>
      workspaceCommands["markdown-writer:#{command}"] =
        @createHelper("./commands", command, optOutGrammars: true)

    @wsCommands = atom.commands.add "atom-workspace", workspaceCommands
    @edCommands = atom.commands.add "atom-text-editor", editorCommands

  createCommand: (path, options = {}) ->
    (e) =>
      unless options.optOutGrammars or @isMarkdown()
        return e.abortKeyBinding()

      CmdModule[path] ?= require(path)
      cmdInstance = new CmdModule[path](options.args)
      cmdInstance.display()

  createHelper: (path, cmd, options = {}) ->
    (e) =>
      unless options.optOutGrammars or @isMarkdown()
        return e.abortKeyBinding()

      CmdModule[path] ?= require(path)
      CmdModule[path].trigger(cmd)

  isMarkdown: ->
    editor = atom.workspace.getActiveTextEditor()
    return false unless editor?
    return editor.getGrammar().scopeName in config.get("grammars")

  deactivate: ->
    @wsCommands.dispose()
    @edCommands.dispose()

    CmdModule = {}
