class TextConverter
  @highlight = (code) ->
    keyP = /(\b)(in|let|rec|if|then|else)(\b)/g
    intP = /(\b)([0-9]+)(\b)/g
    valueP = /(\b)(true|false|unit)(\b)/g
    code
      .replace(keyP, '$1<span class="key-word">$2</span>$3')
      .replace(intP, '$1<span class="int-word">$2</span>$3')
      .replace(valueP, '$1<span class="value-word">$2</span>$3')

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
        pos = location.end.offset
        line = @insert(line, pos, '</span>')
      if idx == location.start.line - 1
        pos = location.start.offset
        line = @insert(line, pos, '<span class="' + className + '">')
      markedLines.push(line)
    markedLines.join('\n')

  # locations must not be overlapped
  @multiMark = (rowCode, specs) ->
    sortedSpecs = specs.sort (a, b) =>
      as = a.location.start
      bs = b.location.start
      if as.line < bs.line || (as.line == bs.line && as.offset < bs.offset)
        1
      else if as.line > bs.line || (as.line == bs.line && as.offset > bs.offset)
        -1
      else
        0
    res = rowCode
    for spec in sortedSpecs
      res = @mark(res, spec.location, spec.className)
    res

  @lines = (rowCode) ->
    rowCode.split(/\r\n|\r|\n/)

  @caret = (rowCode, pos) ->
    lines = rowCode.replace(/\r\n/g, '\n').substr(0, pos).split(/\r\n|\r|\n/)
    {leftString: lines[lines.length - 1], line: lines.length}

if exports?
  exports.TextConverter = TextConverter

@TextConverter = TextConverter
