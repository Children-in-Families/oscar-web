CIF.CallsIndex = do ->
  _init = ->
    _initSelect2()
    _initAdavanceSearchFilter()

  _initSelect2 = ->
    $('#calls-index select').select2
      minimumInputLength: 0,
      allowClear: true

  _initAdavanceSearchFilter = ->
    advanceFilter = new CIF.ClientAdvanceSearch()
    advanceFilter.initBuilderFilter('#call-builder-fields')
    # advanceFilter.setValueToBuilderSelected()
    # advanceFilter.getTranslation()

  { init: _init }
