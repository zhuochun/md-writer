utils = require "../utils"

LIST_UL_TASK_REGEX = /// ^ (\s*) ([*+-\.]) \s+ \[[xX\ ]\] \s* (.*) $ ///
LIST_UL_REGEX      = /// ^ (\s*) ([*+-\.]) \s+ (.*) $ ///
LIST_OL_TASK_REGEX = /// ^ (\s*) (\d+)\. \s+ \[[xX\ ]\] \s* (.*) $ ///
LIST_OL_REGEX      = /// ^ (\s*) (\d+)\. \s+ (.*) $ ///
LIST_AL_TASK_REGEX = /// ^ (\s*) ([a-zA-Z]+)\. \s+ \[[xX\ ]\] \s* (.*) $ ///
LIST_AL_REGEX      = /// ^ (\s*) ([a-zA-Z]+)\. \s+ (.*) $ ///
BLOCKQUOTE_REGEX   = /// ^ (\s*) (>)     \s* (.*) $ ///

incStr = (str) ->
  num = parseInt(str, 10)
  if isNaN(num) then utils.incrementChars(str)
  else num + 1

TYPES = [
  {
    name: ["list", "ul", "task"],
    regex: LIST_UL_TASK_REGEX,
    nextLine: (matches) -> "#{matches[1]}#{matches[2]} [ ] "
  }
  {
    name: ["list", "ul"],
    regex: LIST_UL_REGEX,
    nextLine: (matches) -> "#{matches[1]}#{matches[2]} "
  }
  {
    name: ["list", "ol", "task"],
    regex: LIST_OL_TASK_REGEX,
    nextLine: (matches) -> "#{matches[1]}#{incStr(matches[2])}. [ ] "
  }
  {
    name: ["list", "ol"],
    regex: LIST_OL_REGEX,
    nextLine: (matches) -> "#{matches[1]}#{incStr(matches[2])}. "
  }
  {
    name: ["list", "ol", "al", "task"],
    regex: LIST_AL_TASK_REGEX,
    nextLine: (matches) -> "#{matches[1]}#{incStr(matches[2])}. [ ] "
  }
  {
    name: ["list", "ol", "al"],
    regex: LIST_AL_REGEX,
    nextLine: (matches) -> "#{matches[1]}#{incStr(matches[2])}. "
  }
  {
    name: ["blockquote"],
    regex: BLOCKQUOTE_REGEX,
    nextLine: (matches) -> "#{matches[1]}> "
  }
]

module.exports =
class LineMeta
  constructor: (line) ->
    @line = line
    @types = []
    @head = ""
    @body = ""
    @indent = ""
    @nextLine = ""

    @_findMeta()

  _findMeta: ->
    for type in TYPES
      if matches = type.regex.exec(@line)
        @types = type.name
        @indent = matches[1]
        @head = matches[2]
        @body = matches[3]
        @nextLine = type.nextLine(matches)

        break

  isTaskList: -> @types.indexOf("task") != -1
  isList: (type) -> @types.indexOf("list") != -1 && (!type || @types.indexOf(type) != -1)
  isContinuous: -> !!@nextLine
  isEmptyBody: -> !@body

  @isList: (line) -> LIST_UL_REGEX.test(line) || LIST_OL_REGEX.test(line) || LIST_AL_REGEX.test(line)
  @isOrderedList: (line) -> LIST_OL_REGEX.test(line) || LIST_AL_REGEX.test(line)
  @isUnorderedList: (line) -> LIST_UL_REGEX.test(line)
  @incStr: incStr
