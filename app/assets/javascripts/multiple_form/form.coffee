CIF.Client_trackingsNew = CIF.Client_trackingsCreate = CIF.Client_custom_fieldsNew = CIF.Client_custom_fieldsCreate = do ->

  _init = ->
    _initSelect2()
    _initFileInput()
    _preventRequireFields()
    _toggleCheckingRadioButton()
    _confirm()

  _toggleCheckingRadioButton = ->
    $('input[type="radio"]').on 'ifChecked', (e) ->
      $(@).parents('span.radio').siblings('.radio').find('.iradio_square-green').removeClass('checked')

  _initSelect2 = ->
    $('select').select2()

  _initFileInput = ->
    $('.file').fileinput
      showUpload: false
      removeClass: 'btn btn-danger btn-outline'
      browseLabel: 'Browse'
      theme: "explorer"
      allowedFileExtensions: ['jpg', 'png', 'jpeg', 'doc', 'docx', 'xls', 'xlsx', 'pdf']

  _preventRequireFields = ->
    prevent = new CIF.PreventRequiredFileUploader()
    prevent.preventFileUploader()
    _preventClient()

  _confirm = ->
    $('#yes').on 'click', ->
      $('#confirm').val('true')
      $('#complete-form').modal('hide')
      $('.multiple-form .simple_form').submit()
    $('#no').on 'click', ->
      $('#confirm').val('false')
      $('#complete-form').modal('hide')
      $('.multiple-form .simple_form').submit()


  _preventClient = ->
    $('form.simple_form').on 'submit', (e) ->
      values = $('select.clients').select2('val')
      if _.isEmpty(values)
        $('#client').addClass('has-error')
        $('#client').find('.help-block').removeClass('hidden')
        e.preventDefault()
      else
        $('#client').removeClass('has-error')
        $('#client').find('.help-block').addClass('hidden')


  { init: _init }
