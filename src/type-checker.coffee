{Type, UnifyError} = require __dirname + '/type.coffee' if require?

class TypeChecker
  constructor: (@ast) ->
    @idCounter = 0

  check: () ->
    @typing(@ast, [])

  newTypeVar: ->
    new Type(@idCounter++)

  newTupleType: (typeArgs) ->
    new Type(@idCounter++, 'Tuple', typeArgs)

  newFuncType: (left, right) ->
    new Type(@idCounter++, 'Func', [left, right])

  newIntType: ->
    new Type(@idCounter++, 'Int')

  newBoolType: ->
    new Type(@idCounter++, 'Bool')

  newUnitType: ->
    new Type(@idCounter++, 'Unit')

  unifyOneAST: (ast, type) ->
    try
      ast.expType.unify(type)
    catch error
      if error instanceof UnifyError
        throw new UnexpectedTypeError(ast, type)
      else
        throw error

  unifyTwoAST: (astA, astB) ->
    try
      astA.expType.unify(astB.expType)
    catch error
      if error instanceof UnifyError
        throw new MismatchedTypeError(astA, astB)
      else
        throw error

  typing: (ast, env) ->
    switch ast.syntax
      when 'if'
        @typing(ast.condExp, env)
        @typing(ast.thenExp, env)
        @typing(ast.elseExp, env)
        @unifyOneAST(ast.condExp, @newBoolType())
        @unifyTwoAST(ast.thenExp, ast.elseExp)
        ast.expType = ast.thenExp.expType
      when 'let'
        varType = @newTypeVar()
        newEnv = [{"#{ast.varName.string}": varType}].concat(env)
        @typing(ast.varExp, env)
        @typing(ast.bodyExp, newEnv)
        @unifyOneAST(ast.varExp, varType)
        ast.expType = ast.bodyExp.expType
      when 'let-rec'
        funcExpType = @newTypeVar()
        funcType = funcExpType
        varTable = {}
        for name in ast.funcParamNames.reverse()
          t = @newTypeVar()
          varTable[name.string] = t
          funcType = @newFuncType(t, funcType)
        newBodyEnv = [{"#{ast.funcName.string}": funcType}].concat(env)
        newFuncEnv = [varTable].concat(newBodyEnv)
        @typing(ast.funcExp, newFuncEnv)
        @unifyOneAST(ast.funcExp, funcExpType)
        ast.expType = @typing(ast.bodyExp, newBodyEnv)
      when 'let-tuple'
        @typing(ast.tupleExp, env)
        varTypes = (@newTypeVar() for _ in ast.varNames)
        @unifyOneAST(ast.tupleExp, @newTupleType(varTypes))
        varTable = {}
        for name, idx in ast.varNames
          varTable[name.string] = varTypes[idx]
        @typing(ast.bodyExp, [varTable].concat(env))
        ast.expType = ast.bodyExp.expType
      when 'apply'
        expType = @newTypeVar()
        funcType = @newFuncType(@typing(ast.rightExp, env), expType)
        @typing(ast.leftExp, env)
        @unifyOneAST(ast.leftExp, funcType)
        ast.expType = expType
      when 'eq', 'le', 'add', 'sub', 'mul', 'div'
        @typing(ast.leftExp, env)
        @typing(ast.rightExp, env)
        @unifyOneAST(ast.leftExp, @newIntType())
        @unifyOneAST(ast.rightExp, @newIntType())
        ast.expType = @newIntType()
      when 'not'
        @typing(ast.exp, env)
        @unifyOneAST(ast.exp, @newBoolType())
        ast.expType = @newBoolType()
      when 'neg'
        @typing(ast.exp, env)
        @unifyOneAST(ast.exp, @newIntType())
        ast.expType = @newIntType()
      when 'tuple'
        ast.expType = @newTupleType(@typing(e, env) for e in ast.exps)
      when 'parenthesis'
        ast.expType = @typing(ast.exp, env)
      when 'var-ref'
        resolved = null
        for obj in env
          if obj.hasOwnProperty(ast.string)
            resolved = obj[ast.string]
            break
        ast.expType = resolved
      when 'bool'
        ast.expType = @newBoolType()
      when 'int'
        ast.expType = @newIntType()
      when 'unit'
        ast.expType = @newUnitType()

class MismatchedTypeError extends Error
  constructor: (@astA, @astB) ->

class UnexpectedTypeError extends Error
  constructor: (@ast, @type) ->

if exports?
  exports.TypeChecker = TypeChecker
  exports.MismatchedTypeError = MismatchedTypeError
  exports.UnexpectedTypeError = UnexpectedTypeError
