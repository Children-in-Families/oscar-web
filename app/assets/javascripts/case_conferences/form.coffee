CIF.Case_conferencesNew = CIF.Case_conferencesCreate = CIF.Case_conferencesEdit = CIF.Case_conferencesUpdate = do ->
  _init = ->
    _initSelect2CasenoteInteractionType()
    _initUploader()

  _initSelect2CasenoteInteractionType = ->
    $('#case_conference_user_ids').select2
      width: '100%'

  _initUploader = ->
    $('#case_conference_attachments').fileinput
      showUpload: false
      removeClass: 'btn btn-danger btn-outline'
      browseLabel: 'Browse'
      theme: "explorer"
      allowedFileExtensions: ['jpg', 'png', 'jpeg', 'doc', 'docx', 'xls', 'xlsx', 'pdf']


  { init: _init }
