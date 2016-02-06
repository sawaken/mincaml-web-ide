 {
   function mergeLocation(left, right) {
     return {start: left.location.start, end: right.location.end};
   }
   var keywords = ['let', 'rec', 'in', 'if', 'then', 'else'];
   function isKeyword(str) {
     var i;
     for (i = 0; i < keywords.length; i++) {
       if (str === keywords[i]) { return true; }
     }
     return false;
   }
 }

Top
  = _ e:Exp _ { return e; }

Exp
  = ExpIf / ExpLet / ExpLetRec / ExpLetTuple / ExpBinary1

ExpIf 'if expression'
  = 'if' _ condExp:Exp _ 'then' _ thenExp:Exp _ 'else' _ elseExp:Exp {
    return {location: location(), syntax: 'if', condExp: condExp, thenExp: thenExp, elseExp: elseExp};
  }

ExpLet 'let expression'
  = 'let' _ !'rec' varName:Identifier _ '=' _ varExp:Exp _ 'in' _ bodyExp:Exp {
    return {location: location(), syntax: 'let', varName: varName, varExp: varExp, bodyExp: bodyExp};
  }

ExpLetRec 'let-rec expression'
  = 'let' _ 'rec' _ funcName:Identifier _ paramNames:((_ i:Identifier){ return i; })+ _ '=' _ funcExp:Exp _ 'in' _ bodyExp:Exp {
    return {location: location(), syntax: 'let-rec', funcName: funcName, funcParamNames: paramNames, funcExp: funcExp, bodyExp: bodyExp};
  }

ExpLetTuple 'let-tuple expression'
  = 'let' _ '(' _ head:Identifier tail:((_ ',' _ i:Identifier){ return i; })+ _ ')' _  '=' _ tupleExp:Exp _ 'in' _ bodyExp:Exp {
    return {location: location(), syntax: 'let-tuple', varNames: [head].concat(tail), tupleExp: tupleExp, bodyExp: bodyExp};
  }

ExpBinary1
  = head:ExpBinary2 tail:(_ ('==' / '<=') _ ExpBinary2)* {
    var result = head, i;
    for (i = 0; i < tail.length; i++) {
      var left = result, right = tail[i][3];
      if (tail[i][1] === '==') { result = {location: mergeLocation(left, right), syntax: 'eq', leftExp: left, rightExp: right}; }
      if (tail[i][1] === '<=') { result = {location: mergeLocation(left, right), syntax: 'le', leftExp: left, rightExp: right}; }
    }
    return result;
  }

ExpBinary2
  = head:ExpBinary3 tail:(_ ('+' / '-') _ ExpBinary3)* {
    var result = head, i;
    for (i = 0; i < tail.length; i++) {
      var left = result, right = tail[i][3];
      if (tail[i][1] === '+') { result = {location: mergeLocation(left, right), syntax: 'add', leftExp: left, rightExp: right}; }
      if (tail[i][1] === '-') { result = {location: mergeLocation(left, right), syntax: 'sub', leftExp: left, rightExp: right}; }
    }
    return result;
  }

ExpBinary3
  = head:ExpUnary tail:(_ ('*' / '/') _ ExpUnary)* {
    var result = head, i;
    for (i = 0; i < tail.length; i++) {
      var left = result, right = tail[i][3];
      if (tail[i][1] === '*') { result = {location: mergeLocation(left, right), syntax: 'mul', leftExp: left, rightExp: right}; }
      if (tail[i][1] === '/') { result = {location: mergeLocation(left, right), syntax: 'div', leftExp: left, rightExp: right}; }
    }
    return result;
  }

ExpUnary
  = ops:(UnaryOp _)* exp:ExpApply {
    var result = exp, i;
    for (i = ops.length - 1; i >= 0; i--) {
      var op = ops[i][0];
      if (op.opStr === '!') { result = {location: mergeLocation(op, result), syntax: 'not', exp: result}; }
      if (op.opStr === '-') { result = {location: mergeLocation(op, result), syntax: 'neg', exp: result}; }
    }
    return result;
  }

ExpApply
  = head:ExpBottom tail:(_ !(('in' / 'then' / 'else') [ \t\n\r]) ExpBottom)* {
    if (tail.length === 0) {
      return head;
    } else {
      var result = head, i;
      for (i = 0; i < tail.length; i++) {
        var left = result, right = tail[i][2];
        result = {location: mergeLocation(left, right), syntax: 'apply', leftExp: left, rightExp: right};
      }
      return result;
    }
  }

ExpBottom
  = ExpParenthesis / ExpBool / ExpInt / ExpUnit / ExpVarRef

ExpParenthesis 'tuple or parenthesis expression'
  = '(' _ head:Exp tail:((_ ',' _ e:Exp){ return e; })* _ ')' {
    if (tail.length === 0) {
      return {location: location(), syntax: 'parenthesis', exp: head};
    } else {
      return {location: location(), syntax: 'tuple', exps: [head].concat(tail)};
    }
  }

ExpVarRef 'var-ref expression'
  = name:Identifier {
    return {location: location(), syntax: 'var-ref', string: name.string};
  }

ExpBool 'literal-bool'
  = name:('true' / 'false') {
    return {location: location(), syntax: 'bool', bool: (name === 'true'), string: name};
  }

ExpInt 'literal-int'
  = digits:[0-9]+ {
    var string = digits.join('');
    return {location: location(), syntax: 'int', number: parseInt(string, 10), string: string};
  }

ExpUnit 'unit expression'
  = 'unit' {
    return {location: location(), syntax: 'unit'};
  }


/* utils */

UnaryOp
  = op:('!' / '-') { return {location: location(), opStr: op}; }

Identifier 'identifier'
  = head:[a-z] tail:[a-zA-Z0-9]* {
    var string = head + tail.join('');
    if (isKeyword(string)) {
      expected('identifier');
    } else{
      return {location: location(), syntax: 'identifier', string: string};
    }
  }

_ 'whitespace'
  = [ \t\n\r]*
