CSON = require "season"
path = require "path"

prefix = "markdown-writer"
packagePath = atom.packages.resolvePackagePath("markdown-writer")
getConfigFile = (parts...) ->
  if packagePath then path.join(packagePath, "lib", parts...)
  else path.join(__dirname, parts...)

# load sample config to defaults
defaults = CSON.readFileSync(getConfigFile("config.cson"))

# static engine of your blog, see `@engines`
defaults["siteEngine"] = "general"
# project specific configuration file name
# https://github.com/zhuochun/md-writer/wiki/Settings-for-individual-projects
defaults["projectConfigFile"] = "_mdwriter.cson"
# path to a cson file that stores links added for automatic linking
# default to `markdown-writer-links.cson` file under user's config directory
defaults["siteLinkPath"] = path.join(atom.getConfigDirPath(), "#{prefix}-links.cson")
# filetypes markdown-writer commands apply
defaults["grammars"] = [
  'source.gfm'
  'source.gfm.nvatom'
  'source.litcoffee'
  'source.asciidoc'
  'text.md'
  'text.plain'
  'text.plain.null-grammar'
]

# filetype defaults
filetypes =
  'source.asciidoc': CSON.readFileSync(getConfigFile("filetypes", "asciidoc.cson"))

# engine defaults
engines =
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
        regexBefore: "{% highlight(?: .+)? %}\\r?\\n"
        regexAfter: "\\r?\\n{% endhighlight %}"
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

module.exports =
  projectConfigs: {}

  engineNames: -> Object.keys(engines)

  keyPath: (key) -> "#{prefix}.#{key}"

  get: (key, options = {}) ->
    allow_blank = if options["allow_blank"]? then options["allow_blank"] else true

    for config in ["Project", "User", "Engine", "Filetype", "Default"]
      val = @["get#{config}"](key)

      if allow_blank then return val if val?
      else return val if val

  set: (key, val) ->
    atom.config.set(@keyPath(key), val)

  restoreDefault: (key) ->
    atom.config.unset(@keyPath(key))

  # get config.defaults
  getDefault: (key) ->
    @_valueForKeyPath(defaults, key)

  # get config.filetypes[filetype] based on current file
  getFiletype: (key) ->
    editor = atom.workspace.getActiveTextEditor()
    return undefined unless editor?

    filetypeConfig = filetypes[editor.getGrammar().scopeName]
    return undefined unless filetypeConfig?

    @_valueForKeyPath(filetypeConfig, key)

  # get config.engines based on siteEngine set
  getEngine: (key) ->
    engine = @getProject("siteEngine") ||
             @getUser("siteEngine") ||
             @getDefault("siteEngine")

    engineConfig = engines[engine]
    return undefined unless engineConfig?

    @_valueForKeyPath(engineConfig, key)

  # get config based on engine set or global defaults
  getCurrentDefault: (key) ->
    @getEngine(key) || @getDefault(key)

  # get config from user's config file
  getUser: (key) ->
    atom.config.get(@keyPath(key), sources: [atom.config.getUserConfigPath()])

  # get project specific config from project's config file
  getProject: (key) ->
    configFile = @getProjectConfigFile()
    return unless configFile

    config = @_loadProjectConfig(configFile)
    @_valueForKeyPath(config, key)

  getSampleConfigFile: -> getConfigFile("config.cson")

  getProjectConfigFile: ->
    return if !atom.project || atom.project.getPaths().length < 1

    projectPath = atom.project.getPaths()[0]
    fileName = @getUser("projectConfigFile") || @getDefault("projectConfigFile")
    path.join(projectPath, fileName)

  _loadProjectConfig: (configFile) ->
    return @projectConfigs[configFile] if @projectConfigs[configFile]

    try
      # when configFile is empty, CSON return undefined, fallback to {}
      @projectConfigs[configFile] = CSON.readFileSync(configFile) || {}
    catch error
      # log error message in dev mode for easier troubleshotting,
      # but ignoring file not exists error
      if atom.inDevMode() && !/ENOENT/.test(error.message)
        console.info("Markdown Writer [config.coffee]: #{error}")

      @projectConfigs[configFile] = {}

  _valueForKeyPath: (object, keyPath) ->
    keys = keyPath.split(".")
    for key in keys
      object = object[key]
      return unless object?
    object
