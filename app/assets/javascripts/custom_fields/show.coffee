CIF.Custom_fieldsShow = CIF.Custom_fieldsPreview = do ->
  _init = ->
    _initFileInput()

  _initFileInput = ->
    $('.file').fileinput
      showUpload: false
      removeClass: 'btn btn-danger btn-outline'
      browseLabel: 'Browse'
      theme: "explorer"

  { init: _init }
