CIF.Progress_notesNew = CIF.Progress_notesCreate = CIF.Progress_notesEdit = CIF.Progress_notesUpdate = do ->
  _init = ->
    _select2()
    _toggleOtherLocation()
    _triggerLocationChanged()

  _select2 = ->
    $('.progress_note_progress_note_type select, .progress_note_location select, .progress_note_material select, .progress_note_interventions select, .progress_note_assessment_domains select').select2
      minimumInputLength: 0
      allowClear: true

  _toggleOtherLocation = ->
    selectedOption = $('.progress_note_location select option:selected')
    if selectedOption.text().toLowerCase().indexOf('other') >= 0
      $('input#progress_note_other_location').removeAttr('disabled')
    else
      $('input#progress_note_other_location').attr('disabled', 'disabled')
        .val('')

  _triggerLocationChanged = ->
    $('.progress_note_location select').change ->
      _toggleOtherLocation()

  { init: _init }