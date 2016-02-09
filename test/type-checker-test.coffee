expect = require('chai').expect
{TypeChecker} = require  __dirname + '/../src/type-checker.coffee'
{TestingAST} = require  __dirname + '/testing-ast.coffee'

describe 'type-checker test', ->
  it 'simple if', ->
    ast = (new TestingAST()).simpleIf
    tc = new TypeChecker(ast)
    tc.check()
    expect(ast.expType.getTypeName()).to.equal("Int")
    expect(ast.condExp.expType.getTypeName()).to.equal("Bool")
    expect(ast.thenExp.expType.getTypeName()).to.equal("Int")
    expect(ast.elseExp.expType.getTypeName()).to.equal("Int")

  it 'simple let', ->
    ast = (new TestingAST()).simpleLet
    tc = new TypeChecker(ast)
    tc.check()
    expect(ast.expType.getTypeName()).to.equal("Int")
    expect(ast.varExp.expType.getTypeName()).to.equal("Int")
    expect(ast.bodyExp.expType.getTypeName()).to.equal("Int")

  it 'simple let-rec', ->
    ast = (new TestingAST()).simpleLetRec
    tc = new TypeChecker(ast)
    tc.check()
    expect(ast.expType.getTypeName()).to.equal("Int")
    expect(ast.funcExp.expType.getTypeName()).to.equal("Int")
    expect(ast.bodyExp.expType.getTypeName()).to.equal("Int")

  it 'simple let-tuple', ->
    ast = (new TestingAST()).simpleLetTuple
    tc = new TypeChecker(ast)
    tc.check()
    expect(ast.expType.getTypeName()).to.equal("Int")
    expect(ast.tupleExp.expType.getTypeName()).to.equal("Tuple")
    expect(ast.tupleExp.expType.getTypeArgs().length).to.equal(2)
    expect(ast.tupleExp.expType.getTypeArgs()[0].getTypeName()).to.equal("Int")
    expect(ast.tupleExp.expType.getTypeArgs()[1].getTypeName()).to.equal("Int")
    expect(ast.bodyExp.expType.getTypeName()).to.equal("Int")

  it 'binary-tree', ->
    ast = (new TestingAST()).binaryTree
    tc = new TypeChecker(ast)
    tc.check()
    expect(ast.expType.getTypeName()).to.equal("Int")
    expect(ast.leftExp.expType.getTypeName()).to.equal("Int")
    expect(ast.leftExp.leftExp.expType.getTypeName()).to.equal("Int")
    expect(ast.leftExp.rightExp.expType.getTypeName()).to.equal("Int")
    expect(ast.rightExp.expType.getTypeName()).to.equal("Int")
    expect(ast.rightExp.leftExp.expType.getTypeName()).to.equal("Int")
    expect(ast.rightExp.rightExp.expType.getTypeName()).to.equal("Int")

  it 'unary-tree', ->
    ast = (new TestingAST()).unaryTree
    tc = new TypeChecker(ast)
    tc.check()
    expect(ast.expType.getTypeName()).to.equal("Bool")
    expect(ast.exp.expType.getTypeName()).to.equal("Bool")
    expect(ast.exp.exp.expType.getTypeName()).to.equal("Bool")

  it 'parenthesis', ->
    ast = (new TestingAST()).parenthesis
    tc = new TypeChecker(ast)
    tc.check()
    expect(ast.expType.getTypeName()).to.equal("Int")
    expect(ast.exp.expType.getTypeName()).to.equal("Int")

  it 'tuple', ->
    ast = (new TestingAST()).tuple
    tc = new TypeChecker(ast)
    tc.check()
    expect(ast.expType.getTypeName()).to.equal("Tuple")
    expect(ast.expType.getTypeArgs().length).to.equal(2)
    expect(ast.expType.getTypeArgs()[0].getTypeName()).to.equal("Int")
    expect(ast.expType.getTypeArgs()[1].getTypeName()).to.equal("Int")
    expect(ast.exps[0].expType.getTypeName()).to.equal("Int")
    expect(ast.exps[1].expType.getTypeName()).to.equal("Int")
