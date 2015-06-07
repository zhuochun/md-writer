path = require "path"
CSON = require "season"
fs = require "fs-plus"

class Configuration
  @prefix: "markdown-writer"

  @defaults:
    # static engine of your blog
    siteEngine: "general"
    # root directory of your blog
    siteLocalDir: "/config/your/local/directory/in/settings"
    # directory to drafts from the root of siteLocalDir
    siteDraftsDir: "_drafts/"
    # directory to posts from the root of siteLocalDir
    sitePostsDir: "_posts/{year}/"
    # directory to images from the root of siteLocalDir
    siteImagesDir: "images/{year}/{month}/"
    # URL to your blog
    siteUrl: ""
    # URLs to tags/posts/categories JSON file
    urlForTags: ""
    urlForPosts: ""
    urlForCategories: ""
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
    # image tag template
    imageTag: "![<alt>](<src>)"
    # fenced code block used
    codeblock:
      before: "```\n"
      after: "\n```"
      regexBefore: "```(?:[\\w- ]+)?\\n"
      regexAfter: "\\n```"
    # path to a .cson file that stores links added for automatic linking
    siteLinkPath: path.join(atom.getConfigDirPath(), "#{@prefix}-links.cson")
    # reference tag insert position (paragraph or article)
    referenceInsertPosition: "paragraph"
    # reference tag indent space (0 or 2)
    referenceIndentLength: 2
    # project specific configuration file name
    projectConfigFile: "_mdwriter.cson"

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

  @projectConfigs: {}

  engineNames: -> Object.keys(@constructor.engines)

  get: (key) ->
    @getProject(key) || @getUser(key) || @getEngine(key) || @getDefault(key)

  set: (key, val) ->
    atom.config.set(@keyPath(key), val)

  # get config.defaults
  getDefault: (key) ->
    @_valueForKeyPath(@constructor.defaults, key)

  # get config.engines based on siteEngine set
  getEngine: (key) ->
    engine = @getProject("siteEngine") ||
             @getUser("siteEngine") ||
             @getDefault("siteEngine")
    if engine in @engineNames()
      @_valueForKeyPath(@constructor.engines[engine], key)

  # get config based on engine set or global defaults
  getCurrentDefault: (key) ->
    @getEngine(key) || @getDefault(key)

  # get config from user's config file
  getUser: (key) ->
    atom.config.get(@keyPath(key), sources: [atom.config.getUserConfigPath()])

  # get project specific config from project's config file
  getProject: (key) ->
    return if !atom.project || atom.project.getPaths().length < 1

    project = atom.project.getPaths()[0]
    config = @_loadProjectConfig(project)

    return @_valueForKeyPath(config, key)

  _loadProjectConfig: (project) ->
    if @constructor.projectConfigs[project]
      return @constructor.projectConfigs[project]

    file = @getUser("projectConfigFile") || @getDefault("projectConfigFile")
    filePath = path.join(project, file)

    config = CSON.readFileSync(filePath) if fs.existsSync(filePath)
    @constructor.projectConfigs[project] = config || {}

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
