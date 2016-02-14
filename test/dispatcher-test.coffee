{expect} = require('chai')
{Dispatcher, Store} = require __dirname + '/../src/dispatcher.coffee'
{TextConverter} = require __dirname + '/../src/text-converter.coffee'
{Program} = require  __dirname + '/../src/interpreter.coffee'

describe 'test dispatcher', ->
  S = Store
  test = (testProc) ->
    store = new Store()
    dispatcher = new Dispatcher(store)
    testProc(store, dispatcher)

  it 'set code without check', ->
    test (s, d) ->
      code = 'x + 1'
      d.setCode(code)
      expect(s.codeStatus).to.equal(S.CodeStatus.Unknown)
      expect(s.editor.ornamentalCode).to.equal(TextConverter.decorate(code))

  it 'set code with check (valid)', ->
    test (s, d) ->
      code = '1 + 1'
      s.currentTime = 10000
      d.setCode(code)
      expect(s.codeStatus).to.equal(S.CodeStatus.Ok)
      expect(s.editor.ornamentalCode).to.equal(TextConverter.decorate(code))

  it 'set code with check (unexpected type error)', ->
    test (s, d) ->
      code = '1+true'
      s.currentTime = 10000
      d.setCode(code)
      expect(s.codeStatus).to.equal(S.CodeStatus.TypeError)
      expect(s.editor.ornamentalCode).to.equal(
        '<span class="int-word">1</span>+' +
        '<span class="exp-error"><span class="value-word">true</span></span>'
      )

  it 'set code with check (unbound variable error)', ->
    test (s, d) ->
      code = 'x'
      s.currentTime = 10000
      d.setCode(code)
      expect(s.codeStatus).to.equal(S.CodeStatus.VarError)
      expect(s.editor.ornamentalCode).to.equal(
        '<span class="exp-error">x</span>'
      )

  it 'set code with check (mismatched variable error)', ->
    test (s, d) ->
      code = 'if true then 1 else unit'
      s.currentTime = 10000
      d.setCode(code)
      expect(s.codeStatus).to.equal(S.CodeStatus.TypeError)
      expect(s.editor.ornamentalCode).to.equal(
        '<span class="key-word">if</span> ' +
        '<span class="value-word">true</span> ' +
        '<span class="key-word">then</span> ' +
        '<span class="exp-error"><span class="int-word">1</span></span> ' +
        '<span class="key-word">else</span> ' +
        '<span class="exp-error"><span class="value-word">unit</span></span>'
      )

  it 'set code with check (syntax error)', ->
    test (s, d) ->
      code = 'x++y'
      s.currentTime = 10000
      d.setCode(code)
      expect(s.codeStatus).to.equal(S.CodeStatus.SyntaxError)
      expect(s.editor.ornamentalCode).to.equal(
        'x+<span class="position-error">+</span>y'
      )

  it 'set line info', ->
    test (s, d) ->
      code = '1\n+\n1'
      s.editor.breakpointLineMap[3] = true
      s.editor.breakpointLineMap[4] = true
      d.setLineInfo(code)
      expect(s.editor.lineNumbers).to.equal(3)
      expect(s.editor.breakpointLineMap[3]).to.equal(true)
      expect(s.editor.breakpointLineMap[4]).to.equal(undefined)

  it 'set caret', ->
    test (s, d) ->
      d.setCaret(100, 50)
      expect(s.editor.caretLeftPos).to.equal(100)
      expect(s.editor.caretTopPos).to.equal(50)

  it 'start program', ->
    test (s, d) ->
      d.startProgram('1')
      expect(s.execution.status).to.equal(S.Execution.Running)
      s.execution.program.step()
      expect(s.execution.program.cont).to.equal(1)

  it 'kill program', ->
    test (s, d) ->
      s.execution.status = S.Execution.Running
      s.execution.program = 'hoge'
      d.killProgram()
      expect(s.execution.status).to.equal(S.Execution.Stopping)
      expect(s.execution.program).to.equal(null)

  it 'stop breaking', ->
    test (s, d) ->
      s.execution.status = S.Execution.Breaking
      d.stopBreaking()
      expect(s.execution.status).to.equal(S.Execution.Running)

  it 'step program', ->
    test (s, d) ->
      ast =
        syntax: 'int'
        number: 123
        location:
          start:
            line: 1
      s.execution.status = S.Execution.Running
      s.execution.program = new Program(ast)
      d.stepProgram()
      expect(s.execution.status).to.equal(S.Execution.Running)
      d.stepProgram()
      expect(s.execution.status).to.equal(S.Execution.Stopping)
      expect(s.console.results.length).to.equal(1)
      expect(s.console.results[0]).to.equal('123')

  it 'keytyped', ->
    test (s, d) ->
      d.keytyped(10000)
      expect(s.editor.lastKeytypedTime).to.equal(10000)

  it 'set current time', ->
    test (s, d) ->
      d.setCurrentTime(10000)
      expect(s.currentTime).to.equal(10000)

  it 'toggle caret flashing', ->
    test (s, d) ->
      expect(s.editor.caretFlashing).to.equal(false)
      d.toggleCaretFlashing()
      expect(s.editor.caretFlashing).to.equal(true)
      d.toggleCaretFlashing()
      expect(s.editor.caretFlashing).to.equal(false)

  it 'toggle breakpoint', ->
    test (s, d) ->
      expect(s.editor.breakpointLineMap[2]).to.not.equal(true)
      d.toggleBreakpoint(2)
      expect(s.editor.breakpointLineMap[2]).to.equal(true)
      d.toggleBreakpoint(2)
      expect(s.editor.breakpointLineMap[2]).to.not.equal(true)
