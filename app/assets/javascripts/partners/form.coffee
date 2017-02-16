CIF.PartnersNew = CIF.PartnersCreate = CIF.PartnersEdit = CIF.PartnersUpdate = do ->
  _init = ->
    _initSelect2()

  _initSelect2 = ->
    $('.select2').select2();

  { init: _init }
