cmds = require "../lib/commands"

describe "commands", ->
  it "correct top level order list numbers", ->
    fixture  = ["3. abc", "9. efg", "0. hij", "  1. k l m", "7. opq", "rst"]
    expected = ["3. abc", "4. efg", "5. hij", "  1. k l m", "6. opq", "rst"]
    expect(cmds._correctOrderNumbers(fixture)).toEqual(expected)

  it "correct sub-level order list numbers", ->
    fixture  = ["  1. abc", "    efg", "  9. hij", "    1. klm", "  9. opq"]
    expected = ["  1. abc", "    efg", "  2. hij", "    1. klm", "  3. opq"]

    expect(cmds._correctOrderNumbers(fixture)).toEqual(expected)


  it "find the first column in table row", ->
    fixture = "hd 1 | hd 2 | hd 3"
    expect(cmds._findNextTableCellIdx(fixture,  0)).toEqual(4)
    expect(cmds._findNextTableCellIdx(fixture,  6)).toEqual(11)
    expect(cmds._findNextTableCellIdx(fixture, 13)).toEqual(19)

  it "find the first non empty line index", ->
    fixture = ["", ""]
    expect(cmds._indexOfFirstNonEmptyLine(fixture)).toEqual(-1)
    fixture = ["abc"]
    expect(cmds._indexOfFirstNonEmptyLine(fixture)).toEqual(0)
    fixture = ["", "abc"]
    expect(cmds._indexOfFirstNonEmptyLine(fixture)).toEqual(1)

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
