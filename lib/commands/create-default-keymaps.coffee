fs = require("fs-plus")
path = require("path")

utils = require "../utils"

module.exports =
class CreateDefaultKeymaps
  trigger: ->
    keymaps = fs.readFileSync(@sampleKeymapFile())

    userKeymapFile = @userKeymapFile()
    fs.appendFile userKeymapFile, keymaps, (err) ->
      atom.workspace.open(userKeymapFile) unless err

  userKeymapFile: ->
    path.join(atom.getConfigDirPath(), "keymap.cson")

  sampleKeymapFile: ->
    utils.getPackagePath("keymaps", @_sampleFilename())

  _sampleFilename: ->
    {
      "darwin": "sample-osx.cson",
      "linux" : "sample-linux.cson",
      "win32" : "sample-win32.cson"
    }[process.platform] || "sample-osx.cson"
