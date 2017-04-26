CIF.Custom_fieldsIndex = do ->
  _init = ->
    _active_tab()

  _active_tab = ->
    if window.location.href.split('tab')[1].substr(1) == 'all_ngo'
      $('a[href="#all-custom-form"]').tab('show')
  { init: _init }
