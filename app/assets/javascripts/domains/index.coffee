CIF.DomainsIndex = do ->
  _init = ->
    _active_tab()

  _active_tab = ->
    tab = window.location.href.split('tab')[1]
    return if tab == undefined
    if tab.substr(1) == 'csi_domain'
      $('a[href="#csi-tools"]').tab('show')
    else if tab.substr(1) == 'custom_domain'
      $('a[href="#custom-csi-tools"]').tab('show')

  { init: _init }
