path = require "path"

class Config
  @prefix: "markdown-writer"

  @defaults:
    # root directory of blog
    siteLocalDir: "/GitHub/example.github.io/"
    # directory to drafts from the root of siteLocalDir
    siteDraftsDir: "_drafts/"
    # directory to posts from the root of siteLocalDir
    sitePostsDir: "_posts/{year}/"
    # URLs to tags/posts/categories JSON file
    urlForTags: "http://example.github.io/assets/tags.json"
    urlForPosts: "http://example.github.io/assets/posts.json"
    urlForCategories: "http://example.github.io/assets/categories.json"
    # filetypes markdown-writer commands will apply
    grammars: [
      'source.gfm'
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
    jekyll:
      codeblock:
        before: '{% highlight %}\n'
        after: '\n{% endhighlight %}'
        regexBefore: '{% highlight(?: .+)? %}\n'
        regexAfter: '\n{% endhighlight %}'
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

  keyPath: (key) -> "#{@constructor.prefix}.#{key}"

  get: (key) ->
    atom.config.get(@keyPath(key)) || @constructor.defaults[key]

  set: (key, val) ->
    atom.config.set(@keyPath(key), val)

  getDefault: (key) -> @constructor.defaults[key]

  restoreDefault: (key) ->
    atom.config.restoreDefault(@keyPath(key))

  engineNames: -> Object.keys(@constructor.engines)

  setEngine: (name) ->
    @set(key, val) for key, val of @constructor.engines[name]

module.exports = new Config()
