CIF.DomainsNew = CIF.DomainsCreate = CIF.DomainsEdit = CIF.DomainsUpdate = do ->
  _init = ->
    _initSelect2()

  _initSelect2 = ->
    $('.select2').select2();
  { init: _init }
