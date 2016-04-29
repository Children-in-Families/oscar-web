CIF.Util =
  capitalize: (value) ->
    value.replace /(^|\s)([a-z])/g, (m, p1, p2) ->
      p1 + p2.toUpperCase()
