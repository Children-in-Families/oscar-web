CIF.ClientsNew = CIF.ClientsCreate = CIF.ClientsUpdate = CIF.ClientsEdit = do ->
  _init = ->
    _clientSelectOption()

  _clientSelectOption = ->
    $("#clients-edit select, #clients-new select, #clients-update select, #clients-create select").select2
      minimumInputLength: 0

    $('select.able-related-info').change ->
      qtSelectedSize = $('select.able-related-info option:selected').length

      if qtSelectedSize > 0
        $('#client_able').val(true)
        $('#fake_client_able').prop('checked', true)
      else
        $('#client_able').val(false)
        $('#fake_client_able').prop('checked', false)

  { init: _init }