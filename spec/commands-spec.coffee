cmds = require "../lib/commands"

describe "commands", ->
  it "find the first column in table row", ->
    fixture = "hd 1 | hd 2 | hd 3"
    expect(cmds._findNextTableColumnIdx(fixture,  0)).toEqual(4)
    expect(cmds._findNextTableColumnIdx(fixture,  6)).toEqual(11)
    expect(cmds._findNextTableColumnIdx(fixture, 13)).toEqual(19)

  it "parse table into vals", ->
    fixture = """
h1   | h21
-----|----
t123 | t2
"""
    expected =
      table: [["h1", "h21"], ["t123", "t2"]]
      maxes: [4, 3]
    expect(cmds._parseTable(fixture.split("\n"))).toEqual(expected)

  it "parse table with empty cell into vals", ->
    fixture = """
h1   | h2-1
-----|----
 | t2
"""
    expected =
      table: [["h1", "h2-1"], ["", "t2"]]
      maxes: [2, 4]
    expect(cmds._parseTable(fixture.split("\n"))).toEqual(expected)

  it "create table row text", ->
    vals = ["h1", "h2", "x y z"]
    maxes = [3, 2, 5]
    expect(cmds._createTableRow(vals, maxes, " | ")).toEqual("h1  | h2 | x y z")

  it "create table text", ->
    vals = [["h1", "h21"], ["t123", "t2"]]
    maxes = [4, 3]
    expect(cmds._createTable(table: vals, maxes: maxes)).toEqual """
h1   | h21
-----|----
t123 | t2
"""
