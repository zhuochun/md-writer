LIST_UL_TASK_REGEX = /// ^ (\s*) ([*+-]) \s+ \[[xX\ ]\] \s* (.*) $ ///
LIST_UL_REGEX      = /// ^ (\s*) ([*+-]) \s+ (.*) $ ///
LIST_OL_TASK_REGEX = /// ^ (\s*) (\d+)\. \s+ \[[xX\ ]\] \s* (.*) $ ///
LIST_OL_REGEX      = /// ^ (\s*) (\d+)\. \s+ (.*) $ ///

BLOCKQUOTE_REGEX   = /// ^ (\s*) (>)     \s* (.*) $ ///

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
    nextLine: (matches) -> "#{matches[1]}#{parseInt(matches[2], 10) + 1}. [ ] "
  }
  {
    name: ["list", "ol"],
    regex: LIST_OL_REGEX,
    nextLine: (matches) -> "#{matches[1]}#{parseInt(matches[2], 10) + 1}. "
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

  @isList: (line) -> LIST_UL_REGEX.test(line) || LIST_OL_REGEX.test(line)
  @isOrderedList: (line) -> LIST_OL_REGEX.test(line)
  @isUnorderedList: (line) -> LIST_UL_REGEX.test(line)
