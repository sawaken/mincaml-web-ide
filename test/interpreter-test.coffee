expect = require('chai').expect
{
  Program,
  Closure,
  Continuation
} = require  __dirname + '/../src/interpreter.coffee'
{TestingAST} = require  __dirname + '/testing-ast.coffee'

describe 'interpreter test', ->
  it 'simple if', ->
    simpleIf = (new TestingAST()).simpleIf
    p = new Program(simpleIf)
    expect(p.terminated).to.be.false
    expect(p.currentAST).to.equal(simpleIf)
    p.step()
    expect(p.terminated).to.be.false
    expect(p.currentAST).to.equal(simpleIf.condExp)
    p.step()
    expect(p.terminated).to.be.false
    expect(p.currentAST).to.equal(simpleIf.thenExp)
    p.step()
    expect(p.terminated).to.be.true
    expect(p.cont).to.equal(1)

  it 'simple let', ->
    simpleLet = (new TestingAST()).simpleLet
    p = new Program(simpleLet)
    expect(p.currentAST).to.equal(simpleLet)
    p.step()
    expect(p.currentAST).to.equal(simpleLet.varExp)
    p.step()
    expect(p.currentAST).to.equal(simpleLet.bodyExp)
    p.step()
    expect(p.cont).to.equal(1)

  it 'simple let-rec', ->
    simpleLetRec = (new TestingAST()).simpleLetRec
    p = new Program(simpleLetRec)
    expect(p.currentAST).to.equal(simpleLetRec)
    p.step()
    expect(p.currentAST).to.equal(simpleLetRec.bodyExp)
    p.step()
    expect(p.currentAST).to.equal(simpleLetRec.bodyExp.leftExp)
    p.step()
    expect(p.currentAST).to.equal(simpleLetRec.bodyExp.leftExp.leftExp)
    p.step()
    expect(p.currentAST).to.equal(simpleLetRec.bodyExp.leftExp.rightExp)
    p.step()
    expect(p.currentAST).to.equal(simpleLetRec.bodyExp.rightExp)
    p.step()
    expect(p.currentAST).to.equal(simpleLetRec.funcExp)
    p.step()
    expect(p.currentAST).to.equal(simpleLetRec.funcExp.leftExp)
    p.step()
    expect(p.currentAST).to.equal(simpleLetRec.funcExp.rightExp)
    p.step()
    expect(p.cont).to.equal(2)

  it 'simple let-tuple', ->
    simpleLetTuple = (new TestingAST()).simpleLetTuple
    p = new Program(simpleLetTuple)
    expect(p.currentAST).to.equal(simpleLetTuple)
    p.step()
    expect(p.currentAST).to.equal(simpleLetTuple.tupleExp)
    p.step()
    expect(p.currentAST).to.equal(simpleLetTuple.tupleExp.exps[0])
    p.step()
    expect(p.currentAST).to.equal(simpleLetTuple.tupleExp.exps[1])
    p.step()
    expect(p.currentAST).to.equal(simpleLetTuple.bodyExp)
    p.step()
    expect(p.currentAST).to.equal(simpleLetTuple.bodyExp.leftExp)
    p.step()
    expect(p.currentAST).to.equal(simpleLetTuple.bodyExp.rightExp)
    p.step()
    expect(p.cont).to.equal(3)

  it 'binary tree', ->
    binaryTree = (new TestingAST()).binaryTree
    p = new Program(binaryTree)
    expect(p.currentAST).to.equal(binaryTree)
    p.step()
    expect(p.currentAST).to.equal(binaryTree.leftExp)
    p.step()
    expect(p.currentAST).to.equal(binaryTree.leftExp.leftExp)
    p.step()
    expect(p.currentAST).to.equal(binaryTree.leftExp.rightExp)
    p.step()
    expect(p.currentAST).to.equal(binaryTree.rightExp)
    p.step()
    expect(p.currentAST).to.equal(binaryTree.rightExp.leftExp)
    p.step()
    expect(p.currentAST).to.equal(binaryTree.rightExp.rightExp)
    p.step()
    expect(p.cont).to.equal(11)

  it 'unary tree', ->
    unaryTree = (new TestingAST()).unaryTree
    p = new Program(unaryTree)
    expect(p.currentAST).to.equal(unaryTree)
    p.step()
    expect(p.currentAST).to.equal(unaryTree.exp)
    p.step()
    expect(p.currentAST).to.equal(unaryTree.exp.exp)
    p.step()
    expect(p.cont).to.equal(true)

  it 'parenthesis', ->
    parenthesis = (new TestingAST()).parenthesis
    p = new Program(parenthesis)
    expect(p.currentAST).to.equal(parenthesis.exp)
    p.step()
    expect(p.cont).to.equal(1)

  it 'tuple', ->
    tuple = (new TestingAST()).tuple
    p = new Program(tuple)
    expect(p.currentAST).to.equal(tuple)
    p.step()
    expect(p.currentAST).to.equal(tuple.exps[0])
    p.step()
    expect(p.currentAST).to.equal(tuple.exps[1])
    p.step()
    expect(p.cont).to.eql([1, 2])
