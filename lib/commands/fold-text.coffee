config = require "../config"
utils = require "../utils"

module.exports =
class FoldText
  # action: fold-links
  constructor: (action) ->
    @action = action
    @editor = atom.workspace.getActiveTextEditor()

  trigger: (e) ->
    fn = @action.replace /-[a-z]/ig, (s) -> s[1].toUpperCase()
    @[fn]()

  foldLinks: ->
    utils.scanLinks @editor, (range) => @editor.foldBufferRange(range)
