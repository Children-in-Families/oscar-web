CIF.ClientsIndex = do ->
  _init = ->
    _enableSelect2()
    _columnsVisibility()
    _fixedHeaderTableColumns()

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

  { init: _init }
