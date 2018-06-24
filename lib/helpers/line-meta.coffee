utils = require "../utils"

LIST_UL_TASK_REGEX = /// ^ (\s*) ([*+-\.]) \s+ \[[xX\ ]\] \s* (.*) $ ///
LIST_UL_REGEX      = /// ^ (\s*) ([*+-\.]) \s+ (.*) $ ///
LIST_OL_TASK_REGEX = /// ^ (\s*) (\d+)([\.\)]) \s+ \[[xX\ ]\] \s* (.*) $ ///
LIST_OL_REGEX      = /// ^ (\s*) (\d+)([\.\)]) \s+ (.*) $ ///
LIST_AL_TASK_REGEX = /// ^ (\s*) ([a-zA-Z]+)([\.\)]) \s+ \[[xX\ ]\] \s* (.*) $ ///
LIST_AL_REGEX      = /// ^ (\s*) ([a-zA-Z]+)([\.\)]) \s+ (.*) $ ///
BLOCKQUOTE_REGEX   = /// ^ (\s*) (>) \s* (.*) $ ///

incStr = (str) ->
  num = parseInt(str, 10)
  if isNaN(num) then utils.incrementChars(str)
  else num + 1

TYPES = [
  {
    name: ["list", "ul", "task"],
    regex: LIST_UL_TASK_REGEX,
    lineHead: (indent, head, suffix) -> "#{indent}#{head} [ ] "
    defaultHead: (head) -> head
  }
  {
    name: ["list", "ul"],
    regex: LIST_UL_REGEX,
    lineHead: (indent, head, suffix) -> "#{indent}#{head} "
    defaultHead: (head) -> head
  }
  {
    name: ["list", "ol", "task"],
    regex: LIST_OL_TASK_REGEX,
    lineHead: (indent, head, suffix) -> "#{indent}#{head}#{suffix} [ ] "
    nextLine: (indent, head, suffix) -> "#{indent}#{incStr(head)}#{suffix} [ ] "
    defaultHead: (head) -> "1"
  }
  {
    name: ["list", "ol"],
    regex: LIST_OL_REGEX,
    lineHead: (indent, head, suffix) -> "#{indent}#{head}#{suffix} "
    nextLine: (indent, head, suffix) -> "#{indent}#{incStr(head)}#{suffix} "
    defaultHead: (head) -> "1"
  }
  {
    name: ["list", "ol", "al", "task"],
    regex: LIST_AL_TASK_REGEX,
    lineHead: (indent, head, suffix) -> "#{indent}#{head}#{suffix} [ ] "
    nextLine: (indent, head, suffix) -> "#{indent}#{incStr(head)}#{suffix} [ ] "
    defaultHead: (head) ->
      c = if utils.isUpperCase(head) then "A" else "a"
      head.replace(/./g, c)
  }
  {
    name: ["list", "ol", "al"],
    regex: LIST_AL_REGEX,
    lineHead: (indent, head, suffix) -> "#{indent}#{head}#{suffix} "
    nextLine: (indent, head, suffix) -> "#{indent}#{incStr(head)}#{suffix} "
    defaultHead: (head) ->
      c = if utils.isUpperCase(head) then "A" else "a"
      head.replace(/./g, c)
  }
  {
    name: ["blockquote"],
    regex: BLOCKQUOTE_REGEX,
    lineHead: (indent, head, suffix) -> "#{indent}> "
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
        @body = matches[matches.length-1]
        @nextLine = (type.nextLine || type.lineHead).call(null, @indent, @head, @suffix)
        break

  lineHead: (head) -> @type.lineHead(@indent, head, @suffix)

  isTaskList: -> @type && @type.name.indexOf("task") != -1
  isList: (type) -> @type && @type.name.indexOf("list") != -1 && (!type || @type.name.indexOf(type) != -1)
  isContinuous: -> !!@nextLine
  isEmptyBody: -> !@body
  isIndented: -> !!@indent && @indent.length > 0

  # Static methods

  @isList: (line) -> LIST_UL_REGEX.test(line) || LIST_OL_REGEX.test(line) || LIST_AL_REGEX.test(line)
  @isOrderedList: (line) -> LIST_OL_REGEX.test(line) || LIST_AL_REGEX.test(line)
  @isUnorderedList: (line) -> LIST_UL_REGEX.test(line)
  @incStr: incStr
