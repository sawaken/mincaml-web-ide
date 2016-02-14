class Program
  constructor: (@ast) ->
    @cont = @evaluate(@ast, {})
    @terminated = false

  step: () ->
    unless @terminated
      @cont = @cont.step()
      @terminated = !(@cont instanceof Continuation)

  evaluate: (ast, env = {}) ->
    context = {ast: ast, env: env}
    switch ast.syntax
      when 'if'
        new Continuation context, 'in', =>
          @evaluate(ast.condExp, env).then (x) =>
            if x == true
              @evaluate(ast.thenExp, env).then (y) =>
                new Continuation context, 'out', => y
            else
              @evaluate(ast.elseExp, env).then (y) =>
                new Continuation context, 'out', => y
      when 'let'
        new Continuation context, 'in', =>
          @evaluate(ast.varExp, env).then (x) =>
            newEnv = [{"#{ast.varName.string}": x}].concat(env)
            @evaluate(ast.bodyExp, newEnv).then (y) =>
              new Continuation context, 'out', => y
      when 'let-rec'
        new Continuation context, 'in', =>
          closure = new Closure(env, ast.funcParamNames, ast.funcExp)
          closure.bindName(ast.funcName.string)
          @evaluate(ast.bodyExp, closure.env).then (y) =>
            new Continuation context, 'out', => y
      when 'let-tuple'
        new Continuation context, 'in', =>
          @evaluate(ast.tupleExp, env).then (t) =>
            newEnv = {}
            for v, idx in ast.varNames
              newEnv[v.string] = t[idx]
            @evaluate(ast.bodyExp, [newEnv].concat(env)).then (y) =>
              new Continuation context, 'out', => y
      when 'apply'
        new Continuation context, 'in', =>
          @evaluate(ast.leftExp, env).then (x) =>
            @evaluate(ast.rightExp, env).then (y) =>
              closure = x.apply(y)
              if closure.paramNames.length == 0
                @evaluate(closure.bodyExp, closure.env).then (z) =>
                  new Continuation context, 'out', => z
              else
                new Continuation context, 'out', => closure
      when 'eq', 'le', 'add', 'sub', 'mul', 'div'
        new Continuation context, 'in', =>
          @evaluate(ast.leftExp, env).then (x) =>
            @evaluate(ast.rightExp, env).then (y) =>
              new Continuation context, 'out', =>
                switch ast.syntax
                  when 'eq' then x == y
                  when 'le' then x <= y
                  when 'add' then x + y
                  when 'sub' then x - y
                  when 'mul' then x * y
                  when 'div' then x / y
      when 'not', 'neg'
        new Continuation context, 'in', =>
          @evaluate(ast.exp, env).then (x) =>
            new Continuation context, 'out', =>
              switch ast.syntax
                when 'not' then !x
                when 'neg' then -x
      when 'tuple'
        new Continuation context, 'in', =>
          @evaluateSeq ast.exps, env, (xs) =>
            new Continuation context, 'out', => xs
      when 'parenthesis'
        @evaluate(ast.exp, env)
      when 'var-ref'
        resolved = null
        for obj in env
          if obj.hasOwnProperty(ast.string)
            resolved = obj[ast.string]
            break
        new Continuation context, 'bottom', => resolved
      when 'bool'
        new Continuation context, 'bottom', => ast.bool
      when 'int'
        new Continuation context, 'bottom', => ast.number
      when 'unit'
        new Continuation context, 'bottom', => null

  evaluateSeq: (exps, env, f, xs = []) ->
    if exps.length > 0
      @evaluate(exps[0], env).then (x) =>
        @evaluateSeq(exps.slice(1), env, f, xs.concat([x]))
    else
      f(xs)

  # Class methods
  # ----------

  @markLineHeads = (ast) ->
    map = []
    for a in @flattenAST(ast)
      l = a.location.start.line
      o = a.location.start.column
      if map[l] == undefined || o < map[l].location.start.column
        map[l] = a
    for a in map
      a.leftMost = true if a != undefined

  @flattenAST = (ast) ->
    res = [ast]
    if ast.syntax == undefined || ast.syntax == 'identifier'
      []
    else if ast.syntax == 'parenthesis'
      @flattenAST(ast.exp)
    else
      for key, val of ast
        res = res.concat(@flattenAST(val))
      res

  @valueToString = (value) ->
    if value == null
      "unit"
    else if value instanceof Array
      '(' + (@valueToString(a) for a in value).join(', ') + ')'
    else
      value.toString()

  @envToString = (env) ->
    flat = {}
    for h in env
      for name, val of h
        flat[name] = val if flat[name] == undefined
    pairs = ("#{name}: #{@valueToString(val)}" for name, val of flat)
    '{' + pairs.join(', ') + '}'

class Closure
  constructor: (@env, @paramNames, @bodyExp) ->

  bindName: (name) ->
    @env = [{"#{name}": this}].concat(@env)

  apply: (value) ->
    firstParamName = @paramNames[0].string
    newEnv = [{"#{firstParamName}": value}].concat(@env)
    new Closure(newEnv, @paramNames.slice(1), @bodyExp)

  toString: ->
    '<#Closure>'

class Continuation
  constructor: (@context, @visitType, @step) ->

  isIn: ->
    @visitType == 'in'

  isOut: ->
    @visitType == 'out'

  isBottom: ->
    @visitType == 'bottom'

  then: (f) ->
    new Continuation @context, @visitType, =>
      if (c = @step()) instanceof Continuation
        c.then(f)
      else
        f(c)

if exports?
  exports.Program = Program
  exports.Closure = Closure
  exports.Continuation = Continuation
