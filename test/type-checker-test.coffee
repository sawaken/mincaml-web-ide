expect = require('chai').expect
{TypeChecker} = require  __dirname + '/../src/type-checker.coffee'
{TestingAST} = require  __dirname + '/testing-ast.coffee'

describe 'type-checker test', ->
  it 'simple if', ->
    ta = new TestingAST()
    tc = new TypeChecker(ta.simpleIf)
    tc.check()
    expect(ta.simpleIf.expType.getTypeName()).to.equal("Int")
    expect(ta.simpleIf.condExp.expType.getTypeName()).to.equal("Bool")
    expect(ta.simpleIf.thenExp.expType.getTypeName()).to.equal("Int")
    expect(ta.simpleIf.elseExp.expType.getTypeName()).to.equal("Int")

  it 'simple let', ->
    ta = new TestingAST()
    tc = new TypeChecker(ta.simpleLet)
    tc.check()
    expect(ta.simpleLet.expType.getTypeName()).to.equal("Int")
    expect(ta.simpleLet.varExp.expType.getTypeName()).to.equal("Int")
    expect(ta.simpleLet.bodyExp.expType.getTypeName()).to.equal("Int")

  it 'simple let-rec', ->
    ta = new TestingAST()
    tc = new TypeChecker(ta.simpleLetRec)
    tc.check()
    expect(ta.simpleLetRec.expType.getTypeName()).to.equal("Int")
    expect(ta.simpleLetRec.funcExp.expType.getTypeName()).to.equal("Int")
    expect(ta.simpleLetRec.bodyExp.expType.getTypeName()).to.equal("Int")

  it 'simple let-tuple', ->
    ta = new TestingAST()
    tc = new TypeChecker(ta.simpleLetTuple)
    tc.check()
    expect(ta.simpleLetTuple.expType.getTypeName()).to.equal("Int")
    expect(ta.simpleLetTuple.tupleExp.expType.getTypeName()).to.equal("Tuple")
    expect(ta.simpleLetTuple.tupleExp.expType.getTypeArgs().length).to.equal(2)
    expect(ta.simpleLetTuple.tupleExp.expType.getTypeArgs()[0].getTypeName()).to.equal("Int")
    expect(ta.simpleLetTuple.tupleExp.expType.getTypeArgs()[1].getTypeName()).to.equal("Int")
    expect(ta.simpleLetTuple.bodyExp.expType.getTypeName()).to.equal("Int")

  it 'binary-tree', ->
    ta = new TestingAST()
    tc = new TypeChecker(ta.binaryTree)
    tc.check()
    expect(ta.binaryTree.expType.getTypeName()).to.equal("Int")
    expect(ta.binaryTree.leftExp.expType.getTypeName()).to.equal("Int")
    expect(ta.binaryTree.leftExp.leftExp.expType.getTypeName()).to.equal("Int")
    expect(ta.binaryTree.leftExp.rightExp.expType.getTypeName()).to.equal("Int")
    expect(ta.binaryTree.rightExp.expType.getTypeName()).to.equal("Int")
    expect(ta.binaryTree.rightExp.leftExp.expType.getTypeName()).to.equal("Int")
    expect(ta.binaryTree.rightExp.rightExp.expType.getTypeName()).to.equal("Int")

  it 'unary-tree', ->
    ta = new TestingAST()
    tc = new TypeChecker(ta.unaryTree)
    tc.check()
    expect(ta.unaryTree.expType.getTypeName()).to.equal("Bool")
    expect(ta.unaryTree.exp.expType.getTypeName()).to.equal("Bool")
    expect(ta.unaryTree.exp.exp.expType.getTypeName()).to.equal("Bool")

  it 'parenthesis', ->
    ta = new TestingAST()
    tc = new TypeChecker(ta.parenthesis)
    tc.check()
    expect(ta.parenthesis.expType.getTypeName()).to.equal("Int")
    expect(ta.parenthesis.exp.expType.getTypeName()).to.equal("Int")

  it 'tuple', ->
    ta = new TestingAST()
    tc = new TypeChecker(ta.tuple)
    tc.check()
    expect(ta.tuple.expType.getTypeName()).to.equal("Tuple")
    expect(ta.tuple.expType.getTypeArgs().length).to.equal(2)
    expect(ta.tuple.expType.getTypeArgs()[0].getTypeName()).to.equal("Int")
    expect(ta.tuple.expType.getTypeArgs()[1].getTypeName()).to.equal("Int")
    expect(ta.tuple.exps[0].expType.getTypeName()).to.equal("Int")
    expect(ta.tuple.exps[1].expType.getTypeName()).to.equal("Int")





