OpenCheatSheet = require "../../lib/commands/open-cheat-sheet"

describe "OpenCheatSheet", ->
  it "returns correct cheatsheetURL", ->
    cmd = new OpenCheatSheet()

    expect(cmd.cheatsheetURL("markdown-preview")).toMatch("markdown-preview://")
    expect(cmd.cheatsheetURL("markdown-preview")).toMatch("CHEATSHEET.md")
    expect(cmd.cheatsheetURL("markdown-preview")).toNotMatch("%5C")
