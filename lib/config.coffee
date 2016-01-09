path = require "path"
CSON = require "season"
fs = require "fs-plus"

class Configuration
  @prefix: "markdown-writer"

  @defaults:
    # static engine of your blog, see `@engines`
    siteEngine: "general"

    # project specific configuration file name
    # https://github.com/zhuochun/md-writer/wiki/Settings-for-individual-projects
    projectConfigFile: "_mdwriter.cson"

    # URL to your blog
    siteUrl: ""
    # root directory of your blog
    siteLocalDir: ""
    # directory to drafts from the root of siteLocalDir
    siteDraftsDir: "_drafts/"
    # directory to posts from the root of siteLocalDir
    sitePostsDir: "_posts/{year}/"
    # directory to images from the root of siteLocalDir
    siteImagesDir: "images/{year}/{month}/"

    # URLs to tags/posts/categories JSON files
    # https://github.com/zhuochun/md-writer/wiki/Settings-for-Front-Matters
    urlForTags: ""
    urlForPosts: ""
    urlForCategories: ""

    # filename format of new drafts created
    newDraftFileName: "{slug}{extension}"
    # filename format of new posts created
    newPostFileName: "{year}-{month}-{day}-{slug}{extension}"

    # front matter date format
    frontMatterDate: "{year}-{month}-{day} {hour}:{minute}"
    # front matter template
    frontMatter: """
      ---
      layout: "{layout}"
      title: "{title}"
      date: "{date}"
      ---
      """

    # file extension of posts/drafts
    fileExtension: ".markdown"
    # file slug separator
    slugSeparator: "-"
    # use relative path to image from the opened file
    relativeImagePath: false

    # whether rename filename based on title in front matter when publishing
    publishRenameBasedOnTitle: false
    # whether publish keep draft's extension name used
    publishKeepFileExtname: false

    # list continuation in middle of line
    inlineNewLineContinuation: false

    # path to a .cson file that stores links added for automatic linking
    siteLinkPath: path.join(atom.getConfigDirPath(), "#{@prefix}-links.cson")

    # TextStyles and LineStyles
    #
    # In `regex{Before,After}`, `regexMatch{Before,After}`, DO NOT USE CAPTURE GROUP!
    # Capture group will break things! USE non-capturing group `(?:)` instead.
    #
    # Use `regexMatch{Before,After}` when you mean it is an exact match of the style.
    # If this match regex test = true, the style will be toggled.
    #
    # Use `regex{Before,After}`, when you mean it is an general match of the style.
    # If this match regex test = true, the style will be replaced by new style.
    #
    # When `regexMatch{Before,After}` is not specified, `regex{Before,After}` is used instead.
    #
    # text styles related
    textStyles:
      code:
        before: "`", after: "`"
      bold:
        before: "**", after: "**"
      italic:
        before: "_", after: "_"
      keystroke:
        before: "<kbd>", after: "</kbd>"
      strikethrough:
        before: "~~", after: "~~"
      codeblock:
        before: "```\n"
        after: "\n```"
        regexBefore: "```(?:[\\w- ]+)?\\n"
        regexAfter: "\\n```"

    # line styles related
    lineStyles:
      h1: before: "# "
      h2: before: "## "
      h3: before: "### "
      h4: before: "#### "
      h5: before: "##### "
      ul:
        before: "- ",
        regexMatchBefore: "(?:-|\\*|\\+)\\s"
        regexBefore: "(?:-|\\*|\\+|\\d+\\.)\\s"
      ol:
        before: "1. ",
        regexMatchBefore: "(?:\\d+\\.)\\s"
        regexBefore: "(?:-|\\*|\\+|\\d+\\.)\\s"
      task:
        before: "- [ ] ",
        regexMatchBefore: "(?:-|\\*|\\+|\\d+\\.)\\s+\\[ ]\\s"
        regexBefore: "(?:-|\\*|\\+|\\d+\\.)\\s*(?:\\[[xX ]])?\\s"
      taskdone:
        before: "- [X] ",
        regexMatchBefore: "(?:-|\\*|\\+|\\d+\\.)\\s+\\[[xX]]\\s"
        regexBefore: "(?:-|\\*|\\+|\\d+\\.)\\s*(?:\\[[xX ]])?\\s"
      blockquote: before: "> "

    # image tag template
    imageTag: "![{alt}]({src})"

    # inline link tag template
    linkInlineTag: "[{text}]({url})"
    # reference link tag template
    referenceInlineTag: "[{text}][{label}]"
    referenceDefinitionTag: '{indent}[{label}]: {url} "{title}"'
    # reference link tag insert position (paragraph or article)
    referenceInsertPosition: "paragraph"
    # reference link tag indent space (0 or 2) - deprecated
    referenceIndentLength: 2

    # table default alignments: "empty", "left", "right", "center"
    tableAlignment: "empty"
    # insert extra pipes at the beginning and the end of table rows
    tableExtraPipes: false

    # filetypes markdown-writer commands apply
    grammars: [
      'source.gfm'
      'text.md'
      'source.litcoffee'
      'text.plain'
      'text.plain.null-grammar'
    ]

    # template variables is a key-value map that used in template string
    # e.g. you can have `posts/{author}/{year}` in newPostFileName after you set author.
    templateVariables:
      author: ''

  @engines:
    html:
      imageTag: """
        <a href="{site}/{slug}.html" target="_blank">
          <img class="align{align}" alt="{alt}" src="{src}" width="{width}" height="{height}" />
        </a>
        """
    jekyll:
      textStyles:
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
        layout: "{layout}"
        title: "{title}"
        date: "{date}"
        ---
        """

  @projectConfigs: {}

  engineNames: -> Object.keys(@constructor.engines)

  keyPath: (key) -> "#{@constructor.prefix}.#{key}"

  get: (key) ->
    @getProject(key) || @getUser(key) || @getEngine(key) || @getDefault(key)

  set: (key, val) ->
    atom.config.set(@keyPath(key), val)

  restoreDefault: (key) ->
    atom.config.unset(@keyPath(key))

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

    @_valueForKeyPath(config, key)

  _loadProjectConfig: (project) ->
    if @constructor.projectConfigs[project]
      return @constructor.projectConfigs[project]

    file = @getUser("projectConfigFile") || @getDefault("projectConfigFile")
    filePath = path.join(project, file)

    config = CSON.readFileSync(filePath) if fs.existsSync(filePath)
    @constructor.projectConfigs[project] = config || {}

  _valueForKeyPath: (object, keyPath) ->
    keys = keyPath.split('.')
    for key in keys
      object = object[key]
      return unless object?
    object

module.exports = new Configuration()
