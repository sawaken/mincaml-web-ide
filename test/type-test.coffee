expect = require('chai').expect
{Type, UnifyError} = require  __dirname + '/../src/type.coffee'

describe 'type test', ->
  T = (tname = null, targs = []) ->
    new Type(null, tname, targs)

  it 'simple unify', ->
    a = T()
    b = T()
    c = T()
    a.unify(b)
    b.unify(c)
    expect(a.same(c)).to.be.true

  it 'set type-name', ->
    a = T()
    b = T()
    a.unify(b)
    c = T('Int')
    b.unify(c)
    expect(a.getTypeName()).to.equal('Int')

  it 'set type-args', ->
    a = T()
    b = T()
    c = T('Tuple', [a, b])
    x = T()
    y = T()
    z = T('Tuple', [x, y])
    c.unify(z)
    expect(a.same(x)).to.be.true
    expect(b.same(y)).to.be.true
    expect(c.same(z)).to.be.true
    i = T()
    i.unify(c)
    expect(i.getTypeArgs().length).to.equal(2)

  it 'complex use (let rec f x = x + 1 in f 0)', ->
    letRecExp = T()
    varX = T()
    funcExp = T()
    bodyExp = T()
    funcF = T('Func', [varX, funcExp])
    applyLeft = T('Func', [T('Int'), bodyExp])
    varX.unify(T('Int'))
    funcExp.unify(T('Int'))
    funcF.unify(applyLeft)
    letRecExp.unify(bodyExp)
    expect(funcF.toString()).to.equal('Int -> Int')
    expect(letRecExp.getTypeName()).to.equal('Int')

  it 'unify error (different type names)', ->
    a = T('Int')
    b = T('Bool')
    try
      a.unify(b)
    catch error
      expect(error).to.be.instanceof(UnifyError)
      expect(error.a).to.equal(a)
      expect(error.b).to.equal(b)

  it 'unify error (different size tuples)', ->
    a = T('Tuple', [T(), T()])
    b = T('Tuple', [T(), T(), T()])
    try
      a.unify(b)
    catch error
      expect(error).to.be.instanceof(UnifyError)

  it 'unify error (fail occur check)', ->
    a = T()
    b = T('Tuple', [a, a])
    c = T()
    a.unify(c)
    try
      b.unify(c)
    catch error
      expect(error).to.be.instanceof(UnifyError)

  it 'unify error (child fail)', ->
    a = T('Tuple', [T('Int'), T()])
    b = T('Tuple', [T('Bool'), T()])
    try
      a.unify(b)
    catch error
      expect(error).to.be.instanceof(UnifyError)
