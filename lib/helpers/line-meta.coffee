utils = require "../utils"

LIST_UL_TASK_REGEX = /// ^ (\s*) ([*+-\.]) \s+ \[[xX\ ]\] (?:\s+ (.*))? $ ///
LIST_UL_REGEX      = /// ^ (\s*) ([*+-\.]) (?:\s+ (.*))? $ ///
LIST_OL_TASK_REGEX = /// ^ (\s*) (\d+)([\.\)]) \s+ \[[xX\ ]\] (?:\s+ (.*))? $ ///
LIST_OL_REGEX      = /// ^ (\s*) (\d+)([\.\)]) (?:\s+ (.*))? $ ///
LIST_AL_TASK_REGEX = /// ^ (\s*) ([a-zA-Z]{1,2})([\.\)]) \s+ \[[xX\ ]\] (?:\s+ (.*))? $ ///
LIST_AL_REGEX      = /// ^ (\s*) ([a-zA-Z]{1,2})([\.\)]) (?:\s+ (.*))? $ ///
BLOCKQUOTE_REGEX   = /// ^ (\s*) (>) (?:\s+ (.*))? $ ///

incStr = (str) ->
  num = parseInt(str, 10)
  if isNaN(num) then utils.incrementChars(str)
  else num + 1

TYPES = [
  {
    name: ["list", "ul", "task"],
    regex: LIST_UL_TASK_REGEX,
    lineHead: (m) -> "#{m.indent}#{m.head} [ ] "
    nextLine: (m) -> "#{m.indent}#{m.head} [ ] "
    nextIndent: (m) -> m.head.length + 1
    defaultHead: (head) -> head
  }
  {
    name: ["list", "ul"],
    regex: LIST_UL_REGEX,
    lineHead: (m) -> "#{m.indent}#{m.head} "
    nextLine: (m) -> "#{m.indent}#{m.head} "
    nextIndent: (m) -> m.head.length + 1
    defaultHead: (head) -> head
  }
  {
    name: ["list", "ol", "task"],
    regex: LIST_OL_TASK_REGEX,
    lineHead: (m) -> "#{m.indent}#{m.head}#{m.suffix} [ ] "
    nextLine: (m) -> "#{m.indent}#{incStr(m.head)}#{m.suffix} [ ] "
    nextIndent: (m) -> m.head.length + m.suffix.length + 1
    defaultHead: (head) -> "1"
  }
  {
    name: ["list", "ol"],
    regex: LIST_OL_REGEX,
    lineHead: (m) -> "#{m.indent}#{m.head}#{m.suffix} "
    nextLine: (m) -> "#{m.indent}#{incStr(m.head)}#{m.suffix} "
    nextIndent: (m) -> m.head.length + m.suffix.length + 1
    defaultHead: (head) -> "1"
  }
  {
    name: ["list", "ol", "al", "task"],
    regex: LIST_AL_TASK_REGEX,
    lineHead: (m) -> "#{m.indent}#{m.head}#{m.suffix} [ ] "
    nextLine: (m) -> "#{m.indent}#{incStr(m.head)}#{m.suffix} [ ] "
    nextIndent: (m) -> m.head.length + m.suffix.length + 1
    defaultHead: (head) ->
      c = if utils.isUpperCase(head) then "A" else "a"
      head.replace(/./g, c)
  }
  {
    name: ["list", "ol", "al"],
    regex: LIST_AL_REGEX,
    lineHead: (m) -> "#{m.indent}#{m.head}#{m.suffix} "
    nextLine: (m) -> "#{m.indent}#{incStr(m.head)}#{m.suffix} "
    nextIndent: (m) -> m.head.length + m.suffix.length + 1
    defaultHead: (head) ->
      c = if utils.isUpperCase(head) then "A" else "a"
      head.replace(/./g, c)
  }
  {
    name: ["blockquote"],
    regex: BLOCKQUOTE_REGEX,
    lineHead: (m) -> "#{m.indent}> "
    nextLine: (m) -> "#{m.indent}> "
    nextIndent: (m) -> 2
    defaultHead: (head) -> ">"
  }
]

module.exports =
class LineMeta
  constructor: (line) ->
    @line = line
    @type = undefined
    @head = ""
    @defaultHead = ""
    @body = ""
    @indent = ""
    @nextLine = ""

    @_findMeta()

  _findMeta: ->
    for type in TYPES
      if matches = type.regex.exec(@line)
        @type = type
        @indent = matches[1]
        @head = matches[2]
        @defaultHead = type.defaultHead(matches[2])
        @suffix = if matches.length >= 4 then matches[3] else ""
        @body = matches[matches.length-1] || ""
        @nextLine = type.nextLine(@)
        break

  lineHead: (head) -> @type.lineHead({ indent: @indent, head: head, suffix: @suffix })

  # If line to be indented
  indentLineTabText: -> " ".repeat(@indentLineTabLength())
  indentLineTabLength: -> @type.nextIndent(@)

  # Checks
  isTaskList: -> !!@type && @type.name.indexOf("task") != -1
  isList: (type) -> !!@type && @type.name.indexOf("list") != -1 && (!type || @type.name.indexOf(type) != -1)
  isContinuous: -> !!@nextLine
  isEmptyBody: -> !@body
  isIndented: -> !!@indent && @indent.length > 0

  # Static methods
  @isList: (line) -> LIST_UL_REGEX.test(line) || LIST_OL_REGEX.test(line) || LIST_AL_REGEX.test(line)
  @isOrderedList: (line) -> LIST_OL_REGEX.test(line) || LIST_AL_REGEX.test(line)
  @isUnorderedList: (line) -> LIST_UL_REGEX.test(line)
  @incStr: incStr
