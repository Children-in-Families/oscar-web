CIF.Progress_notesNew = CIF.Progress_notesCreate = CIF.Progress_notesEdit = CIF.Progress_notesUpdate = do ->
  _init = ->
    _select2()

  _select2 = ->
    $('.progress_note_progress_note_type select, .progress_note_location select, .progress_note_material select, .progress_note_interventions select').select2
      minimumInputLength: 0
      allowClear: true

  { init: _init }