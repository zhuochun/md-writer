{CompositeDisposable} = require "atom"

config = require "./config"
basicConfig = require "./config-basic"

CmdModule = {} # To cache required modules

module.exports =
  config: basicConfig

  activate: ->
    @disposables = new CompositeDisposable()

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

    @disposables.add(atom.commands.add("atom-workspace", workspaceCommands))

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

    ["insert-new-line", "indent-list-line"].forEach (command) =>
      editorCommands["markdown-writer:#{command}"] =
        @registerCommand("./commands/edit-line", args: command)

    ["correct-order-list-numbers", "format-table"].forEach (command) =>
      editorCommands["markdown-writer:#{command}"] =
        @registerCommand("./commands/format-text", args: command)

    ["publish-draft"].forEach (command) =>
      editorCommands["markdown-writer:#{command}"] =
        @registerCommand("./commands/#{command}")

    @disposables.add(atom.commands.add("atom-text-editor", editorCommands))

  registerView: (path, options = {}) ->
    (e) =>
      unless options.optOutGrammars || @isMarkdown()
        return e.abortKeyBinding()

      CmdModule[path] ?= require(path)
      cmdInstance = new CmdModule[path](options.args)
      cmdInstance.display() # unless config.get("testMode")

  registerCommand: (path, options = {}) ->
    (e) =>
      unless options.optOutGrammars || @isMarkdown()
        return e.abortKeyBinding()

      CmdModule[path] ?= require(path)
      cmdInstance = new CmdModule[path](options.args)
      cmdInstance.trigger(e) # unless config.get("testMode")

  isMarkdown: ->
    editor = atom.workspace.getActiveTextEditor()
    return false unless editor?
    return editor.getGrammar().scopeName in config.get("grammars")

  deactivate: ->
    @disposables.dispose()
    CmdModule = {}
