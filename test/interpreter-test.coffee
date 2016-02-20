expect = require('chai').expect
{
  Program,
  Closure,
  Continuation
} = require  __dirname + '/../src/interpreter.coffee'
{TestingAST} = require  __dirname + '/testing-ast.coffee'

describe 'interpreter test', ->
  test = (astName, testProc) ->
    ast = (new TestingAST)[astName]
    program = new Program(ast)
    testProc(ast, program)

  it 'termination', ->
    test 'int', (ast, p) ->
      expect(p.terminated).to.be.false
      p.step()
      expect(p.terminated).to.be.true
      expect(p.cont).to.equal(1)

  it 'simple if', ->
    test 'simpleIf', (ast, p) ->
      expect(p.cont.context.ast).to.equal(ast)
      expect(p.cont.isIn()).to.be.true
      p.step()
      expect(p.cont.context.ast).to.equal(ast.condExp)
      expect(p.cont.isBottom()).to.be.true
      p.step()
      expect(p.cont.context.ast).to.equal(ast.thenExp)
      expect(p.cont.isBottom()).to.be.true
      p.step()
      expect(p.cont.context.ast).to.equal(ast)
      expect(p.cont.isOut()).to.be.true
      p.step()
      expect(p.cont).to.equal(1)

  it 'simple let', ->
    test 'simpleLet', (ast, p) ->
      expect(p.cont.context.ast).to.equal(ast)
      expect(p.cont.isIn()).to.be.true
      p.step()
      expect(p.cont.context.ast).to.equal(ast.varExp)
      expect(p.cont.isBottom()).to.be.true
      p.step()
      expect(p.cont.context.ast).to.equal(ast.bodyExp)
      expect(p.cont.isBottom()).to.be.true
      p.step()
      expect(p.cont.context.ast).to.equal(ast)
      expect(p.cont.isOut()).to.be.true
      p.step()
      expect(p.cont).to.equal(1)

  it 'simple let-rec', ->
    test 'simpleLetRec', (ast, p) ->
      expect(p.cont.context.ast).to.equal(ast)
      expect(p.cont.isIn()).to.be.true
      # enter body
      p.step()
      expect(p.cont.context.ast).to.equal(ast.bodyExp)
      expect(p.cont.isIn()).to.be.true
      p.step()
      expect(p.cont.context.ast).to.equal(ast.bodyExp.leftExp)
      expect(p.cont.isIn()).to.be.true
      p.step()
      expect(p.cont.context.ast).to.equal(ast.bodyExp.leftExp.leftExp)
      expect(p.cont.isBottom()).to.be.true
      p.step()
      expect(p.cont.context.ast).to.equal(ast.bodyExp.leftExp.rightExp)
      expect(p.cont.isBottom()).to.be.true
      p.step()
      expect(p.cont.context.ast).to.equal(ast.bodyExp.leftExp)
      expect(p.cont.isOut()).to.be.true
      p.step()
      expect(p.cont.context.ast).to.equal(ast.bodyExp.rightExp)
      expect(p.cont.isBottom()).to.be.true
      # enter function
      p.step()
      expect(p.cont.context.ast).to.equal(ast.funcExp)
      expect(p.cont.isIn()).to.be.true
      p.step()
      expect(p.cont.context.ast).to.equal(ast.funcExp.leftExp)
      expect(p.cont.isBottom()).to.be.true
      p.step()
      expect(p.cont.context.ast).to.equal(ast.funcExp.rightExp)
      expect(p.cont.isBottom()).to.be.true
      p.step()
      expect(p.cont.context.ast).to.equal(ast.funcExp)
      expect(p.cont.isOut()).to.be.true
      # leave function
      p.step()
      expect(p.cont.context.ast).to.equal(ast.bodyExp)
      expect(p.cont.isOut()).to.be.true
      # leave body
      p.step()
      expect(p.cont.context.ast).to.equal(ast)
      expect(p.cont.isOut()).to.be.true
      p.step()
      expect(p.cont).to.equal(-1)

  it 'simple let-tuple', ->
    test 'simpleLetTuple', (ast, p) ->
      expect(p.cont.context.ast).to.equal(ast)
      expect(p.cont.isIn()).to.be.true
      # enter tuple-exp
      p.step()
      expect(p.cont.context.ast).to.equal(ast.tupleExp)
      expect(p.cont.isIn()).to.be.true
      p.step()
      expect(p.cont.context.ast).to.equal(ast.tupleExp.exps[0])
      expect(p.cont.isBottom()).to.be.true
      p.step()
      expect(p.cont.context.ast).to.equal(ast.tupleExp.exps[1])
      expect(p.cont.isBottom()).to.be.true
      p.step()
      expect(p.cont.context.ast).to.equal(ast.tupleExp)
      expect(p.cont.isOut()).to.be.true
      # enter body-exp
      p.step()
      expect(p.cont.context.ast).to.equal(ast.bodyExp)
      expect(p.cont.isIn()).to.be.true
      p.step()
      expect(p.cont.context.ast).to.equal(ast.bodyExp.leftExp)
      expect(p.cont.isBottom()).to.be.true
      p.step()
      expect(p.cont.context.ast).to.equal(ast.bodyExp.rightExp)
      expect(p.cont.isBottom()).to.be.true
      p.step()
      expect(p.cont.context.ast).to.equal(ast.bodyExp)
      expect(p.cont.isOut()).to.be.true
      # exit whole exp
      p.step()
      expect(p.cont.context.ast).to.equal(ast)
      expect(p.cont.isOut()).to.be.true
      p.step()
      expect(p.cont).to.equal(3)

  it 'binary tree', ->
    test 'binaryTree', (ast, p) ->
      expect(p.cont.context.ast).to.equal(ast)
      expect(p.cont.isIn()).to.be.true
      p.step()
      expect(p.cont.context.ast).to.equal(ast.leftExp)
      expect(p.cont.isIn()).to.be.true
      p.step()
      expect(p.cont.context.ast).to.equal(ast.leftExp.leftExp)
      expect(p.cont.isBottom()).to.be.true
      p.step()
      expect(p.cont.context.ast).to.equal(ast.leftExp.rightExp)
      expect(p.cont.isBottom()).to.be.true
      p.step()
      expect(p.cont.context.ast).to.equal(ast.leftExp)
      expect(p.cont.isOut()).to.be.true
      p.step()
      expect(p.cont.context.ast).to.equal(ast.rightExp)
      expect(p.cont.isIn()).to.be.true
      p.step()
      expect(p.cont.context.ast).to.equal(ast.rightExp.leftExp)
      expect(p.cont.isBottom()).to.be.true
      p.step()
      expect(p.cont.context.ast).to.equal(ast.rightExp.rightExp)
      expect(p.cont.isBottom()).to.be.true
      p.step()
      expect(p.cont.context.ast).to.equal(ast.rightExp)
      expect(p.cont.isOut()).to.be.true
      p.step()
      expect(p.cont.context.ast).to.equal(ast)
      expect(p.cont.isOut()).to.be.true
      p.step()
      expect(p.cont).to.equal(11)

  it 'unary tree', ->
    test 'unaryTree', (ast, p) ->
      expect(p.cont.context.ast).to.equal(ast)
      expect(p.cont.isIn()).to.be.true
      p.step()
      expect(p.cont.context.ast).to.equal(ast.exp)
      expect(p.cont.isIn()).to.be.true
      p.step()
      expect(p.cont.context.ast).to.equal(ast.exp.exp)
      expect(p.cont.isBottom()).to.be.true
      p.step()
      expect(p.cont.context.ast).to.equal(ast.exp)
      expect(p.cont.isOut()).to.be.true
      p.step()
      expect(p.cont.context.ast).to.equal(ast)
      expect(p.cont.isOut()).to.be.true
      p.step()
      expect(p.cont).to.equal(true)

  it 'parenthesis', ->
    test 'parenthesis', (ast, p) ->
      expect(p.cont.context.ast).to.equal(ast.exp)
      expect(p.cont.isBottom()).to.be.true
      p.step()
      expect(p.cont).to.equal(1)

  it 'tuple', ->
    test 'tuple', (ast, p) ->
      expect(p.cont.context.ast).to.equal(ast)
      expect(p.cont.isIn()).to.be.true
      p.step()
      expect(p.cont.context.ast).to.equal(ast.exps[0])
      expect(p.cont.isBottom()).to.be.true
      p.step()
      expect(p.cont.context.ast).to.equal(ast.exps[1])
      expect(p.cont.isBottom()).to.be.true
      p.step()
      expect(p.cont.context.ast).to.equal(ast)
      expect(p.cont.isOut()).to.be.true
      p.step()
      expect(p.cont).to.eql([1, 2])

  it 'mark line heads (class method)', ->
    # use parser
    peg = require 'pegjs'
    fs = require 'fs'
    grammerFile = __dirname + '/../parser/mincaml-parser.pegjs'
    mincamlParser = peg.buildParser fs.readFileSync(grammerFile, 'utf8')
    ast = mincamlParser.parse('if true then\n  1\nelse\n  2')
    Program.markLineHeads(ast)
    expect(ast.leftMost).to.be.true
    expect(ast.condExp.leftMost).to.be.undefined
    expect(ast.thenExp.leftMost).to.be.true
    expect(ast.elseExp.leftMost).to.be.true

  it 'flatten ast (class method)', ->
    ast =
      syntax: 'let'
      varName: {syntax: 'identifier', string: 'x'}
      varExp:
        syntax: 'parenthesis'
        exp: {syntax: 'int', number: 1}
      bodyExp: {syntax: 'var-ref', string: 'x'}
    res = Program.flattenAST(ast)
    expect(res.length).to.equal(3)
    expect(res).to.include(ast)
    expect(res).to.include(ast.varExp.exp)
    expect(res).to.include(ast.bodyExp)

  it 'value to string (class method)', ->
    res = Program.valueToString([1, true, null, [null, null]])
    ans = '(1, true, unit, (unit, unit))'
    expect(res).to.equal(ans)

  it 'env to string (class method)', ->
    env = [{a: 1, b: 2}, {a: 3, c: 4}]
    res = Program.envToString(env)
    ans = '{a: 1, b: 2, c: 4}'
    expect(res).to.equal(ans)
