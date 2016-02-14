store = new Store()
dispatcher = new Dispatcher(store)

Root = React.createClass
  getInitialState: ->
    store

  componentDidMount: ->
    setInterval (=> @setState(store)), 20

  render: ->
    <div className="container-fluid full-height ide-whole">
      <div className="row bg-inverse card-header ide-header">
        <div className="container">
          <h2 className="text-md-center">MinCaml Web IDE</h2>
        </div>
      </div>
      <div className="row ide-content">
        <LeftBox
          editor={@state.editor}
          codeStatus={@state.codeStatus}
          execution={@state.execution}
        />
        <RightBox console={@state.console}/>
      </div>
    </div>

LeftBox = React.createClass
  stopping: ->
    @props.execution.status == Store.Execution.Stopping

  runButtonDisplay: ->
    if @stopping() && @props.codeStatus == Store.CodeStatus.Ok
      {}
    else
      {display: 'none'}

  stopButtonDisplay: ->
    if @stopping() then {display: 'none'} else {}

  continueButtonDisplay: ->
    if @props.execution.status == Store.Execution.Breaking
      {}
    else
      {display: 'none'}

  codeStatus: ->
    switch @props.execution.status
      when Store.Execution.Running
        <span>
          <i className="fa fa-cog fa-spin color-thin"></i>
          <span className="editor-cstyle color-thin">Now Running...</span>
        </span>
      when Store.Execution.Breaking
        <span>
          <i className="fa fa-stop color-thin"></i>
          <span className="editor-cstyle color-thin">Now Breaking...</span>
        </span>
      when Store.Execution.Stopping
        switch @props.codeStatus
          when Store.CodeStatus.Unknown
            <span>
              <i className="fa fa-spinner fa-spin color-thin"></i>
              <span className="editor-cstyle color-thin">Now Editing...</span>
            </span>
          when Store.CodeStatus.Ok
            <span>
              <i className="fa fa-check color-green"></i>
              <span className="editor-cstyle color-green">Syntax OK</span>
            </span>
          when Store.CodeStatus.TypeError
            <span>
              <i className="fa fa-times color-red"></i>
              <span className="editor-cstyle color-red">Type Error</span>
            </span>
          when Store.CodeStatus.SyntaxError
            if @props.editor.rowCode == ''
              <span></span>
            else
              <span>
                <i className="fa fa-times color-red"></i>
                <span className="editor-cstyle color-red">Syntax Error</span>
              </span>
          when Store.CodeStatus.VarError
            <span>
              <i className="fa fa-times color-red"></i>
              <span className="editor-cstyle color-red">Unbound Variable</span>
            </span>

  render: ->
    <div className="col-xs-6 bg-grey ide-left">
      <div className="row ide-left-header">

      </div>
      <div className="row ide-left-content">
        <LineNumberObi count={@props.editor.lineNumbers}/>
        <BreakpointObi
          count={@props.editor.lineNumbers}
          map={@props.editor.breakpointLineMap}
        />
        <EditorBox
          editor={@props.editor}
          codeStatus={@props.codeStatus}
          execution={@props.execution}
        />
      </div>
      <div className="row ide-left-status">
        <div className="col-xs-1 editor-status-a"></div>
        <div className="col-xs-1 editor-status-b"></div>
        <div className="col-xs-10 editor-status-c">
          {@codeStatus()}
        </div>
      </div>
      <div className="row ide-left-footer">
        <span className="btn-position">
          <a className="btn btn-primary btn-md" role="button"
            onClick={=> dispatcher.startProgram(@props.editor.rowCode)}
            style={@runButtonDisplay()}>
            <i className="fa fa-play"></i> Run
          </a>
        </span>
        <span className="btn-position">
          <a className="btn btn-primary btn-md" role="button"
            onClick={=> dispatcher.killProgram()}
            style={@stopButtonDisplay()}>
            <i className="fa fa-stop"></i> Stop
          </a>
        </span>
        <span className="btn-position">
          <a className="btn btn-primary btn-md" role="button"
            onClick={=> dispatcher.stopBreaking()}
            style={@continueButtonDisplay()}>
            <i className="fa fa-play"></i> Continue
          </a>
        </span>
      </div>
    </div>

LineNumberObi = React.createClass
  render: ->
    <div className="col-xs-1 editor-cstyle editor-line-obi">
      {[1..(@props.count)].map (i) -> <div key={i}>{i}</div>}
    </div>

BreakpointObi = React.createClass
  render: ->
    xs = [1..(@props.count)].map (i) =>
      toggle = (=> dispatcher.toggleBreakpoint(i))
      if @props.map[i] == true
        <div key={i} className="bpoint clickable" onClick={toggle}>
          <i className="fa fa-circle break-point-symbol clickable"></i>
        </div>
      else
        <div key={i} className="bpoint clickable" onClick={toggle}></div>
    <div className="col-xs-1 editor-cstyle editor-line-obi">
      {xs}
    </div>

RightBox = React.createClass
  render: ->
    <div className="col-xs-6 bg-grey ide-right">
      <div className="modal-header ide-screen-header">
        <h1><small>status</small></h1>
      </div>
      <div
        className="bg-inverse editor-cstyle ide-screen"
        dangerouslySetInnerHTML={{__html: @props.console.status}}
      ></div>
      <div className="modal-header ide-screen-header">
        <h1><small>result</small></h1>
      </div>
      <div className="bg-inverse editor-cstyle ide-screen">
        {<div key={i}>{x}</div> for x, i in @props.console.results}
      </div>
    </div>

EditorBox = React.createClass
  editable: ->
    @props.execution.status == Store.Execution.Stopping

  render: ->
    touch = (=> dispatcher.keytyped(Date.now()))
    <div className="col-xs-10 bg-inverse editor-box">
      <span
        id="left-pos-scale"
        className="editor-cstyle left-pos-scale"
      ></span>
      <EditorBackPanel
        ornamentalCode={@props.editor.ornamentalCode}
        lineNumbers={@props.editor.lineNumbers}
      />
      <textarea
        id="editor-front-panel"
        className="panel-position editor-cstyle editor-front-panel"
        spellCheck={false}
        onKeyDown={touch} onKeyUp={touch} onKeyPress={touch} onPaste={touch}
        onFocus={=> dispatcher.focusEditor()}
        onBlur={=> dispatcher.blurEditor()}
        style={{height: ((1.2 * @props.editor.lineNumbers) + 2.0) + 'em'}}
        readOnly={!@editable()}
      ></textarea>
      <EditorCaret
        leftPos={@props.editor.caretLeftPos}
        topPos={@props.editor.caretTopPos}
        visible={@props.editor.caretVisible}
      />
    </div>

EditorCaret = React.createClass
  render: ->
    style =
      left: @props.leftPos
      top: @props.topPos
      display: if @props.visible then '' else 'none'
    <div className="caret" style={style}></div>

EditorBackPanel = React.createClass
  render: ->
    <div className="panel-position editor-cstyle editor-back-panel"
      id="editor-back-panel"
      dangerouslySetInnerHTML={{__html: @props.ornamentalCode}}
      style={{height: ((1.2 * @props.lineNumbers) + 2.0) + 'em'}}
    ></div>

$ ->
  ReactDOM.render <Root/>, document.getElementById('ide-view')
  setInterval (=>
    code = $('#editor-front-panel').val()
    pos = document.getElementById('editor-front-panel').selectionStart
    {leftString, line} = TextConverter.caret(code, pos)
    leftStringTagDeleted = TextConverter.escapeTag(leftString)
    $('#left-pos-scale').html(leftStringTagDeleted.replace(/\s/g, '&nbsp;'))
    leftPos = $('#left-pos-scale').width()
    topPos = (1.2 * (line - 1)) + 'em'
    dispatcher.setCode(code.replace(/\r\n/g, '\n'))
    dispatcher.setLineInfo(code)
    dispatcher.setCaret(leftPos, topPos)
    dispatcher.setCurrentTime(Date.now())
    dispatcher.stepProgram()
    dispatcher.setCaretVisible()
  ), 20
  setInterval (=>
    dispatcher.toggleCaretFlashing()
  ), 500
