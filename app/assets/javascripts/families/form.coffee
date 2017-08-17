CIF.FamiliesNew = CIF.FamiliesCreate = CIF.FamiliesEdit = CIF.FamiliesUpdate = do ->
  _init = ->
    _initSelect2()

  _initSelect2 = ->
    $('select').select2
      allowClear: true
      _clearSelectedOption()

  _clearSelectedOption = ->
    formAction = $('body').attr('id')
    $('#family_family_type').val('') unless formAction.includes('edit')

  { init: _init }
