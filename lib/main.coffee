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
      @registerCommand "toggle-#{style}-text", "./text-style-view", args: style

    ["h1", "h2", "h3", "h4", "h5"].forEach (style) =>
      @registerCommand "toggle-#{style}", "./heading-style-view", args: style

    # media
    ["link"].forEach (media) =>
      @registerCommand "insert-#{media}", "./insert-#{media}-view"

  registerCommand: (cmd, view, opts = {}) ->
    atom.workspaceView.command "markdown-writer:#{cmd}", ->
      ViewModule = require(view)
      viewInstance = new ViewModule(opts.args)
      viewInstance.display()

  deactivate: ->

  serialize: ->
