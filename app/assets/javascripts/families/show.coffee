CIF.FamiliesShow = do ->
  _init = ->
    _fixedHeaderTableColumns()
    _getClientPath()
    _handleScrollTable()
    _buttonHelpTextPophover()
    # Todo: check what this func does
    # _enterNgoModalValidation()
    _initDatePicker()

  _initDatePicker = ->
    $('.enter_ngos, .exit_ngos, .exit_date, .enter_date').datepicker
      autoclose: true
      format: 'yyyy-mm-dd'
      todayHighlight: true
      orientation: 'bottom'
      disableTouchKeyboard: true

  # _enterNgoModalValidation = ->
  #   data = {
  #     date: '#enter_ngo_accepted_date',
  #     field: '#enter_ngo_user_ids',
  #     form: '#enter-ngo-form',
  #     btn: '.agree-btn'
  #   }
  #   _modalFormValidator(data)

  # _modalFormValidator = (data)->
  #   date = data['date']
  #   field = data['field']
  #   note = data['note']
  #   form = data['form']
  #   btn = data['btn']
  #   exitReasonsLength = _checkExitReasonsLength(form)
  #   _modalButtonAction(form, date, field, note, btn, exitReasonsLength)

  #   $(date).add(field).add(note).bind 'keyup change', ->
  #     exitReasonsLength = _checkExitReasonsLength(form)
  #     _modalButtonAction(form, date, field, note, btn, exitReasonsLength)

  #   $('#exitFromNgo .i-checks, .exit-ngos .i-checks').on 'ifToggled', ->
  #     exitReasonsLength = _checkExitReasonsLength(form)
  #     _modalButtonAction(form, date, field, note, btn, exitReasonsLength)

  # _checkExitReasonsLength = (form) ->
  #   if form == '#exitFromNgo' or form.indexOf('#exit_ngos-') >= 0 then $(form).find('.i-checks input:checked').length else 1

  # _modalButtonAction = (form, date, field, note, btn, exitReasonsLength) ->
  #   date = $(date).val()
  #   field = $(field).val()
  #   note = $(note).val()

  #   if (field == '' or field == null) or date == '' or note == '' or exitReasonsLength == 0
  #     $(form).find(btn).attr 'disabled', 'disabled'
  #   else
  #     $(form).find(btn).removeAttr 'disabled'

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
      unless /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini|Mobile|mobile|CriOS/i.test(ua)
        $('.clients-table .dataTables_scrollBody').niceScroll
          scrollspeed: 30
          cursorwidth: 10
          cursoropacitymax: 0.4

  _getClientPath = ->
    return if $('table.clients tbody tr').text().trim() == 'No results found' || $('table.clients tbody tr').text().trim() == 'មិនមានលទ្ធផល'
    $('table.clients tbody tr').click (e) ->
      return if $(e.target).hasClass('btn') || $(e.target).hasClass('fa') || $(e.target).is('a')
      window.open($(@).data('href'), '_blank')
  
  _buttonHelpTextPophover = ->
    $("button[data-content]").popover();

  { init: _init }
