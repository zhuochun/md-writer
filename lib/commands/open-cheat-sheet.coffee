utils = require "../utils"

module.exports =
class OpenCheatSheet
  trigger: (e) ->
    e.abortKeyBinding() unless @hasPreview()

    atom.workspace.open @cheatsheetURL(),
      split: 'right', searchAllPanes: true

  hasPreview: ->
    !!atom.packages.activePackages['markdown-preview']

  cheatsheetURL: ->
    cheatsheet = utils.getPackagePath("CHEATSHEET.md")
    "markdown-preview://#{encodeURI(cheatsheet)}"
