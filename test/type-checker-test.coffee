{expect, assert} = require('chai')
{
  TypeChecker,
  MismatchedTypeError,
  UnexpectedTypeError,
  UnboundVariableError
} = require  __dirname + '/../src/type-checker.coffee'
{TestingAST} = require  __dirname + '/testing-ast.coffee'

describe 'type-checker test', ->

  # test utils
  # ----------

  errorTest = (astName, testProc) ->
    ast = (new TestingAST())[astName]
    tc = new TypeChecker(ast)
    try
      tc.check()
    catch error
      testProc(ast, error)
      return
    assert(false, 'An error is expected but nothing has ocurred')

  test = (astName, testProc) ->
    ast = (new TestingAST())[astName]
    tc = new TypeChecker(ast)
    tc.check()
    testProc(ast)

  # tests for ASTs with valid typing
  # ----------

  it 'simple if', ->
    test 'simpleIf', (ast) ->
      expect(ast.expType.getTypeName()).to.equal('Int')
      expect(ast.condExp.expType.getTypeName()).to.equal('Bool')
      expect(ast.thenExp.expType.getTypeName()).to.equal('Int')
      expect(ast.elseExp.expType.getTypeName()).to.equal('Int')

  it 'simple let', ->
    test 'simpleLet', (ast) ->
      expect(ast.expType.getTypeName()).to.equal('Int')
      expect(ast.varExp.expType.getTypeName()).to.equal('Int')
      expect(ast.bodyExp.expType.getTypeName()).to.equal('Int')

  it 'simple let-rec', ->
    test 'simpleLetRec', (ast) ->
      expect(ast.expType.getTypeName()).to.equal('Int')
      expect(ast.funcExp.expType.getTypeName()).to.equal('Int')
      expect(ast.bodyExp.expType.getTypeName()).to.equal('Int')

  it 'simple let-tuple', ->
    test 'simpleLetTuple', (ast) ->
      expect(ast.expType.getTypeName()).to.equal('Int')
      expect(ast.tupleExp.expType.getTypeName()).to.equal('Tuple')
      expect(ast.tupleExp.expType.getTypeArgs().length).to.equal(2)
      tupleTypes = ast.tupleExp.expType.getTypeArgs()
      expect(tupleTypes[0].getTypeName()).to.equal('Int')
      expect(tupleTypes[1].getTypeName()).to.equal('Int')
      expect(ast.bodyExp.expType.getTypeName()).to.equal('Int')

  it 'binary-tree', ->
    test 'binaryTree', (ast) ->
      expect(ast.expType.getTypeName()).to.equal('Int')
      expect(ast.leftExp.expType.getTypeName()).to.equal('Int')
      expect(ast.leftExp.leftExp.expType.getTypeName()).to.equal('Int')
      expect(ast.leftExp.rightExp.expType.getTypeName()).to.equal('Int')
      expect(ast.rightExp.expType.getTypeName()).to.equal('Int')
      expect(ast.rightExp.leftExp.expType.getTypeName()).to.equal('Int')
      expect(ast.rightExp.rightExp.expType.getTypeName()).to.equal('Int')

  it 'unary-tree', ->
    test 'unaryTree', (ast) ->
      expect(ast.expType.getTypeName()).to.equal('Bool')
      expect(ast.exp.expType.getTypeName()).to.equal('Bool')
      expect(ast.exp.exp.expType.getTypeName()).to.equal('Bool')

  it 'parenthesis', ->
    test 'parenthesis', (ast) ->
      expect(ast.expType.getTypeName()).to.equal('Int')
      expect(ast.exp.expType.getTypeName()).to.equal('Int')

  it 'tuple', ->
    test 'tuple', (ast) ->
      expect(ast.expType.getTypeName()).to.equal('Tuple')
      expect(ast.expType.getTypeArgs().length).to.equal(2)
      expect(ast.expType.getTypeArgs()[0].getTypeName()).to.equal('Int')
      expect(ast.expType.getTypeArgs()[1].getTypeName()).to.equal('Int')
      expect(ast.exps[0].expType.getTypeName()).to.equal('Int')
      expect(ast.exps[1].expType.getTypeName()).to.equal('Int')

  # tests for ASTs with invalid typing
  # ----------

  it 'if with type error 1', ->
    errorTest 'ifWithTypeError1', (ast, error) ->
      expect(error).to.be.instanceof(UnexpectedTypeError)
      expect(error.ast).to.equal(ast.condExp)
      expect(error.type.getTypeName()).to.equal('Bool')

  it 'if with type error 2', ->
    errorTest 'ifWithTypeError2', (ast, error) ->
      expect(error).to.be.instanceof(MismatchedTypeError)
      expect(error.astA).to.equal(ast.thenExp)
      expect(error.astB).to.equal(ast.elseExp)

  it 'let-rec with type error', ->
    errorTest 'letRecWithTypeError', (ast, error) ->
      expect(error).to.be.instanceof(UnexpectedTypeError)
      expect(error.ast).to.equal(ast.funcExp)
      expect(error.ast.expType.toString()).to.equal('(a3, Int)')
      expect(error.type.toString()).to.equal('a3')
      # note: a3 is constant but depending implementation

  it 'let-tuple with type error 1', ->
    errorTest 'letTupleWithTypeError1', (ast, error) ->
      expect(error).to.be.instanceof(UnexpectedTypeError)
      expect(error.ast).to.equal(ast.tupleExp)
      expect(error.ast.expType.getTypeArgs().length)
        .to.be.not.equal(error.type.getTypeArgs().length)

  it 'let-tuple with type error 2', ->
    errorTest 'letTupleWithTypeError2', (ast, error) ->
      expect(error).to.be.instanceof(UnexpectedTypeError)
      expect(error.ast).to.equal(ast.tupleExp)
      expect(error.ast.expType.getTypeName()).to.equal('Unit')
      expect(error.type.getTypeName()).to.equal('Tuple')

  it 'apply with type error', ->
    errorTest 'applyWithTypeError', (ast, error) ->
      expect(error).to.be.instanceof(UnexpectedTypeError)
      expect(error.ast.expType.toString()).to.equal('Int')
      expect(error.type.toString()).to.equal('Int -> a0')
      # note: a0 is constant but depending implementation

  it 'add with type error left', ->
    errorTest 'addWithTypeErrorLeft', (ast, error) ->
      expect(error).to.be.instanceof(UnexpectedTypeError)
      expect(error.ast.expType.toString()).to.equal('Bool')
      expect(error.type.toString()).to.equal('Int')

  it 'add with type error right', ->
    errorTest 'addWithTypeErrorRight', (ast, error) ->
      expect(error).to.be.instanceof(UnexpectedTypeError)
      expect(error.ast.expType.toString()).to.equal('Bool')
      expect(error.type.toString()).to.equal('Int')

  it 'not with type error', ->
    errorTest 'notWithTypeError', (ast, error) ->
      expect(error).to.be.instanceof(UnexpectedTypeError)
      expect(error.ast.expType.toString()).to.equal('Int')
      expect(error.type.toString()).to.equal('Bool')

  it 'neg with type error', ->
    errorTest 'negWithTypeError', (ast, error) ->
      expect(error).to.be.instanceof(UnexpectedTypeError)
      expect(error.ast.expType.toString()).to.equal('Bool')
      expect(error.type.toString()).to.equal('Int')

  # a test fpr unbound variables
  # ----------

  it 'unbound variable', ->
    errorTest 'unboundVar', (ast, error) ->
      expect(error).to.be.instanceof(UnboundVariableError)
      expect(error.ast.string).to.equal('x')
