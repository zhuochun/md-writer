MdWriter = require "../lib/main"

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "MarkdownWriter", ->
  workspaceElement = null
  activationPromise = null

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage("markdown-writer")

  xdescribe "when the md-writer:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(getMarkdownWriter().length).toBe(0)

      atom.commands.dispatch workspaceElement, "markdown-writer:new-draft"

      waitsForPromise -> activationPromise
      runs -> expect(getMarkdownWriter().length).toBe(1)

  getMarkdownWriter = ->
    workspaceElement.getElementsByClassName(".markdown-writer")
