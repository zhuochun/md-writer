child_process = require "child_process"
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
      when 'darwin' then child_process.execFile("open", [link.url])
      when 'linux'  then child_process.execFile("xdg-open", [link.url])
      when 'win32'  then shell.openExternal(link.url)
