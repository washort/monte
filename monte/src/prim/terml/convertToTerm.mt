module makeTerm :DeepFrozen, Term :DeepFrozen, makeTag :DeepFrozen, unittest
export (convertToTerm)

# copypasted here since I am too lazy to DF-annotate everything that needs
# it. remove ASAP
def optMakeTagFromData(val, mkt) as DeepFrozen:
    switch (val):
        match ==null:
            return mkt("null", null)
        match ==true:
            return mkt("true", null)
        match ==false:
            return mkt("false", null)
        match v :Int:
            return mkt(".int.", v)
        match v :Double:
            return mkt(".float64.", v)
        match v :Str:
            return mkt(".String.", v)
        match v :Char:
            return mkt(".char.", v)
        match _:
            return null

def mkt(name, data) as DeepFrozen:
    return makeTerm(makeTag(null, name, Any), data, [], null)

def convertToTerm(val, ej) as DeepFrozen:
    if (val =~ _ :Term):
        return val
    if ((def t := optMakeTagFromData(val, mkt)) != null):
        return t
    switch (val):
        match v :List:
            def ts := [].diverge()
            for item in v:
               ts.push(convertToTerm(item, ej))
            def l := ts.snapshot()
            return makeTerm(makeTag(null, ".tuple.", Any), null, l, null)
        # match v :set:
        #   return mkt(".bag.", null, [for item in (v) convertToTerm(item)])
        match m :Map:
            def mm := [].diverge()
            for k => v in m:
                mm.push(makeTerm(makeTag(null, ".attr.", Any), null, [convertToTerm(k, ej),
                       convertToTerm(v, ej)], null))
            return makeTerm(makeTag(null, ".bag.", Any), null,
                       mm.snapshot(), null)
        match _:
            throw.eject(ej, `Could not coerce $val to term`)

def test_convert(assert):
    def t1 := convertToTerm([1, null, 2.5, "yes", 'c', true, [1 => 2]], null)
    assert.equal(t1.getTag().getName(), ".tuple.")
    def a := t1.getArgs()
    def one := a[0]
    assert.equal(one.getTag().getName(), ".int.")
    assert.equal(one.getData(), 1)
    def nul := a[1]
    assert.equal(nul.getTag().getName(), "null")
    def flo := a[2]
    assert.equal(flo.getTag().getName(), ".float64.")
    assert.equal(flo.getData(), 2.5)
    def s := a[3]
    assert.equal(s.getTag().getName(), ".String.")
    assert.equal(s.getData(), "yes")
    def c := a[4]
    assert.equal(c.getTag().getName(), ".char.")
    assert.equal(c.getData(), 'c')
    def b := a[5]
    assert.equal(b.getTag().getName(), "true")
    def m := a[6]
    assert.equal(m.getTag().getName(), ".bag.")
    def ma := m.getArgs()
    assert.equal(ma[0].getTag().getName(), ".attr.")
    def k := ma[0].getArgs()[0]
    assert.equal(k.getData(), 1)
    def v := ma[0].getArgs()[1]
    assert.equal(v.getData(), 2)

unittest([test_convert])
