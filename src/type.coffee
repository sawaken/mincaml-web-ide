class Type
  constructor: (@id, @typeName = null, @typeArgs = []) ->
    @parent = null

  root: ->
    unless @parent == null
      @parent = @parent.root()
    else
      this

  getTypeName: ->
    @root().typeName

  getTypeArgs: ->
    @root().typeArgs

  unify: (other) ->
    return if this.same(other)
    if this.getTypeName() != null && other.getTypeName() != null
      unless this.getTypeName() == other.getTypeName()
        throw new UnifyError(this, other)
      unless this.getTypeArgs().length == other.getTypeArgs().length
        throw new UnifyError(this, other)
      for v, idx in this.getTypeArgs()
        v.unify(other.getTypeArgs()[idx])
      this.root().parent = other
    else if this.getTypeName() == null && other.getTypeName() != null
      if other.occurCheck(this)
        this.root().parent = other
      else
        throw new UnifyError(this, other)
    else if this.getTypeName() != null && other.getTypeName() == null
      if this.occurCheck(other)
        other.root().parent = this
      else
        throw new UnifyError(this, other)
    else if this.getTypeName() == null && other.getTypeName() == null
      this.root().parent = other

  occurCheck: (t) ->
    return false if @same(t)
    for ch in @getTypeArgs()
      return false unless ch.occurCheck(t)
    true

  same: (other) ->
    this.root() == other.root()

  toString: ->
    if @getTypeName() == null
      'a' + @root().id.toString()
    else
      switch @getTypeName()
        when 'Func'
          [l, r] = @getTypeArgs()
          leftStr = if l.getTypeName() == 'Func'
            "(#{l.toString()})"
          else
            l.toString()
          rightStr = r.toString()
          leftStr + ' -> ' + rightStr
        when 'Tuple'
          '(' + (a.toString() for a in @getTypeArgs()).join(', ') + ')'
        else
          @getTypeName()

class UnifyError extends Error
  constructor: (@a, @b) ->

  toString: ->
    "Cannot unify #{@a.toString()} and #{@b.toString()}"

if exports?
  exports.Type = Type
  exports.UnifyError = UnifyError
