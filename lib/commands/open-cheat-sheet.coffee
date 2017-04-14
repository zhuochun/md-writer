utils = require "../utils"

# Markdown-Preview packages and their protocals
pkgs =
  "markdown-preview": "markdown-preview",
  "markdown-preview-plus": "markdown-preview-plus"

module.exports =
class OpenCheatSheet
  trigger: (e) ->
    protocal = @getProtocal()
    return e.abortKeyBinding() unless !!protocal

    atom.workspace.open @cheatsheetURL(protocal),
      split: 'right', searchAllPanes: true

  getProtocal: ->
    for pkg, protocal of pkgs
      return protocal if @hasActivePackage(pkg)

  hasActivePackage: (pkg) ->
    !!atom.packages.activePackages[pkg]

  cheatsheetURL: (protocal) ->
    "#{protocal}://#{utils.getPackagePath("CHEATSHEET.md")}"
