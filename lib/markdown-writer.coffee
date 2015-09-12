basicConfig = require "./config-basic"

CmdModule = {} # To cache required modules

module.exports =
  config: basicConfig

  activate: (state) ->
    @registerWorkspaceCommands()
    @registerEditorCommands()

  registerWorkspaceCommands: ->
    workspaceCommands = {}

    ["draft", "post"].forEach (file) =>
      workspaceCommands["markdown-writer:new-#{file}"] =
        @registerView("./views/new-#{file}-view", optOutGrammars: true)

    ["open-cheat-sheet", "create-default-keymaps"].forEach (command) =>
      workspaceCommands["markdown-writer:#{command}"] =
        @registerCommand("./commands/#{command}", optOutGrammars: true)

    @wsCommands = atom.commands.add("atom-workspace", workspaceCommands)

  registerEditorCommands: ->
    editorCommands = {}

    ["tags", "categories"].forEach (attr) =>
      editorCommands["markdown-writer:manage-post-#{attr}"] =
        @registerView("./views/manage-post-#{attr}-view")

    ["link", "image", "table"].forEach (media) =>
      editorCommands["markdown-writer:insert-#{media}"] =
        @registerView("./views/insert-#{media}-view")

    ["code", "codeblock", "bold", "italic",
     "keystroke", "strikethrough"].forEach (style) =>
      editorCommands["markdown-writer:toggle-#{style}-text"] =
        @registerCommand("./commands/style-text", args: style)

    ["h1", "h2", "h3", "h4", "h5", "ul", "ol",
     "task", "taskdone", "blockquote"].forEach (style) =>
      editorCommands["markdown-writer:toggle-#{style}"] =
        @registerCommand("./commands/style-line", args: style)

    ["previous-heading", "next-heading", "next-table-cell",
     "reference-definition"].forEach (command) =>
      editorCommands["markdown-writer:jump-to-#{command}"] =
        @registerCommand("./commands/jump-to", args: command)

    ["publish-draft", "insert-new-line", "indent-list-line",
     "correct-order-list-numbers", "format-table"].forEach (command) =>
      editorCommands["markdown-writer:#{command}"] =
        @registerCommand("./commands/#{command}")

    @edCommands = atom.commands.add("atom-text-editor", editorCommands)

  registerView: (path, options = {}) ->
    (e) =>
      unless options.optOutGrammars or @isMarkdown()
        return e.abortKeyBinding()

      CmdModule[path] ?= require(path)
      cmdInstance = new CmdModule[path](options.args)
      cmdInstance.display()

  registerCommand: (path, options = {}) ->
    (e) =>
      unless options.optOutGrammars or @isMarkdown()
        return e.abortKeyBinding()

      CmdModule[path] ?= require(path)
      cmdInstance = new CmdModule[path](options.args)
      cmdInstance.trigger(e)

  isMarkdown: ->
    editor = atom.workspace.getActiveTextEditor()
    return false unless editor?
    return editor.getGrammar().scopeName in config.get("grammars")

  deactivate: ->
    @wsCommands.dispose()
    @edCommands.dispose()

    CmdModule = {}
