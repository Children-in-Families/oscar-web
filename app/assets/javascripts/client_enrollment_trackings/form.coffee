CIF.Client_enrollment_trackingsNew = CIF.Client_enrollment_trackingsCreate = CIF.Client_enrollment_trackingsEdit = CIF.Client_enrollment_trackingsUpdate = do ->
  
  _init = ->
    _initSelect2()
    _handlePreventCheckboxEmpty()

  _initSelect2 = ->
    $('select').select2()

  _handlePreventCheckboxEmpty = ->
    form = $('form.simple_form')
    $(form).on 'submit', (e) ->
      checkboxes = $(form).find('input[type="checkbox"]')
      textArea  = $(form).find('textarea')
      otherInputs = $(form).find('input:not([type="checkbox"], [type="file"], [type="hidden"], [type="submit"])')
      checked = false

      for checkbox in checkboxes
        if $(checkbox).prop('checked')
          checked = true
          break

      if checkboxes.length > 0 and !checked and (otherInputs.length == 0 and textArea.length == 0)
        e.preventDefault()
        $('#message').text("Please select a checkbox")

  { init: _init }