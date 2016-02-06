assert = require('chai').assert

{UnionFind} = require  __dirname + '/../src/union-find.coffee'

describe 'test disjoint-set', ->
  it 'simple unite', ->
    a = new UnionFind()
    b = new UnionFind()
    assert !a.same(b), 'at first, not same'
    a.unite(b)
    assert a.same(b), 'same after unite'

  it 'a+b, b+c, x+a, y+c pattern', ->
    a = new UnionFind()
    b = new UnionFind()
    c = new UnionFind()
    x = new UnionFind()
    y = new UnionFind()
    a.unite(b)
    b.unite(c)
    x.unite(a)
    y.unite(c)
    assert x.same(y)
