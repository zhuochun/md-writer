fs = require("fs-plus")

config = require "../config"

module.exports =
class CreateProjectConfigs
  trigger: ->
    configFile = config.getProjectConfigFile()

    return unless @inProjectFolder(configFile)
    return if @fileExists(configFile)

    content = fs.readFileSync(config.getSampleConfigFile())
    err = fs.writeFileSync(configFile, content)

    atom.workspace.open(configFile) unless err

  inProjectFolder: (configFile) ->
    return true if configFile
    atom.confirm
      message: "[Markdown Writer] Error!"
      detailedMessage: "Cannot create file if you are not in a project folder."
      buttons: ['OK']
    false

  fileExists: (configFile) ->
    exists = fs.existsSync(configFile)
    if exists
      atom.confirm
        message: "[Markdown Writer] Error!"
        detailedMessage: "Project config file already exists:\n#{configFile}"
        buttons: ['OK']
    exists
