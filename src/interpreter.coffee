class Program
  constructor: (ast) ->
    @cont = @evaluate(ast, {})
    @terminated = false

  step: () ->
    unless @terminated
      @cont = @cont.step()
      @terminated = !(@cont instanceof Continuation)

  evaluate: (ast, env = {}) ->
    @currentAST = ast
    @currentENV = env
    switch ast.syntax
      when 'if'
        new Continuation =>
          @evaluate(ast.condExp, env).then (x) =>
            if x == true
              @evaluate(ast.thenExp, env)
            else
              @evaluate(ast.elseExp, env)
      when 'let'
        new Continuation =>
          @evaluate(ast.varExp, env).then (x) =>
            @evaluate(ast.bodyExp, [{"#{ast.varName.string}": x}].concat(env))
      when 'let-rec'
        new Continuation =>
          closure = new Closure(env, ast.funcParamNames, ast.funcExp)
          closure.bindName(ast.funcName.string)
          @evaluate(ast.bodyExp, closure.env)
      when 'let-tuple'
        new Continuation =>
          @evaluate(ast.tupleExp, env).then (t) =>
            newEnv = {}
            for v, idx in ast.varNames
              newEnv[v.string] = t[idx]
            @evaluate(ast.bodyExp, [newEnv].concat(env))
      when 'apply'
        new Continuation =>
          @evaluate(ast.leftExp, env).then (x) =>
            @evaluate(ast.rightExp, env).then (y) =>
              closure = x.apply(y)
              if closure.paramNames.length == 0
                @evaluate(closure.bodyExp, closure.env)
              else
                closure
      when 'eq', 'le', 'add', 'sub', 'mul', 'div'
        new Continuation =>
          @evaluate(ast.leftExp, env).then (x) =>
            @evaluate(ast.rightExp, env).then (y) =>
              switch ast.syntax
                when 'eq' then x == y
                when 'le' then x <= y
                when 'add' then x + y
                when 'sub' then x - y
                when 'mul' then x * y
                when 'div' then x / y
      when 'not', 'neg'
        new Continuation =>
          @evaluate(ast.exp, env).then (x) =>
            switch ast.syntax
              when 'not' then !x
              when 'neg' then -x
      when 'tuple'
        new Continuation =>
          @evaluateSeq ast.exps, (xs) => xs
      when 'parenthesis'
        @evaluate(ast.exp, env)
      when 'var-ref'
        resolved = null
        for obj in env
          if obj.hasOwnProperty(ast.string)
            resolved = obj[ast.string]
            break
        new Continuation -> resolved
      when 'bool'
        new Continuation -> ast.bool
      when 'int'
        new Continuation -> ast.number
      when 'unit'
        new Continuation -> null

  evaluateSeq: (exps, f, xs = []) ->
    if exps.length > 0
      @evaluate(exps[0]).then (x) =>
        @evaluateSeq(exps.slice(1), f, xs.concat([x]))
    else
      f(xs)

class Closure
  constructor: (@env, @paramNames, @bodyExp) ->

  bindName: (name) ->
    @env = [{"#{name}": this}].concat(@env)

  apply: (value) ->
    firstParamName = @paramNames[0].string
    newEnv = [{"#{firstParamName}": value}].concat(@env)
    new Closure(newEnv, @paramNames.slice(1), @bodyExp)

class Continuation
  constructor: (@step) ->

  then: (f) ->
    new Continuation () =>
      if (c = @step()) instanceof Continuation
        c.then(f)
      else
        f(c)

if exports?
  exports.Program = Program
  exports.Closure = Closure
  exports.Continuation = Continuation
