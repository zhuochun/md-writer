CmdModule = {}

module.exports =
  configDefaults:
    siteLocalDir: "/GitHub/example.github.io/"
    siteDraftsDir: "_drafts/"
    sitePostsDir: "_posts/{year}/"
    urlForTags: "http://example.github.io/assets/tags.json"
    urlForPosts: "http://example.github.io/assets/posts.json"
    urlForCategories: "http://example.github.io/assets/categories.json"
    newPostFileName: "{year}-{month}-{day}-{title}{extension}"
    fileExtension: ".markdown"

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
      @registerCommand "toggle-#{style}", "./style-heading", args: style

    # media
    ["link", "image", "table"].forEach (media) =>
      @registerCommand "insert-#{media}", "./insert-#{media}-view"

    # helpers
    ["open-cheat-sheet", "move-to-previous-heading", "move-to-next-heading",
     "move-to-next-table-column", "format-table"].forEach (command) =>
      @registerHelper command, "./commands"

  registerCommand: (cmd, path, options = {}) ->
    atom.workspaceView.command "markdown-writer:#{cmd}", =>
      return unless options.optOutGrammars or @isMarkdown()

      CmdModule[path] ?= require(path)
      cmdInstance = new CmdModule[path](options.args)
      cmdInstance.display()

  registerHelper: (cmd, path) ->
    atom.workspaceView.command "markdown-writer:#{cmd}", =>
      return unless @isMarkdown()

      CmdModule[path] ?= require(path)
      CmdModule[path].trigger(cmd)

  isMarkdown: ->
    editor = atom.workspace.getActiveEditor()
    return false unless editor?

    grammars = atom.config.get('markdown-writer.grammars') || [
      'source.gfm'
      'text.plain'
      'text.plain.null-grammar'
    ]
    return true if editor.getGrammar().scopeName in grammars

  deactivate: ->
    CmdModule = {}

  serialize: ->
