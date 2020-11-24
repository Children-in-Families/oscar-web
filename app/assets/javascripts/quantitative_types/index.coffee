CIF.Quantitative_typesIndex = do ->
  _init = ->
    _initSelect2()

  _initSelect2 = ->
    $('.select2').select2
      allowClear: true

  { init: _init }
