CIF.Able_screening_questionsNew = CIF.Able_screening_questionsCreate = CIF.Able_screening_questionsEdit = CIF.Able_screening_questionsUpdate = do ->
  _init = ->
    _initialSelect2()
    _afterSelectMode()
    # _reloadAfterCocoon()
    _initUploader()

  _initialSelect2 = ->
    $('.select2').select2
      theme: 'bootstrap'

  _initUploader = ->
    image = $('.question-image img')
    uploader = $("#able-image")
    button = $(".browse-image")
    $(image).previewImage
      uploader: uploader
      button: button

  _reloadAfterCocoon = ->
    $('.container-fluid').on 'cocoon:after-insert', (e, insertedItem) ->
      insertedItem.find('.select2').select2
        theme: 'bootstrap'
      _afterSelectMode()

  _afterSelectMode = ->
    self = @
    $('.check-mode').map( (index) ->
      element = $($('.check-mode')[index])
      _checkModeHandler(element, element.val())
    )

    $('.check-mode').on 'change', (e, item) ->
      _checkModeHandler(this, e.val)

  _checkModeHandler = (element, value) ->
    parentElement = $(element).closest('.row')
    checkBoxName  = parentElement.find('input[type="checkbox"]').attr('name')
    checkBoxId  = parentElement.find('input[type="checkbox"]').attr('id')
    disabled      = value == 'free_text' ? true : false
    check = $("##{checkBoxId}").val() == '1'
    check = false if value == 'free_text'

    $("input[name='#{checkBoxName}']").prop('disabled', disabled)

  { init: _init }
