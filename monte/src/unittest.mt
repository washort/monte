object _failure:
    pass

object unitTestAssertions:
    to notEqual(left, right):
        if (left == right):
            throw(`Equal: ${M.toQuote(left)} == ${M.toQuote(right)}`)

    to equal(left, right):
        if (left != right):
            throw(`Not equal: ${M.toQuote(left)} != ${M.toQuote(right)}`)

    to ejects(f):
        var reason := null
        def fail(msg):
            reason := msg
        escape ej:
            f(ej, fail)
        if (reason != null):
            throw("Failed to eject: " + reason)

    to raises(f):
        var reason := null
        def fail(msg):
            reason := msg
        try:
            f(fail)
        catch e:
            pass
        if (reason != null):
            throw("Failed to raise: " + reason)
