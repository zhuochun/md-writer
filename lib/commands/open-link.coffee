child_process = require "child_process"
shell = require "shell"
path = require "path"
fs = require "fs-plus"

config = require "../config"
utils = require "../utils"

module.exports =
class OpenLink
  # action: open-link-in-browser, open-link-in-file
  constructor: (action) ->
    @action = action
    @editor = atom.workspace.getActiveTextEditor()

  trigger: (e) ->
    fn = @action.replace /-[a-z]/ig, (s) -> s[1].toUpperCase()
    @[fn](e)

  openLinkInBrowser: (e) ->
    range = utils.getTextBufferRange(@editor, "link")

    link = utils.findLinkInRange(@editor, range)
    return e.abortKeyBinding() if !link || !link.url

    switch process.platform
      when 'darwin' then child_process.execFile("open", [link.url])
      when 'linux'  then child_process.execFile("xdg-open", [link.url])
      when 'win32'  then shell.openExternal(link.url)

  openLinkInFile: (e) ->
    range = utils.getTextBufferRange(@editor, "link")

    link = utils.findLinkInRange(@editor, range)
    return e.abortKeyBinding() if !link || !link.url

    siteUrl = config.get("siteUrl") || ""
    return e.abortKeyBinding() if !siteUrl || !link.url.startsWith(siteUrl)

    [filePath, anchorName] = link.url.slice(siteUrl.length).split("#")
    # construct actual file path
    localDir = utils.getSitePath(config.get("siteLocalDir"), @editor.getPath())
    filePath = path.join(localDir, filePath)
    # check file exists
    return e.abortKeyBinding() unless fs.existsSync(filePath)
    # TODO jump to anchorName
    atom.workspace.open(filePath)
