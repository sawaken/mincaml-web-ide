# AST examples for test
class TestingAST
  constructor: () ->
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

exports.TestingAST = TestingAST