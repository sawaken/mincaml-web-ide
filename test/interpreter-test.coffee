expect = require('chai').expect
{Program, Closure, Continuation} = require  __dirname + '/../src/interpreter.coffee'

describe 'interpreter test', ->
  simpleIf =
    syntax: 'if'
    condExp: {syntax: 'bool', bool: true}
    thenExp: {syntax: 'int', number: 1}
    elseExp: {syntax: 'int', number: 2}

  simpleLet =
    syntax: 'let'
    varName: {syntax: 'identifier', string: 'x'}
    varExp: {syntax: 'int', number: 1}
    bodyExp: {syntax: 'var-ref', string: 'x'}

  simpleLetRec =
    syntax: 'let-rec'
    funcName: {syntax: 'identifier', string: 'f'}
    funcParamNames: [
      {syntax: 'identifier', string: 'x'}
      {syntax: 'identifier', string: 'y'}
    ]
    funcExp:
      syntax: 'add'
      leftExp: {syntax: 'var-ref', string: 'x'}
      rightExp: {syntax: 'var-ref', string: 'y'}
    bodyExp:
      syntax: 'apply'
      leftExp:
        syntax: 'apply'
        leftExp: {syntax: 'var-ref', string: 'f'}
        rightExp: {syntax: 'int', number: 1}
      rightExp: {syntax: 'int', number: 1}

  simpleLetTuple =
    syntax: 'let-tuple'
    varNames: [
      {syntax: 'identifier', string: 'x'},
      {syntax: 'identifier', string: 'y'}
    ]
    tupleExp:
      syntax: 'tuple'
      exps: [
        {syntax: 'int', number: 1},
        {syntax: 'int', number: 2}
      ]
    bodyExp:
      syntax: 'add'
      leftExp: {syntax: 'var-ref', string: 'x'}
      rightExp: {syntax: 'var-ref', string: 'y'}

  binaryTree =
    syntax: 'add'
    leftExp:
      syntax: 'sub'
      leftExp: {syntax: 'int', number: 1}
      rightExp: {syntax: 'int', number: 2}
    rightExp:
      syntax: 'mul'
      leftExp: {syntax: 'int', number: 3}
      rightExp: {syntax: 'int', number: 4}

  unaryTree =
    syntax: 'not'
    exp:
      syntax: 'not'
      exp: {syntax: 'bool', bool: true}

  parenthesis =
    syntax: 'parenthesis'
    exp: {syntax: 'int', number: 1}

  tuple =
    syntax: 'tuple'
    exps: [
      {syntax: 'int', number: 1},
      {syntax: 'int', number: 2}
    ]

  it 'simple if', ->
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
    p = new Program(simpleLet)
    expect(p.currentAST).to.equal(simpleLet)
    p.step()
    expect(p.currentAST).to.equal(simpleLet.varExp)
    p.step()
    expect(p.currentAST).to.equal(simpleLet.bodyExp)
    p.step()
    expect(p.cont).to.equal(1)

  it 'simple let-rec', ->
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
    p = new Program(unaryTree)
    expect(p.currentAST).to.equal(unaryTree)
    p.step()
    expect(p.currentAST).to.equal(unaryTree.exp)
    p.step()
    expect(p.currentAST).to.equal(unaryTree.exp.exp)
    p.step()
    expect(p.cont).to.equal(true)

  it 'parenthesis', ->
    p = new Program(parenthesis)
    expect(p.currentAST).to.equal(parenthesis.exp)
    p.step()
    expect(p.cont).to.equal(1)

  it 'tuple', ->
    p = new Program(tuple)
    expect(p.currentAST).to.equal(tuple)
    p.step()
    expect(p.currentAST).to.equal(tuple.exps[0])
    p.step()
    expect(p.currentAST).to.equal(tuple.exps[1])
    p.step()
    expect(p.cont).to.eql([1, 2])