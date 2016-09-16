utils = require "../utils"

module.exports =
class OpenCheatSheet
  trigger: (e) ->
    return e.abortKeyBinding() unless @hasPreview()

    atom.workspace.open @cheatsheetURL(),
      split: 'right', searchAllPanes: true

  hasPreview: ->
    !!atom.packages.activePackages['markdown-preview']

  cheatsheetURL: ->
    cheatsheet = utils.getPackagePath("CHEATSHEET.md")
    "markdown-preview://#{cheatsheet}"
