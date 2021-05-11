CIF.Case_conferencesNew = CIF.Case_conferencesCreate = CIF.Case_conferencesEdit = CIF.Case_conferencesUpdate = do ->
  _init = ->
    _initSelect2CasenoteInteractionType()

  _initSelect2CasenoteInteractionType = ->
    $('#case_conference_user_ids').select2
      width: '100%'

  { init: _init }
