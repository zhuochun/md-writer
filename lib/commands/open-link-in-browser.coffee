{exec} = require "child_process"
shell = require "shell"

utils = require "../utils"

module.exports =
class OpenLinkInBrowser
  trigger: (e) ->
    editor = atom.workspace.getActiveTextEditor()
    range = utils.getTextBufferRange(editor, "link")
    link = utils.findLinkInRange(editor, range)

    return e.abortKeyBinding() if !link || !link.url

    switch process.platform
      when 'darwin' then exec("open #{link.url}")
      when 'linux' then exec("xdg-open #{link.url}")
      when 'win32' then shell.openExternal(link.url)
