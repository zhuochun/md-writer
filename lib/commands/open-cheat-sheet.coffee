utils = require "../utils"

# Markdown-Preview packages and their protocals
pkgs =
  "markdown-preview": "markdown-preview://",
  "markdown-preview-plus": "markdown-preview-plus://file/",
  "markdown-preview-enhanced": "mpe://"

errTitle = "Cannot Open Cheat Sheet"
errMsg = """Please install and enable one of the following package:

- [markdown-preview](https://atom.io/packages/markdown-preview)
- [markdown-preview-plus](https://atom.io/packages/markdown-preview-plus)
"""

module.exports =
class OpenCheatSheet
  trigger: (e) ->
    protocal = @getProtocal()
    if !protocal # abort if we cant find preview packages
      atom.notifications.addError(errTitle, description: errMsg, dismissable: true)
      return e.abortKeyBinding()

    atom.workspace.open @cheatsheetURL(protocal),
      split: 'right', searchAllPanes: true

  getProtocal: ->
    for pkg, protocal of pkgs
      return protocal if @hasActivePackage(pkg)

  hasActivePackage: (pkg) ->
    !!atom.packages.activePackages[pkg]

  cheatsheetURL: (protocal) ->
    protocal + utils.getPackagePath("CHEATSHEET.md")
