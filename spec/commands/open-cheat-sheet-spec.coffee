OpenCheatSheet = require "../../lib/commands/open-cheat-sheet"

describe "OpenCheatSheet", ->
  it "returns correct cheatsheetURL", ->
    cmd = new OpenCheatSheet()
    expect(cmd.cheatsheetURL()).toMatch("markdown-preview://")
    expect(cmd.cheatsheetURL()).toMatch("CHEATSHEET.md")
