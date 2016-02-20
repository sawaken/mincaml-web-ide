expect = require('chai').expect

describe 'test mincaml parser', ->
  mincamlParser = null

  assertAST = (expected, actual) ->
    if expected instanceof Object
      for key of expected
        assertAST(expected[key], actual[key])
    else if expected instanceof Array
      for v, idx in expected
        assertAST(expected[idx], actual[idx])
    else
      expect(actual).to.equal(expected)

  ptest = (input, expected) ->
    assertAST expected, mincamlParser.parse(input)

  before ->
    peg = require 'pegjs'
    fs = require 'fs'
    grammerFile = __dirname + '/../parser/mincaml-parser.pegjs'
    mincamlParser = peg.buildParser fs.readFileSync(grammerFile, 'utf8')

  it 'arithmetic expression', ->
    ptest '0 == 1*2+3*4',
      syntax: 'eq'
      leftExp:
        number: 0
      rightExp:
        syntax: 'add'
        leftExp:
          syntax: 'mul'
          leftExp:
            number: 1
          rightExp:
            number: 2
        rightExp:
          syntax: 'mul'
          leftExp:
            number: 3
          rightExp:
            number: 4

  it 'arithmetic expresion with parenthesis', ->
    ptest '0 <= (1-2)/3',
      syntax: 'le'
      leftExp:
        number: 0
      rightExp:
        syntax: 'div'
        leftExp:
          syntax: 'parenthesis'
          exp:
            syntax: 'sub'
            leftExp:
              number: 1
            rightExp:
              number: 2
        rightExp:
          number: 3

  it 'primitives', ->
    ptest '(true, false, unit, hoge)',
      syntax: 'tuple'
      exps: [
        {syntax: 'bool', bool: true},
        {syntax: 'bool', bool: false},
        {syntax: 'unit'},
        {syntax: 'var-ref', string: 'hoge'}
      ]

  it 'apply', ->
    ptest 'x y z',
      syntax: 'apply'
      leftExp:
        syntax: 'apply'
        leftExp:
          string: 'x'
        rightExp:
          string: 'y'
      rightExp:
        string: 'z'

  it 'unary op', ->
    ptest '-!0',
      syntax: 'neg'
      exp:
        syntax: 'not'
        exp:
          number: 0

  it 'nested if', ->
    ptest 'if 0 then if 1 then 2 else 3 else if 4 then 5 else 6',
      syntax: 'if'
      condExp: {number: 0}
      thenExp:
        syntax: 'if'
        condExp: {number: 1}
        thenExp: {number: 2}
        elseExp: {number: 3}
      elseExp:
        syntax: 'if'
        condExp: {number: 4}
        thenExp: {number: 5}
        elseExp: {number: 6}

  it 'let', ->
    ptest 'let x = f a in x + x',
      syntax: 'let'
      varName: {syntax: 'identifier', string: 'x'}
      varExp: {syntax: 'apply'}
      bodyExp: {syntax: 'add'}

  it 'let rec', ->
    ptest 'let rec f x y = x - y in f 1 2',
      syntax: 'let-rec'
      funcName: {syntax: 'identifier', string: 'f'}
      funcParamNames: [
        {syntax: 'identifier', string: 'x'}
        {syntax: 'identifier', string: 'y'}
      ]
      funcExp:
        syntax: 'sub'
        leftExp: {syntax: 'var-ref', string: 'x'}
        rightExp: {syntax: 'var-ref', string: 'y'}
      bodyExp:
        syntax: 'apply'
        leftExp:
          syntax: 'apply'
          leftExp: {syntax: 'var-ref', string: 'f'}
          rightExp: {syntax: 'int', number: 1}
        rightExp: {syntax: 'int', number: 2}

  it 'let tuple', ->
    ptest 'let (x, y) = t in x + y',
      syntax: 'let-tuple'
      varNames: [
        {syntax: 'identifier', string: 'x'},
        {syntax: 'identifier', string: 'y'}
      ]
      tupleExp: {string: 't'}
      bodyExp: {syntax: 'add'}

  # tests for parse-fail
  # ----------

  it 'fail1', ->
    try
      mincamlParser.parse('1 + 2 ++ 3')
    catch error
      expect(error.name).to.equal('SyntaxError')
      expect(error.location.start.line).to.equal(1)
      expect(error.location.start.offset).to.equal(7)
