utils = require "../utils"

# Markdown-Preview packages and their protocals
pkgs =
  "markdown-preview": "markdown-preview://",
  "markdown-preview-plus": "markdown-preview-plus://file/",
  "markdown-preview-enhanced": "mpe://"

module.exports =
class OpenCheatSheet
  trigger: (e) ->
    protocal = @getProtocal()
    # abort if we cant find preview packages
    if !protocal
      atom.notifications.addError "Failed to Open Cheat Sheet",
        description: "Require package [markdown-preview](https://atom.io/packages/markdown-preview) or [markdown-preview-plus](https://atom.io/packages/markdown-preview-plus).",
        dismissable: true
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
