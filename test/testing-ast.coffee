# AST examples for test
class TestingAST
  constructor: () ->

    # ASTs with valid typing
    # ----------

    @simpleIf =
      syntax: 'if'
      condExp: {syntax: 'bool', bool: true}
      thenExp: {syntax: 'int', number: 1}
      elseExp: {syntax: 'int', number: 2}

    @simpleLet =
      syntax: 'let'
      varName: {syntax: 'identifier', string: 'x'}
      varExp: {syntax: 'int', number: 1}
      bodyExp: {syntax: 'var-ref', string: 'x'}

    @simpleLetRec =
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

    @simpleLetTuple =
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

    @binaryTree =
      syntax: 'add'
      leftExp:
        syntax: 'sub'
        leftExp: {syntax: 'int', number: 1}
        rightExp: {syntax: 'int', number: 2}
      rightExp:
        syntax: 'mul'
        leftExp: {syntax: 'int', number: 3}
        rightExp: {syntax: 'int', number: 4}

    @unaryTree =
      syntax: 'not'
      exp:
        syntax: 'not'
        exp: {syntax: 'bool', bool: true}

    @parenthesis =
      syntax: 'parenthesis'
      exp: {syntax: 'int', number: 1}

    @tuple =
      syntax: 'tuple'
      exps: [
        {syntax: 'int', number: 1},
        {syntax: 'int', number: 2}
      ]

    @int =
      syntax: 'int'
      number: 1

    # ASTs including type error
    # you should not give those as interpreter's input
    # ----------

    @ifWithTypeError1 =
      syntax: 'if'
      condExp: {syntax: 'int', number: 0}
      thenExp: {syntax: 'int', number: 1}
      elseExp: {syntax: 'int', number: 2}

    @ifWithTypeError2 =
      syntax: 'if'
      condExp: {syntax: 'bool', bool: true}
      thenExp: {syntax: 'int', number: 0}
      elseExp: {syntax: 'bool', bool: false}

    # unification will fail because F = Int -> X and X = (X, Int)
    @letRecWithTypeError =
      syntax: 'let-rec'
      funcName: {syntax: 'identifier', string: 'f'}
      funcParamNames: [
        {syntax: 'identifier', string: 'x'}
      ]
      funcExp:
        syntax: 'tuple'
        exps: [
          {
            syntax: 'apply',
            leftExp: {syntax: 'var-ref', string: 'f'},
            rightExp: {syntax: 'int', number: 0}
          },
          {syntax: 'int', number: 1}
        ]
      bodyExp: {syntax: 'var-ref', string: 'f'}

    @letTupleWithTypeError1 =
      syntax: 'let-tuple'
      varNames: [
        {syntax: 'identifier', string: 'x'},
        {syntax: 'identifier', string: 'y'}
      ]
      tupleExp:
        syntax: 'tuple'
        exps: [
          {syntax: 'int', number: 1},
          {syntax: 'int', number: 2},
          {syntax: 'int', number: 3}
        ]
      bodyExp: {syntax: 'unit'}

    @letTupleWithTypeError2 =
      syntax: 'let-tuple'
      varNames: [
        {syntax: 'identifier', string: 'x'},
        {syntax: 'identifier', string: 'y'}
      ]
      tupleExp: {syntax: 'unit'}
      bodyExp: {syntax: 'unit'}

    @applyWithTypeError =
      syntax: 'apply'
      leftExp: {syntax: 'int', number: 0}
      rightExp: {syntax: 'int', number: 1}

    @addWithTypeErrorLeft =
      syntax: 'add'
      leftExp: {syntax: 'bool', bool: true}
      rightExp: {syntax: 'int', number: 0}

    @addWithTypeErrorRight =
      syntax: 'add'
      leftExp: {syntax: 'int', number: 0}
      rightExp: {syntax: 'bool', bool: true}

    @notWithTypeError =
      syntax: 'not'
      exp: {syntax: 'int', number: 0}

    @negWithTypeError =
      syntax: 'neg'
      exp: {syntax: 'bool', bool: true}

    # AST including unbound variable
    # ----------

    @unboundVar =
      syntax: 'var-ref'
      string: 'x'

exports.TestingAST = TestingAST
