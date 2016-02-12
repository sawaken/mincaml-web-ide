store = new Store()
dispatcher = new Dispatcher(store)

EditorBox = React.createClass
  getInitialState: ->
    store

  componentDidMount: ->
    setInterval (=> @setState(store)), 10

  render: ->
    <div>
      <span id="left-pos-scale" className="editor-cstyle"></span>
      <EditorBackPanel ornamentalCode={@state.ornamentalCode}/>
      <textarea id="editor-front-panel" className="panel-position editor-cstyle"
      spellCheck={false}
      ></textarea>
      <EditorCaret leftPos={@state.caretLeftPos} topPos={@state.caretTopPos}/>
    </div>

EditorCaret = React.createClass
  render: ->
    style = {left: @props.leftPos, top: @props.topPos}
    <div className="caret" style={style}></div>

EditorBackPanel = React.createClass
  render: ->
    <div id="editor-back-panel" className="panel-position editor-cstyle"
    dangerouslySetInnerHTML={{__html: @props.ornamentalCode}}></div>

$ ->
  ReactDOM.render <EditorBox/>, document.getElementById('editor-box')
  setInterval (=>
    code = $('#editor-front-panel').val()
    pos = document.getElementById('editor-front-panel').selectionStart
    {leftString, line} = SourceCodeFormatter.caret(code, pos)
    $('#left-pos-scale').html(leftString.replace(/\s/g, '&nbsp;'))
    leftPos = $('#left-pos-scale').width()
    topPos = $('#left-pos-scale').height() * (line - 1)
    dispatcher.setCode(code)
    dispatcher.setCaret(leftPos, topPos)
  ), 10
