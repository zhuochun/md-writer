{WorkspaceView} = require "atom"
MdWriter = require "../lib/main"

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "MarkdownWriter", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage("markdown-writer")

  describe "when the md-writer:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find(".markdown-writer")).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger "markdown-writer:new-draft"

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find(".markdown-writer")).toExist()
