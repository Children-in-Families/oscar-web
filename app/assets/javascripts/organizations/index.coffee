CIF.OrganizationsIndex = do ->
  _init = ->
    _removeFooter()

  _removeFooter = ->
    if window.location.href.includes('mho')
      $('.padding-bottom').remove()

  { init: _init }
