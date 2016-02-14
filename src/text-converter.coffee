class TextConverter
  @highlight = (code) ->
    keyP = /(\b)(in|let|rec|if|then|else)(\b)/g
    intP = /(\b)([0-9]+)(\b)/g
    valueP = /(\b)(true|false|unit)(\b)/g
    code
      .replace(keyP, '$1<span class="key-word">$2</span>$3')
      .replace(intP, '$1<span class="int-word">$2</span>$3')
      .replace(valueP, '$1<span class="value-word">$2</span>$3')

  @escapeTag = (rowCode) ->
    rowCode.replace(/</g, '&lt;').replace(/>/g, '&gt;')

  @toHtml = (code) ->
    code
      .replace(/\r\n|\r|\n/g, '<br>')
      .replace(/\s\s/g, ' &nbsp;')
      .replace(/<br>\s/g, '<br>&nbsp;')

  @decorate = (code) ->
    @toHtml(@highlight(code))

  @insert = (string, pos, inserted) ->
    string.substr(0, pos) + inserted + string.substr(pos)

  @mark = (rowCode, location, className) ->
    markedLines = []
    for line, idx in @lines(rowCode)
      if idx == location.end.line - 1
        pos = location.end.column - 1
        line = @insert(line, pos, '</span>')
      if idx == location.start.line - 1
        pos = location.start.column - 1
        line = @insert(line, pos, '<span class="' + className + '">')
      markedLines.push(line)
    markedLines.join('\n')

  # locations must not be overlapped
  @multiMark = (rowCode, specs) ->
    sortedSpecs = specs.sort (a, b) =>
      if a.location.start.offset < b.location.start.offset
        1
      else
        -1
    res = rowCode
    for spec in sortedSpecs
      l = spec.location
      if l.start.line == l.end.line && l.start.column == l.end.column
        continue
      res = @mark(res, spec.location, spec.className)
    res

  @lines = (rowCode) ->
    rowCode.split(/\r\n|\r|\n/)

  @caret = (rowCode, pos) ->
    lines = rowCode.replace(/\r\n/g, '\n').substr(0, pos).split(/\r\n|\r|\n/)
    {leftString: lines[lines.length - 1], line: lines.length}

  @valueToString = (value) ->
    if value == null
      "unit"
    else if value instanceof Array
      '(' + (@valueToString(a) for a in value).join(', ') + ')'
    else
      value.toString()

if exports?
  exports.TextConverter = TextConverter
