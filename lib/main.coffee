module.exports =
  configDefaults:
    siteLocalDir: "example.github.io/"
    siteLinkPath: "example.github.io/_link.cson"
    sitePostsDir: "_posts/{year}/"
    siteUrl: "http://example.github.io/"
    urlForTags: "http://example.github.io/assets/tags.json"
    urlForPosts: "http://example.github.io/assets/posts.json"
    urlForCategories: "http://example.github.io/assets/categories.json"
    fileExtension: ".markdown"

  activate: (state) ->
    # general
    @registerCommand "new-post", "./new-post-view"

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
    atom.workspaceView.command "md-writer:#{cmd}", ->
      ViewModule = require(view)
      viewInstance = new ViewModule(opts.args)
      viewInstance.display()

  deactivate: ->

  serialize: ->
