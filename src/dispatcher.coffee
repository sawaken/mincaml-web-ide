if require?
  # use TextConverter
  {TextConverter} = require __dirname + '/text-converter.coffee'
  # use TypeChecker
  {
    TypeChecker,
    MismatchedTypeError,
    UnexpectedTypeError,
    UnboundVariableError
  } = require  __dirname + '/type-checker.coffee'
  # use mincamlParser
  peg = require 'pegjs'
  fs = require 'fs'
  grammerFile = __dirname + '/../parser/mincaml-parser.pegjs'
  mincamlParser = peg.buildParser fs.readFileSync(grammerFile, 'utf8')
  # use Program
  {
    Program,
    Closure,
    Continuation
  } = require  __dirname + '/interpreter.coffee'

class Store
  @Execution =
    Stopping: 1
    Breaking: 2
    Running:  3

  @CodeStatus =
    Ok:          1
    SyntaxError: 2
    TypeError:   3
    VarError:    4
    Unknown:     5

  constructor: () ->
    @editor =
      caretLeftPos: 0
      caretTopPos: 0
      caretVisible: false
      caretFlashing: false
      ornamentalCode : ""
      rowCode: ""
      lineNumbers: 1
      breakpointLineMap: []
      lastKeytypedTime: 0
      focusing: false
    @currentTime = 0
    @codeStatus = Store.CodeStatus.Unknown
    @execution =
      status: Store.Execution.Stopping
      program: null
    @console =
      status: ''
      results : []

  nowTyping: (delay) ->
    @editor.lastKeytypedTime > @currentTime - delay

  nowEditing: ->
    @nowTyping(1000)

class Dispatcher
  constructor: (@store) ->

  setCode: (rowCode) ->
    if @store.nowEditing()
      @setCodeWithoutCheck(rowCode)
    else
      if @store.codeStatus == Store.CodeStatus.Unknown
        @setCodeWithCheck(rowCode)
      else
        # do nothing

  # private
  setCodeWithoutCheck: (rowCode) ->
    escapedRowCode = TextConverter.escapeTag(rowCode)
    @store.codeStatus = Store.CodeStatus.Unknown
    @store.console.status = ''
    @store.editor.rowCode = rowCode
    @store.editor.ornamentalCode = TextConverter.decorate(escapedRowCode)

  # private
  setCodeWithCheck: (rowCode) ->
    code = try
      (new TypeChecker(mincamlParser.parse(rowCode))).check()
      @store.codeStatus = Store.CodeStatus.Ok
      @store.console.status = ''
      rowCode
    catch error
      if error instanceof UnexpectedTypeError
        @store.codeStatus = Store.CodeStatus.TypeError
        @store.console.status = "#{error.type.toString()} is expected " +
        "but the actual is #{error.ast.expType.toString()}"
        TextConverter.multiMark rowCode, [
          {location: error.ast.location, className: 'exp-error'}
        ]
      else if error instanceof UnboundVariableError
        @store.codeStatus = Store.CodeStatus.VarError
        @store.console.status = "Unbound variable `#{error.ast.string}`"
        TextConverter.multiMark rowCode, [
          {location: error.ast.location, className: 'exp-error'}
        ]
      else if error instanceof MismatchedTypeError
        @store.codeStatus = Store.CodeStatus.TypeError
        @store.console.status = "cannot unify " +
        "#{error.astA.expType.toString()} and #{error.astB.expType.toString()}"
        TextConverter.multiMark rowCode, [
          {location: error.astA.location, className: 'exp-error'},
          {location: error.astB.location, className: 'exp-error'}
        ]
      else if error.name == 'SyntaxError'
        @store.codeStatus = Store.CodeStatus.SyntaxError
        @store.console.status = if rowCode == '' then '' else error.message
        TextConverter.multiMark rowCode, [
          {location: error.location, className: 'position-error'}
        ]
      else
        throw error
    @store.editor.rowCode = rowCode
    @store.editor.ornamentalCode = TextConverter.decorate(code)

  setLineInfo: (rowCode) ->
    lc = TextConverter.lines(rowCode).length
    newMap = @store.editor.breakpointLineMap.slice(0, lc + 1)
    @store.editor.lineNumbers = lc
    @store.editor.breakpointLineMap = newMap

  setCaret: (leftPos, topPos) ->
    @store.editor.caretLeftPos = leftPos
    @store.editor.caretTopPos = topPos

  startProgram: (validRowCode) ->
    if @store.execution.status == Store.Execution.Stopping
      ast = mincamlParser.parse(validRowCode)
      (new TypeChecker(ast)).check()
      program = new Program(ast)
      Program.markLineHeads(ast)
      @store.execution.status = Store.Execution.Running
      @store.execution.program = program

  killProgram: () ->
    if @store.execution.status != Store.Execution.Stopping
      @store.execution.status = Store.Execution.Stopping
      @store.execution.program = null
      @store.editor.ornamentalCode =
        TextConverter.decorate(@store.editor.rowCode)

  stopBreaking: () ->
    if @store.execution.status == Store.Execution.Breaking
      @store.execution.status = Store.Execution.Running

  stepProgram: () ->
    if @store.execution.status == Store.Execution.Running
      program = @store.execution.program
      @store.console.status = ''
      @store.editor.ornamentalCode =
        TextConverter.decorate(@store.editor.rowCode)
      if program.terminated
        valueStr = Program.valueToString(program.cont)
        @store.console.results.push(valueStr)
        @killProgram()
        @store.console.status = 'Program terminated'
      else
        ast = program.cont.context.ast
        line = ast.location.start.line
        if @store.editor.breakpointLineMap[line] && ast.leftMost == true
          if program.cont.isIn() || program.cont.isBottom()
            @store.execution.status = Store.Execution.Breaking
            @store.console.status = "Breaking at #{ast.syntax} " +
            "from #{ast.location.start.line.toString()}:" +
            "#{ast.location.start.column}<br>" +
            "#{Program.envToString(program.cont.context.env)}"
            code = TextConverter.multiMark @store.editor.rowCode, [
              {location: ast.location, className: 'breaking-exp'}
            ]
            @store.editor.ornamentalCode = TextConverter.decorate(code)
      program.step()

  keytyped: (time) ->
    @store.editor.lastKeytypedTime = time

  focusEditor: ->
    @store.editor.focusing = true

  blurEditor: ->
    @store.editor.focusing = false

  setCurrentTime: (time) ->
    @store.currentTime = time

  toggleCaretFlashing: () ->
    @store.editor.caretFlashing = !@store.editor.caretFlashing

  setCaretVisible: ->
    @store.editor.caretVisible = unless @store.editor.focusing
      false
    else
      @store.nowTyping(500) || @store.editor.caretFlashing

  toggleBreakpoint: (lineNum) ->
    if @store.editor.breakpointLineMap[lineNum] == true
      @store.editor.breakpointLineMap[lineNum] = false
    else
      @store.editor.breakpointLineMap[lineNum] = true

if exports?
  exports.Store = Store
  exports.Dispatcher = Dispatcher
