{View} = require 'atom'

module.exports =
class MdWriterView extends View
  @content: ->
    @div class: 'md-writer overlay from-top', =>
      @div "The MdWriter package is Alive! It's ALIVE!", class: "message"

  initialize: (serializeState) ->
    atom.workspaceView.command "md-writer:new-jekyll-post", => @newJekyllPost()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    console.log "MdWriterView was toggled!"
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)

  newJekyllPost: ->
