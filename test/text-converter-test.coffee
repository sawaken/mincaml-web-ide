{expect} = require('chai')
{
  TextConverter
} = require __dirname + '/../src/text-converter.coffee'

describe 'test text-converter', ->
  it 'highlight', ->
    src = 'let x=1 in unit'
    ans =
    '<span class="key-word">let</span> x=' +
    '<span class="int-word">1</span> <span class="key-word">in</span> ' +
    '<span class="value-word">unit</span>'
    res = TextConverter.highlight(src)
    expect(res).to.equal(ans)

  it 'to html', ->
    src = '   1\n+1'
    ans = ' &nbsp; 1<br>+1'
    res = TextConverter.toHtml(src)
    expect(res).to.equal(ans)

  it 'decorate', ->
    src = '  x + 1'
    ans = ' &nbsp;x + <span class="int-word">1</span>'
    expect(TextConverter.decorate(src)).to.equal(ans)

  it 'lines', ->
    expect(TextConverter.lines('\n\n\r\n').length).to.equal(4)

  it 'insert', ->
    expect(TextConverter.insert('ac', 1, 'b')).to.equal('abc')

  it 'mark', ->
    src = 'abc\ndef'
    location = {start: {line: 2, offset: 1}, end: {line: 2, offset: 2}}
    res = TextConverter.mark(src, location, 'foo')
    expect(res).to.equal('abc\nd<span class="foo">e</span>f')

  it 'multi mark', ->
    src = 'abc'
    l1 = {start: {line: 1, offset: 0}, end: {line: 1, offset: 1}}
    l2 = {start: {line: 1, offset: 2}, end: {line: 1, offset: 3}}
    specs = [{location: l1, className: 'foo'}, {location: l2, className: 'bar'}]
    res = TextConverter.multiMark(src, specs)
    ans = '<span class="foo">a</span>b<span class="bar">c</span>'
    expect(res).to.equal(ans)

  it 'caret', ->
    src = 'hoge\n fuga\r\n piyo'
    res = TextConverter.caret(src, 4)
    expect(res.leftString).to.equal('hoge')
    expect(res.line).to.equal(1)
    res = TextConverter.caret(src, 5)
    expect(res.leftString).to.equal('')
    expect(res.line).to.equal(2)
    res = TextConverter.caret(src, 10)
    expect(res.leftString).to.equal(' fuga')
    expect(res.line).to.equal(2)
    res = TextConverter.caret(src, 11)
    expect(res.leftString).to.equal('')
    expect(res.line).to.equal(3)
    res = TextConverter.caret(src, 14)
    expect(res.leftString).to.equal(' pi')
    expect(res.line).to.equal(3)
