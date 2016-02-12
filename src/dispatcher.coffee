class @Store
  constructor: () ->
    @caretLeftPos = 0
    @caretTopPos = 0
    @ornamentalCode = ""

class @Dispatcher
  constructor: (@store) ->

  setCode: (rowCode) ->
    @store.ornamentalCode = SourceCodeFormatter.decorate(rowCode)

  setCaret: (leftPos, topPos) ->
    @store.caretLeftPos = leftPos
    @store.caretTopPos = topPos
