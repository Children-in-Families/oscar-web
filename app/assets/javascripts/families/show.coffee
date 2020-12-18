CIF.FamiliesShow = do ->
  _init = ->
    _fixedHeaderTableColumns()
    _getClientPath()
    _handleScrollTable()
    _ajaxCheckReferral()
    _globalIDToolTip()

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

  _ajaxCheckReferral = ->
    $('a.target-ngo').on 'click', (e) ->
      e.preventDefault()
      self= @
      id= @.id
      href = @.href
      data = {
        org: id
        familyId: $('#family-id').val()
      }
      $.ajax
        type: 'GET'
        url: '/api/family_referrals/compare'
        data: data
        success: (response) ->
          modalTitle = $('#hidden_title').val()
          modalTextFirst  = $('#body_first').val()
          modalTextSecond = $('#hidden_body_second').val()
          modalTextThird  = $('#hidden_body_third').val()
          responseText = response.text
          if responseText == 'create referral'
            window.location.replace href
          else if responseText == 'already exist'
            $('#confirm-referral-modal .modal-header .modal-title').text(modalTitle)
            $('#confirm-referral-modal .modal-body').html(modalTextSecond)
            $('#confirm-referral-modal').modal('show')
          else if responseText == 'already referred'
            $('#confirm-referral-modal .modal-header .modal-title').text(modalTitle)
            $('#confirm-referral-modal .modal-body').html(modalTextThird)
            $('#confirm-referral-modal').modal('show')

  _globalIDToolTip = ->
    debugger
    $('[data-toggle="tooltip"]').tooltip()

  { init: _init }
