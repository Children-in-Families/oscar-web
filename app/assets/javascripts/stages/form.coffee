CIF.StagesNew = CIF.StagesCreate = CIF.StagesEdit = CIF.StagesUpdate = do ->
  _init = ->
    _initialSelect2()
    _afterSelectMode()
    _reloadAfterCocoon()
    _validateInputNumber()

  _initialSelect2 = ->
    $('.select2').select2
      theme: 'bootstrap'

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

  _validateInputNumber = ->
    $('#stage_from_age,#stage_to_age').keydown (e) ->
      if $.inArray(e.keyCode, [
          46
          8
          9
          27
          13
          110
          190
        ]) != -1 or e.keyCode == 65 and e.ctrlKey == true or e.keyCode == 67 and e.ctrlKey == true or e.keyCode == 88 and e.ctrlKey == true or e.keyCode >= 35 and e.keyCode <= 41
        return
      if (e.shiftKey or e.keyCode < 48 or e.keyCode > 57) and (e.keyCode < 96 or e.keyCode > 105)
        e.preventDefault()
      return

  _checkModeHandler = (element, value) ->
    parentElement = $(element).closest('.row')
    checkBoxName  = parentElement.find('input[type="checkbox"]').attr('name')
    checkBoxId  = parentElement.find('input[type="checkbox"]').attr('id')
    disabled      = value == 'free_text' ? true : false
    check = $("##{checkBoxId}").val() == '1'
    check = false if value == 'free_text'

    $("input[name='#{checkBoxName}']").prop('checked', check)
    $("input[name='#{checkBoxName}']").prop('disabled', disabled)

  { init: _init }
