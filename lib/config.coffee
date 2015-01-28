path = require "path"

class Configuration
  @prefix: "markdown-writer"

  @defaults:
    # static engine of your blog
    siteEngine: "general"
    # root directory of your blog
    siteLocalDir: "/github/example.github.io/"
    # directory to drafts from the root of siteLocalDir
    siteDraftsDir: "_drafts/"
    # directory to posts from the root of siteLocalDir
    sitePostsDir: "_posts/{year}/"
    # URL to your blog
    siteUrl: ""
    # URLs to tags/posts/categories JSON file
    urlForTags: "http://example.github.io/assets/tags.json"
    urlForPosts: "http://example.github.io/assets/posts.json"
    urlForCategories: "http://example.github.io/assets/categories.json"
    # filetypes markdown-writer commands apply
    grammars: [
      'source.gfm'
      'source.litcoffee'
      'text.plain'
      'text.plain.null-grammar'
    ]
    # file extension of posts/drafts
    fileExtension: ".markdown"
    # whether rename filename based on title in front matter when publishing
    publishRenameBasedOnTitle: false
    # whether publish keep draft's extensio name used
    publishKeepFileExtname: false
    # filename format of new posts/drafts created
    newPostFileName: "{year}-{month}-{day}-{title}{extension}"
    # front matter template
    frontMatter: """
      ---
      layout: <layout>
      title: "<title>"
      date: "<date>"
      ---
      """
    # fenced code block used
    codeblock:
      before: "```\n"
      after: "\n```"
      regexBefore: "```(?:[\\w- ]+)?\\n"
      regexAfter: "\\n```"
    # path to a .cson file that stores links added for automatic linking
    siteLinkPath: path.join(atom.getConfigDirPath(), "#{@prefix}-links.cson")
    # image tag template
    imageTag: "![<alt>](<src>)"
    # image url prefix if you insert image not in blog directory
    siteImageUrl: "/assets/{year}/{month}/"

  @engines:
    html:
      imageTag: """
        <a href="<site>/<slug>.html" target="_blank">
          <img class="align<align>" alt="<alt>" src="<src>" width="<width>" height="<height>" />
        </a>
        """
    jekyll:
      codeblock:
        before: "{% highlight %}\n"
        after: "\n{% endhighlight %}"
        regexBefore: "{% highlight(?: .+)? %}\n"
        regexAfter: "\n{% endhighlight %}"
    octopress:
      imageTag: "{% img {align} {src} {width} {height} '{alt}' %}"
    hexo:
      newPostFileName: "{title}{extension}"
      frontMatter: """
        layout: <layout>
        title: "<title>"
        date: "<date>"
        ---
        """

  engineNames: -> Object.keys(@constructor.engines)

  get: (key) ->
    @getUserConfig(key) || @getEngine(key) || @getDefault(key)

  set: (key, val) ->
    atom.config.set(@keyPath(key), val)

  # get config.defaults
  getDefault: (key) ->
    @_valueForKeyPath(@constructor.defaults, key)

  # get config.engines based on siteEngine set
  getEngine: (key) ->
    engine = atom.config.get(@keyPath("siteEngine"))
    if engine in @engineNames()
      @_valueForKeyPath(@constructor.engines[engine], key)

  # get config based on engine set or global defaults
  getCurrentConfig: (key) ->
    @getEngine(key) || @getDefault(key)

  # get config from user's config file
  getUserConfig: (key) ->
    atom.config.get(@keyPath(key), sources: [atom.config.getUserConfigPath()])

  restoreDefault: (key) ->
    atom.config.unset(@keyPath(key))

  keyPath: (key) -> "#{@constructor.prefix}.#{key}"

  _valueForKeyPath: (object, keyPath) ->
    keys = keyPath.split('.')
    for key in keys
      object = object[key]
      return unless object?
    object

module.exports = new Configuration()
