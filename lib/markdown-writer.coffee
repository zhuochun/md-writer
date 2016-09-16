{CompositeDisposable} = require "atom"

config = require "./config"
basicConfig = require "./config-basic"

module.exports =
  config: basicConfig

  modules: {} # To cache required modules
  disposables: null # Composite disposable

  activate: ->
    @disposables = new CompositeDisposable()

    @registerWorkspaceCommands()
    @registerEditorCommands()

  deactivate: ->
    @disposables?.dispose()
    @disposables = null
    @modules = {}

  registerWorkspaceCommands: ->
    workspaceCommands = {}

    ["draft", "post"].forEach (file) =>
      workspaceCommands["markdown-writer:new-#{file}"] =
        @registerView("./views/new-#{file}-view", optOutGrammars: true)

    ["open-cheat-sheet", "create-default-keymaps",
     "create-project-configs"].forEach (command) =>
      workspaceCommands["markdown-writer:#{command}"] =
        @registerCommand("./commands/#{command}", optOutGrammars: true)

    @disposables.add(atom.commands.add("atom-workspace", workspaceCommands))

  registerEditorCommands: ->
    editorCommands = {}

    ["tags", "categories"].forEach (attr) =>
      editorCommands["markdown-writer:manage-post-#{attr}"] =
        @registerView("./views/manage-post-#{attr}-view")

    ["link", "footnote", "image", "table"].forEach (media) =>
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
        @registerCommand("./commands/edit-line",
          args: command, skipList: ["autocomplete-active"])

    ["correct-order-list-numbers", "format-table"].forEach (command) =>
      editorCommands["markdown-writer:#{command}"] =
        @registerCommand("./commands/format-text", args: command)

    ["publish-draft", "open-link-in-browser"].forEach (command) =>
      editorCommands["markdown-writer:#{command}"] =
        @registerCommand("./commands/#{command}")

    @disposables.add(atom.commands.add("atom-text-editor", editorCommands))

  registerView: (path, options = {}) ->
    (e) =>
      if (options.optOutGrammars || @isMarkdown()) && !@inSkipList(options.skipList)
        @modules[path] ?= require(path)
        moduleInstance = new @modules[path](options.args)
        moduleInstance.display() unless config.get("_skipAction")?
      else
        e.abortKeyBinding()

  registerCommand: (path, options = {}) ->
    (e) =>
      if (options.optOutGrammars || @isMarkdown()) && !@inSkipList(options.skipList)
        @modules[path] ?= require(path)
        moduleInstance = new @modules[path](options.args)
        moduleInstance.trigger(e) unless config.get("_skipAction")?
      else
        e.abortKeyBinding()

  isMarkdown: ->
    editor = atom.workspace.getActiveTextEditor()
    return false unless editor?

    grammars = config.get("grammars") || []
    return grammars.indexOf(editor.getGrammar().scopeName) >= 0

  inSkipList: (list) ->
    return false unless list?
    editorElement = atom.views.getView(atom.workspace.getActiveTextEditor())
    return false unless editorElement? && editorElement.classList?
    return list.every (className) -> editorElement.classList.contains(className)
