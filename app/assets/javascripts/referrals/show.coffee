CIF.ReferralsShow = do ->
  _init = ->
    $.fn.editable.defaults.ajaxOptions = {type: "put"}
    $('.editable').editable
      select2:
        width: '250px'
        dropdownAutoWidth: true
        allowClear: true
        viewseparator: ','
      ajaxOptions:
        dataType: 'json'
      error: (response, newValue) ->
        if response.status == 500
          'Service unavailable. Please try later.'
        else
          response.responseText

  { init: _init }
