module.exports =
  configDefaults:
    siteLocalDir: "example.github.io/"
    siteLinkPath: "example.github.io/_link.cson"
    siteDraftsDir: "_drafts/"
    sitePostsDir: "_posts/{year}/"
    siteUrl: "http://example.github.io/"
    urlForTags: "http://example.github.io/assets/tags.json"
    urlForPosts: "http://example.github.io/assets/posts.json"
    urlForCategories: "http://example.github.io/assets/categories.json"
    fileExtension: ".markdown"
    grammars: [
      'source.gfm'
      'text.plain'
      'text.plain.null-grammar'
    ]

  activate: (state) ->
    # general
    ["draft", "post"].forEach (file) =>
      @registerCommand "new-#{file}", "./new-#{file}-view"
    @registerCommand "publish-draft", "./publish-draft"

    # front-matter
    ["tags", "categories"].forEach (attr) =>
      @registerCommand "manage-post-#{attr}", "./manage-post-#{attr}-view"

    # text
    ["code", "bold", "italic", "strikethrough"].forEach (style) =>
      @registerCommand "toggle-#{style}-text", "./style-text", args: style

    ["h1", "h2", "h3", "h4", "h5"].forEach (style) =>
      @registerCommand "toggle-#{style}", "./style-heading", args: style

    # media
    ["link"].forEach (media) =>
      @registerCommand "insert-#{media}", "./insert-#{media}-view"

  registerCommand: (cmd, path, opts = {}) ->
    atom.workspaceView.command "markdown-writer:#{cmd}", ->
      editor = atom.workspace.getActiveEditor()
      return unless editor?

      grammars = atom.config.get('markdown-writer.grammars') ? []
      return unless editor.getGrammar().scopeName in grammars

      cmdModule = require(path)
      cmdInstance = new cmdModule(opts.args)
      cmdInstance.display()

  deactivate: ->

  serialize: ->
