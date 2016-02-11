CSON = require "season"
path = require "path"
fs = require "fs-plus"

prefix = "markdown-writer"
sampleConfigFile =
  if packagePath = atom.packages.resolvePackagePath("markdown-writer")
    path.join(packagePath, "lib", "config.cson")
  else
    path.join(__dirname, "config.cson")

# load sample config to defaults
defaults = CSON.readFileSync(sampleConfigFile)
# static engine of your blog, see `@engines`
defaults["siteEngine"] = "general"
# project specific configuration file name
# https://github.com/zhuochun/md-writer/wiki/Settings-for-individual-projects
defaults["projectConfigFile"] = "_mdwriter.cson"
# path to a cson file that stores links added for automatic linking
# default to user config directory `markdown-writer-links.cson` file
defaults["siteLinkPath"] = path.join(atom.getConfigDirPath(), "#{prefix}-links.cson")
# filetypes markdown-writer commands apply
defaults["grammars"] = [
  'source.gfm'
  'source.litcoffee'
  'text.md'
  'text.plain'
  'text.plain.null-grammar'
]

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

module.exports =
  projectConfigs: {}

  engineNames: -> Object.keys(engines)

  keyPath: (key) -> "#{prefix}.#{key}"

  get: (key) ->
    for config in ["Project", "User", "Engine", "Default"]
      val = @["get#{config}"](key)
      return val if val?

  set: (key, val) ->
    atom.config.set(@keyPath(key), val)

  restoreDefault: (key) ->
    atom.config.unset(@keyPath(key))

  # get config.defaults
  getDefault: (key) ->
    @_valueForKeyPath(defaults, key)

  # get config.engines based on siteEngine set
  getEngine: (key) ->
    engine = @getProject("siteEngine") ||
             @getUser("siteEngine") ||
             @getDefault("siteEngine")

    if engine in @engineNames()
      @_valueForKeyPath(engines[engine], key)

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

  getSampleConfigFile: -> sampleConfigFile

  getProjectConfigFile: ->
    return if !atom.project || atom.project.getPaths().length < 1

    projectPath = atom.project.getPaths()[0]
    fileName = @getUser("projectConfigFile") || @getDefault("projectConfigFile")
    path.join(projectPath, fileName)

  _loadProjectConfig: (configFile) ->
    return @projectConfigs[configFile] if @projectConfigs[configFile]

    if fs.existsSync(configFile)
      @projectConfigs[configFile] = CSON.readFileSync(configFile)
    else
      {}

  _valueForKeyPath: (object, keyPath) ->
    keys = keyPath.split(".")
    for key in keys
      object = object[key]
      return unless object?
    object
