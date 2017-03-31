CIF.DomainsNew = CIF.DomainsCreate = CIF.DomainsEdit = CIF.DomainsUpdate = do ->
  _init = ->
    _initSelect2()
    _removeUnusedTool()

  _removeUnusedTool = ->
    $('.strike, .link, .heading-1, .quote, .code, .nesting-level').remove()

  _initSelect2 = ->
    $('.select2').select2();
  { init: _init }
