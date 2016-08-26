CIF.ClientsIndex = do ->
  _init = ->
    _enableSelect2()
    _columnsVisibility()
    _fixedHeaderTableColumns()
    _cssClassForlabelDynamic()
    _validateFieldDomainNumber()

  _enableSelect2 = ->
    $('#clients-index select').select2
      minimumInputLength: 0,
      allowClear: true

  _columnsVisibility = ->
    $('.columns-visibility').click (e) ->
      e.stopPropagation()

    checkboxes = $('.all-visibility #all_')
    checkboxes.change ->
      if checkboxes.is(':checked')
        $('.visibility input[type=checkbox]').each ->
          $(@).prop('checked', true)
          $(@).change ->
            checkboxes.prop('checked', false)
      else
        $('.visibility input[type=checkbox]').each ->
          $(@).prop('checked', false)

  _fixedHeaderTableColumns = ->
    if !$('table.clients tbody tr td').hasClass('noresults')
      $('table.clients').DataTable(
        'sScrollY': '500px'
        'sScrollX': true
        'sScrollXInner': '100%'
        'bPaginate': false
        'bFilter': false
        'bInfo': false
        'ordering': false)

  _cssClassForlabelDynamic = ->
    $('.dynamic_filter').prev('label').css( "display", "block" )

  _validateFieldDomainNumber = ->
    $('.dynamic_filter.value ').keydown (e) ->
      if $.inArray(e.keyCode, [
          46
          8
          9
          27
          13
          110
          190
        ]) != -1 or e.keyCode == 65 and e.ctrlKey == true or e.keyCode == 67 and e.ctrlKey == true or e.keyCode == 88 and e.ctrlKey == true or e.keyCode >= 35 and e.keyCode <= 39
        return
      if (e.shiftKey or e.keyCode < 48 or e.keyCode > 57) and (e.keyCode < 96 or e.keyCode > 105)
        e.preventDefault()
      return


  { init: _init }
