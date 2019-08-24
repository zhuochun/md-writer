LineMeta = require "../../lib/helpers/line-meta"

describe "LineMeta", ->
  # static methods
  describe ".isList", ->
    it "is not list", -> expect(LineMeta.isList("normal line")).toBe(false)
    it "is not list, blockquote", -> expect(LineMeta.isList("> blockquote")).toBe(false)
    it "is unordered list", -> expect(LineMeta.isList("- list")).toBe(true)
    it "is unordered task list", -> expect(LineMeta.isList("- [ ]list")).toBe(true)
    it "is unordered task list", -> expect(LineMeta.isList("- [ ] list")).toBe(true)
    it "is ordered list", -> expect(LineMeta.isList("12. list")).toBe(true)
    it "is ordered list (bracket)", -> expect(LineMeta.isList("1) list")).toBe(true)
    it "is ordered task list", -> expect(LineMeta.isList("12. [ ]list")).toBe(true)
    it "is ordered task list", -> expect(LineMeta.isList("12. [ ] list")).toBe(true)
    it "is ordered task list (bracket)", -> expect(LineMeta.isList("12) [ ] list")).toBe(true)
    it "is alpha ordered list", -> expect(LineMeta.isList("aa. list")).toBe(true)
    it "is alpha ordered task list", -> expect(LineMeta.isList("A. [ ]list")).toBe(true)
    it "is not alpha ordered task list (3 chars)", -> expect(LineMeta.isList("aaz. [ ]list")).toBe(false)

  # instance
  describe "normal line", ->
    it "is not continuous", ->
      expect(new LineMeta("normal line").isContinuous()).toBe(false)

  describe "unordered task list lines", ->
    for line in ["- [ ]", "- [x]", "- [ ] ", "- [X] "]
      describe line, ->
        lineMeta = new LineMeta(line)
        it "is list", -> expect(lineMeta.isList()).toBe(true)
        it "is ul list", -> expect(lineMeta.isList("ul")).toBe(true)
        it "is not ol list", -> expect(lineMeta.isList("ol")).toBe(false)
        it "is task list", -> expect(lineMeta.isTaskList()).toBe(true)
        it "is continuous", -> expect(lineMeta.isContinuous()).toBe(true)
        it "is empty body", -> expect(lineMeta.isEmptyBody()).toBe(true)
        it "is not indented", -> expect(lineMeta.isIndented()).toBe(false)
        it "has body", -> expect(lineMeta.body).toBe("")
        it "has head", -> expect(lineMeta.head).toBe("-")
        it "had default head", -> expect(lineMeta.defaultHead).toBe("-")
        it "has indent", -> expect(lineMeta.indent).toBe("")
        it "has nextLine", -> expect(lineMeta.nextLine).toBe("- [ ] ")
        it "has indentLineTabLength", -> expect(lineMeta.indentLineTabLength()).toBe(2)
        it "create lineHead", -> expect(lineMeta.lineHead("*")).toBe("* [ ] ")

    describe "- [X] line", ->
      lineMeta = new LineMeta("- [X] line")
      it "is list", -> expect(lineMeta.isList()).toBe(true)
      it "is ul list", -> expect(lineMeta.isList("ul")).toBe(true)
      it "is not ol list", -> expect(lineMeta.isList("ol")).toBe(false)
      it "is task list", -> expect(lineMeta.isTaskList()).toBe(true)
      it "is continuous", -> expect(lineMeta.isContinuous()).toBe(true)
      it "is not empty body", -> expect(lineMeta.isEmptyBody()).toBe(false)
      it "is not indented", -> expect(lineMeta.isIndented()).toBe(false)
      it "has body", -> expect(lineMeta.body).toBe("line")
      it "has head", -> expect(lineMeta.head).toBe("-")
      it "had default head", -> expect(lineMeta.defaultHead).toBe("-")
      it "has indent", -> expect(lineMeta.indent).toBe("")
      it "has nextLine", -> expect(lineMeta.nextLine).toBe("- [ ] ")
      it "has indentLineTabLength", -> expect(lineMeta.indentLineTabLength()).toBe(2)
      it "create lineHead", -> expect(lineMeta.lineHead("*")).toBe("* [ ] ")

  describe "unordered list line", ->
    for line in ["-", "- ", "-   "]
      describe line, ->
        lineMeta = new LineMeta(line)
        it "is list", -> expect(lineMeta.isList()).toBe(true)
        it "is continuous", -> expect(lineMeta.isContinuous()).toBe(true)
        it "is empty body", -> expect(lineMeta.isEmptyBody()).toBe(true)
        it "is not indented", -> expect(lineMeta.isIndented()).toBe(false)
        it "has body", -> expect(lineMeta.body).toBe("")
        it "has head", -> expect(lineMeta.head).toBe("-")
        it "had default head", -> expect(lineMeta.defaultHead).toBe("-")
        it "has indent", -> expect(lineMeta.indent).toBe("")
        it "has nextLine", -> expect(lineMeta.nextLine).toBe("- ")
        it "has indentLineTabLength", -> expect(lineMeta.indentLineTabLength()).toBe(2)
        it "create lineHead", -> expect(lineMeta.lineHead("*")).toBe("* ")

    describe "  - line", ->
      lineMeta = new LineMeta("  - line")
      it "is list", -> expect(lineMeta.isList()).toBe(true)
      it "is continuous", -> expect(lineMeta.isContinuous()).toBe(true)
      it "is not empty body", -> expect(lineMeta.isEmptyBody()).toBe(false)
      it "is indented", -> expect(lineMeta.isIndented()).toBe(true)
      it "has body", -> expect(lineMeta.body).toBe("line")
      it "has head", -> expect(lineMeta.head).toBe("-")
      it "had default head", -> expect(lineMeta.defaultHead).toBe("-")
      it "has indent", -> expect(lineMeta.indent).toBe("  ")
      it "has nextLine", -> expect(lineMeta.nextLine).toBe("  - ")
      it "has indentLineTabLength", -> expect(lineMeta.indentLineTabLength()).toBe(2)
      it "create lineHead", -> expect(lineMeta.lineHead("*")).toBe("  * ")

  describe "ordered task list line", ->
    for line in ["1. [ ]", "1. [x]", "1. [ ] ", "1. [X] "]
      describe line, ->
        lineMeta = new LineMeta(line)
        it "is list", -> expect(lineMeta.isList()).toBe(true)
        it "is ol list", -> expect(lineMeta.isList("ol")).toBe(true)
        it "is not ul list", -> expect(lineMeta.isList("ul")).toBe(false)
        it "is task list", -> expect(lineMeta.isTaskList()).toBe(true)
        it "is continuous", -> expect(lineMeta.isContinuous()).toBe(true)
        it "is empty body", -> expect(lineMeta.isEmptyBody()).toBe(true)
        it "is not indented", -> expect(lineMeta.isIndented()).toBe(false)
        it "has body", -> expect(lineMeta.body).toBe("")
        it "has head", -> expect(lineMeta.head).toBe("1")
        it "had default head", -> expect(lineMeta.defaultHead).toBe("1")
        it "has indent", -> expect(lineMeta.indent).toBe("")
        it "has nextLine", -> expect(lineMeta.nextLine).toBe("2. [ ] ")
        it "has indentLineTabLength", -> expect(lineMeta.indentLineTabLength()).toBe(3)
        it "create lineHead", -> expect(lineMeta.lineHead("1")).toBe("1. [ ] ")

    describe "    99. [X] line", ->
      lineMeta = new LineMeta("    99. [X] line")
      it "is list", -> expect(lineMeta.isList()).toBe(true)
      it "is ol list", -> expect(lineMeta.isList("ol")).toBe(true)
      it "is not ul list", -> expect(lineMeta.isList("ul")).toBe(false)
      it "is task list", -> expect(lineMeta.isTaskList()).toBe(true)
      it "is continuous", -> expect(lineMeta.isContinuous()).toBe(true)
      it "is not empty body", -> expect(lineMeta.isEmptyBody()).toBe(false)
      it "is indented", -> expect(lineMeta.isIndented()).toBe(true)
      it "has body", -> expect(lineMeta.body).toBe("line")
      it "has head", -> expect(lineMeta.head).toBe("99")
      it "had default head", -> expect(lineMeta.defaultHead).toBe("1")
      it "has indent", -> expect(lineMeta.indent).toBe("    ")
      it "has nextLine", -> expect(lineMeta.nextLine).toBe("    100. [ ] ")
      it "has indentLineTabLength", -> expect(lineMeta.indentLineTabLength()).toBe(4)
      it "create lineHead", -> expect(lineMeta.lineHead("1")).toBe("    1. [ ] ")

  describe "ordered list line", ->
    for line in ["3.", "3. ", "3.   "]
      describe line, ->
        lineMeta = new LineMeta(line)
        it "is list", -> expect(lineMeta.isList()).toBe(true)
        it "is continuous", -> expect(lineMeta.isContinuous()).toBe(true)
        it "is empty body", -> expect(lineMeta.isEmptyBody()).toBe(true)
        it "is not indented", -> expect(lineMeta.isIndented()).toBe(false)
        it "has body", -> expect(lineMeta.body).toBe("")
        it "has head", -> expect(lineMeta.head).toBe("3")
        it "had default head", -> expect(lineMeta.defaultHead).toBe("1")
        it "has indent", -> expect(lineMeta.indent).toBe("")
        it "has nextLine", -> expect(lineMeta.nextLine).toBe("4. ")
        it "has indentLineTabLength", -> expect(lineMeta.indentLineTabLength()).toBe(3)
        it "create lineHead", -> expect(lineMeta.lineHead("1")).toBe("1. ")

    describe "3. line", ->
      lineMeta = new LineMeta("3. line")
      it "is list", -> expect(lineMeta.isList()).toBe(true)
      it "is continuous", -> expect(lineMeta.isContinuous()).toBe(true)
      it "is not empty body", -> expect(lineMeta.isEmptyBody()).toBe(false)
      it "is not indented", -> expect(lineMeta.isIndented()).toBe(false)
      it "has body", -> expect(lineMeta.body).toBe("line")
      it "has head", -> expect(lineMeta.head).toBe("3")
      it "had default head", -> expect(lineMeta.defaultHead).toBe("1")
      it "has indent", -> expect(lineMeta.indent).toBe("")
      it "has nextLine", -> expect(lineMeta.nextLine).toBe("4. ")
      it "has indentLineTabLength", -> expect(lineMeta.indentLineTabLength()).toBe(3)
      it "create lineHead", -> expect(lineMeta.lineHead("1")).toBe("1. ")

    describe "3) line", ->
      lineMeta = new LineMeta("3) line")
      it "is list", -> expect(lineMeta.isList()).toBe(true)
      it "is continuous", -> expect(lineMeta.isContinuous()).toBe(true)
      it "is not empty body", -> expect(lineMeta.isEmptyBody()).toBe(false)
      it "is not indented", -> expect(lineMeta.isIndented()).toBe(false)
      it "has body", -> expect(lineMeta.body).toBe("line")
      it "has head", -> expect(lineMeta.head).toBe("3")
      it "had default head", -> expect(lineMeta.defaultHead).toBe("1")
      it "has indent", -> expect(lineMeta.indent).toBe("")
      it "has nextLine", -> expect(lineMeta.nextLine).toBe("4) ")
      it "has indentLineTabLength", -> expect(lineMeta.indentLineTabLength()).toBe(3)
      it "create lineHead", -> expect(lineMeta.lineHead("1")).toBe("1) ")

  describe "ordered alpha list line", ->
    describe "a. line", ->
      lineMeta = new LineMeta("a. line")
      it "is list", -> expect(lineMeta.isList()).toBe(true)
      it "is continuous", -> expect(lineMeta.isContinuous()).toBe(true)
      it "is not empty body", -> expect(lineMeta.isEmptyBody()).toBe(false)
      it "is not indented", -> expect(lineMeta.isIndented()).toBe(false)
      it "has body", -> expect(lineMeta.body).toBe("line")
      it "has head", -> expect(lineMeta.head).toBe("a")
      it "had default head", -> expect(lineMeta.defaultHead).toBe("a")
      it "has indent", -> expect(lineMeta.indent).toBe("")
      it "has nextLine", -> expect(lineMeta.nextLine).toBe("b. ")
      it "has indentLineTabLength", -> expect(lineMeta.indentLineTabLength()).toBe(3)
      it "create lineHead", -> expect(lineMeta.lineHead("a")).toBe("a. ")

    describe "EA) line", ->
      lineMeta = new LineMeta("EA) line")
      it "is list", -> expect(lineMeta.isList()).toBe(true)
      it "is continuous", -> expect(lineMeta.isContinuous()).toBe(true)
      it "is not empty body", -> expect(lineMeta.isEmptyBody()).toBe(false)
      it "is not indented", -> expect(lineMeta.isIndented()).toBe(false)
      it "has body", -> expect(lineMeta.body).toBe("line")
      it "has head", -> expect(lineMeta.head).toBe("EA")
      it "had default head", -> expect(lineMeta.defaultHead).toBe("AA")
      it "has indent", -> expect(lineMeta.indent).toBe("")
      it "has nextLine", -> expect(lineMeta.nextLine).toBe("EB) ")
      it "has indentLineTabLength", -> expect(lineMeta.indentLineTabLength()).toBe(4)
      it "create lineHead", -> expect(lineMeta.lineHead("A")).toBe("A) ")

    describe "aaa. not a list line", ->
      lineMeta = new LineMeta("aaa. not a list line")
      it "is not list", -> expect(lineMeta.isList()).toBe(false)
      it "is not continuous", -> expect(lineMeta.isContinuous()).toBe(false)

  describe "blockquote", ->
    lineMeta = new LineMeta("  > blockquote")
    it "is list", -> expect(lineMeta.isList()).toBe(false)
    it "is continuous", -> expect(lineMeta.isContinuous()).toBe(true)
    it "is not empty body", -> expect(lineMeta.isEmptyBody()).toBe(false)
    it "is indented", -> expect(lineMeta.isIndented()).toBe(true)
    it "has body", -> expect(lineMeta.body).toBe("blockquote")
    it "has head", -> expect(lineMeta.head).toBe(">")
    it "had default head", -> expect(lineMeta.defaultHead).toBe(">")
    it "has indent", -> expect(lineMeta.indent).toBe("  ")
    it "has nextLine", -> expect(lineMeta.nextLine).toBe("  > ")
    it "has indentLineTabLength", -> expect(lineMeta.indentLineTabLength()).toBe(2)
