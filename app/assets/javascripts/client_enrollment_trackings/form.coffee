CIF.Client_enrollment_trackingsNew = CIF.Client_enrollment_trackingsCreate = CIF.Client_enrollment_trackingsEdit = CIF.Client_enrollment_trackingsUpdate = CIF.Client_enrolled_program_trackingsUpdate =
CIF.Client_enrolled_program_trackingsNew = CIF.Client_enrolled_program_trackingsCreate = CIF.Client_enrolled_program_trackingsEdit = do ->

  _init = ->
    _initSelect2()
    _initFileInput()

  _initSelect2 = ->
    $('select').select2()

  _initFileInput = ->
    $('.file').fileinput
      showUpload: false
      removeClass: 'btn btn-danger btn-outline'
      browseLabel: 'Browse'
      theme: "explorer"
      allowedFileExtensions: ['jpg', 'png', 'jpeg', 'doc', 'docx', 'xls', 'xlsx', 'pdf']

  { init: _init }
