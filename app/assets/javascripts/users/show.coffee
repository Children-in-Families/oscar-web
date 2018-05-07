CIF.UsersShow = do ->
  _init = ->
    _fixedHeaderTableColumns()
    _handleScrollTable()
    _getClientPath()
    _autoCheckReadable()
    _autoUncheckEditable()

  _fixedHeaderTableColumns = ->
    $('.clients-table').removeClass('table-responsive')
    if !$('table.clients tbody tr td').hasClass('noresults')
      $('table.clients').dataTable(
        'bPaginate': false
        'bFilter': false
        'bInfo': false
        'bSort': false
        'sScrollY': 'auto'
        'bAutoWidth': true
        'sScrollX': '100%')
    else
      $('.clients-table').addClass('table-responsive')

  _handleScrollTable = ->
    $(window).load ->
      ua = navigator.userAgent
      unless /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|OperaMini|Mobile|mobile|CriOS/i.test(ua)
        $('.clients-table .dataTables_scrollBody').niceScroll
          scrollspeed: 30
          cursorwidth: 10
          cursoropacitymax: 0.4

  _getClientPath = ->
    return if $('table.clients tbody tr').text().trim() == 'No results found' || $('table.clients tbody tr').text().trim() == 'មិនមានលទ្ធផល'
    $('table.clients tbody tr').click (e) ->
      return if $(e.target).hasClass('btn') || $(e.target).hasClass('fa') || $(e.target).is('a')
      window.open($(@).data('href'), '_blank')

  _autoCheckReadable = ->
    $('.user_program_stream_permissions_editable input.i-checks').on 'ifChecked', (event) ->
      $(@).parents('.program-stream-permission').find('.user_program_stream_permissions_readable input.i-checks').iCheck('check')
    $('.user_custom_field_permissions_editable input.i-checks').on 'ifChecked', (event) ->
      $(@).parents('.custom-field-permission').find('.user_custom_field_permissions_readable input.i-checks').iCheck('check')
    $('.user_permission_case_notes_editable input.i-checks').on 'ifChecked', (event) ->
      $(@).parents('.case-note-permission').find('.user_permission_case_notes_readable input.i-checks').iCheck('check')
    $('.user_permission_assessments_editable input.i-checks').on 'ifChecked', (event) ->
      $(@).parents('.assessment-permission').find('.user_permission_assessments_readable input.i-checks').iCheck('check')
    $('.user_quantitative_type_permissions_editable input.i-checks').on 'ifChecked', (event) ->
      $(@).parents('.quantitative-type-permission').find('.user_quantitative_type_permissions_readable input.i-checks').iCheck('check')

  _autoUncheckEditable = ->
    $('.user_program_stream_permissions_readable input.i-checks').on 'ifUnchecked', (event) ->
      $(@).parents('.program-stream-permission').find('.user_program_stream_permissions_editable input.i-checks').iCheck('uncheck')
    $('.user_custom_field_permissions_readable input.i-checks').on 'ifUnchecked', (event) ->
      $(@).parents('.custom-field-permission').find('.user_custom_field_permissions_editable input.i-checks').iCheck('uncheck')
    $('.user_permission_case_notes_readable input.i-checks').on 'ifUnchecked', (event) ->
      $(@).parents('.case-note-permission').find('.user_permission_case_notes_editable input.i-checks').iCheck('uncheck')
    $('.user_permission_assessments_readable input.i-checks').on 'ifUnchecked', (event) ->
      $(@).parents('.assessment-permission').find('.user_permission_assessments_editable input.i-checks').iCheck('uncheck')
     $('.user_quantitative_type_permissions_readable input.i-checks').on 'ifUnchecked', (event) ->
      $(@).parents('.quantitative-type-permission').find('.user_quantitative_type_permissions_editable input.i-checks').iCheck('uncheck')

  { init: _init }
