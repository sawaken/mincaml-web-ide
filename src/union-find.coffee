class UnionFind
  constructor: ->
    @parent = null

  root: ->
    if @parent == null
      return this
    else
      return @parent = @parent.root()

  unite: (other) ->
    other.root().parent = this

  same: (other) ->
    this.root() == other.root()

exports.UnionFind = UnionFind if exports?


