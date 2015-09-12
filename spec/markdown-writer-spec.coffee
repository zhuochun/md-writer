MdWriter = require "../lib/markdown-writer"

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "MarkdownWriter", ->
  beforeEach ->
    waitsForPromise -> atom.workspace.open("empty.markdown")

  it "can be activated", ->
    atom.packages.activatePackage("markdown-writer")
