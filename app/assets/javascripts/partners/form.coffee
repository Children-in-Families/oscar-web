CIF.PartnersNew = CIF.PartnersCreate = CIF.PartnersEdit = CIF.PartnersUpdate = do ->
  _init = ->
    _initSelect2()

  _initSelect2 = ->
    $('select').select2
      allowClear: true

  { init: _init }
