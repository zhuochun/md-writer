pkg = require "../package"

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "MarkdownWriter", ->
  [workspaceView, ditor, editorView, activationPromise] = []

  beforeEach ->
    waitsForPromise -> atom.workspace.open("test")
    runs ->
      workspaceView = atom.views.getView(atom.workspace)
      editor = atom.workspace.getActiveTextEditor()
      editorView = atom.views.getView(editor)
      activationPromise = atom.packages.activatePackage("markdown-writer")

  # To test dispatch commands, remove the comments in markdown-writer.coffee to
  # make sure testMode not actually trigger events.
  #
  # TODO Update individual command specs to test command dispatches in future.
  pkg.activationCommands["atom-workspace"].forEach (cmd) ->
    xit "registered workspace commands #{cmd}", ->
      atom.config.set("markdown-writer.testMode", true)

      atom.commands.dispatch(workspaceView, cmd)

      waitsForPromise -> activationPromise
      runs -> expect(true).toBe(true)

  pkg.activationCommands["atom-text-editor"].forEach (cmd) ->
    xit "registered editor commands #{cmd}", ->
      atom.config.set("markdown-writer.testMode", true)

      atom.commands.dispatch(editorView, cmd)

      waitsForPromise -> activationPromise
      runs -> expect(true).toBe(true)
