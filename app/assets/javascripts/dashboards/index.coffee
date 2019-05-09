CIF.DashboardsIndex = do ->
  @window.getService = (td, select_id)->
    data = {id: td.children[0].value, text: td.children[0].text }

    newOption = new Option(data.text, data.id, true, true)

    # Append it to the select
    $(".type-of-service select##{select_id.id}").append(newOption).trigger 'change'

  _init = ->
    # _clientGenderChart()
    # _clientStatusChart()
    _familyType()
    _resizeChart()
    _clientProgramStreamByGender()
    _clientProgramStream()
    _initSelect2()
    _openTaskListModal()
    _handleApplyFilter()
    _initCustomFieldsDataTable()
    _initTrackingDatatable()
    _initICheckBox()
    _handleProgramStreamServiceShow()
    _handleProgramStreamServiceSelect2()
    _updateProgramStream()
    _enableSaveReferralSource()
    _clickSaveReferral()
    _loadModalReminder()

  _loadModalReminder = ->
    if localStorage.getItem('from login') == 'true'
      if $('.check-ref-sources').text() == 'referral_sources'
        $('#referral-source-category-reminder').modal 'show'
        localStorage.setItem('from login', false)

  _enableSaveReferralSource = ->
    $('.referral_source_ancestry .select').on 'select2-selected', (e) ->
      classNames = this.className.split(' ')
      saveBtnClass = ".save-" + classNames[2]
      $(saveBtnClass).removeAttr 'disabled'
    $('.referral_source_ancestry .select').on 'select2-removed', (e) ->
      classNames = this.className.split(' ')
      saveBtnClass = ".save-" + classNames[2]
      $(saveBtnClass).attr('disabled', 'disabled')

  _clickSaveReferral = ->
   $('.save-referral-btn').on 'click', (e) ->
    tickClass = $(this).siblings()[0].classList[2]
    btnSave = this.classList[3]

    setTimeout ( ->
      $(".#{btnSave}").addClass('hide')
      $(".#{tickClass}").removeClass('hide')
    ), 500

  _initICheckBox = ->
    $('.i-checks').iCheck
      checkboxClass: 'icheckbox_square-green'
      radioClass: 'iradio_square-green'

  _handleApplyFilter = ->
    $('button#user-filter-submit').on 'click', (e) ->
      if $('#tasks').prop('checked') || $('#assessments').prop('checked') || $('#forms').prop('checked')
        e.submit
      else if !($('#tasks').prop('checked') && $('#assessments').prop('checked') && $('#forms').prop('checked'))
        e.preventDefault()
        alertTranslation = $('#active_tasks_list').attr('alert-translation')
        alert(alertTranslation)

  _openTaskListModal = ->
    if window.location.href.indexOf('user_id') >= 0
      $('#active_tasks_list').modal('show')

  _initSelect2 = ->
    $('select').select2
      minimumInputLength: 0
      allowClear: true

  _resizeChart = ->
    $('.minimalize-styl-2').click ->
      setTimeout (->
        window.dispatchEvent new Event('resize')
    ), 220

  # _clientGenderChart = ->
  #   element = $('#client-by-gender')
  #   data    = $(element).data('content-count')
  #   report = new CIF.ReportCreator(data, '', '', element)
  #   report.donutChart()

  # _clientStatusChart = ->
  #   element = $('#client-by-status')
  #   data    = $(element).data('content-count')
  #   report = new CIF.ReportCreator(data, '', '', element)
  #   report.pieChart()

  _familyType = ->
    element = $('#family-type')
    data    = $(element).data('content-count')
    report = new CIF.ReportCreator(data, '', '', element)
    report.pieChart()

  _clientProgramStreamByGender = ->
    element = $('#client-program-stream')
    data    = $(element).data('content-count')
    title    = $(element).data('title')
    report = new CIF.ReportCreator(data, title, '', element)
    report.donutChart()

  _clientProgramStream = ->
    element = $('#client-by-program-stream')
    data    = $(element).data('content-count')
    title    = $(element).data('title')
    report = new CIF.ReportCreator(data, title, '', element)
    report.pieChart(option: true)

  _initCustomFieldsDataTable = ->
    self = $('#custom-fields-table')
    $(self).DataTable
      bFilter: false
      sScrollY: '500'
      bInfo: false
      processing: true
      serverSide: true
      ajax: $(self).data('url')
      columns:  [
        null
        bSortable: false, className: 'text-center'
      ]
      language:
        paginate:
          previous: $(self).data('previous')
          next: $(self).data('next')
      drawCallback: ->
        _getDataTableId()

  _initTrackingDatatable = ->
    self = $('#program-streams-table')
    $(self).DataTable
      bFilter: false
      sScrollY: '500'
      bInfo: false
      processing: true
      serverSide: true
      ajax: $(self).data('url')
      columns: [
        null
        null
        bSortable: false, className: 'text-center'
      ]
      language:
        paginate:
          previous: $(self).data('previous')
          next: $(self).data('next')
      drawCallback: ->
        _getDataTableId()

  _getDataTableId = ->
    $('.paginate_button a').click ->
      DATA_TABLE_ID = $($(this).parents('.table-responsive').find('.custom-field-table')[1]).attr('id')

  _handleProgramStreamServiceShow = ->
    $('#referral-source-category-reminder button[data-dismiss=modal]').click ->
      $('#program-stream-service-modal.just-login').modal('show')
    $('#program-stream-service-modal button[data-dismiss=modal]').click ->
      $('.modal.in').removeClass('just-login')
      return


  _handleProgramStreamServiceSelect2 = ->
    $('.type-of-service select').select2
      width: '100%'

    createHeaderElement = (options, indexes)->
      html = ""
      indexes.forEach (entry) ->
        html += "<th><b>#{options[entry][0]}</b></th>"
      html

    createRowElement = (options, indexes, select_id) ->
      html = ""
      indexes.forEach (entries) ->
        td = ""
        entries.forEach (index) ->
          td += "<td width='' onclick='getService(this, #{select_id})'><option value='#{options[index][1]}'>#{options[index][0]}</option></td>"

        html += "<tr>#{td}</tr>"
      html

    $('.type-of-service select').on 'select2-open', (e) ->
      arr = []
      i = 0
      while i < $('.type-of-service').data('custom').length
        arr.push i
        i++

      options = $('.type-of-service').data('custom')
      results = []
      chunk_size = 11
      while arr.length > 0
        results.push arr.splice(0, chunk_size)

      indexes = results.shift()
      th  = createHeaderElement(options, indexes)
      row = createRowElement(options, results, @id)

      html = '<table class="table table-bordered" style="margin-top: 5px;margin-bottom: 0px;"><thead>' + th + '</thead><tbody>' + row + '</tbody></table>'
      $('#select2-drop .select2-results').html $(html)
      # $('.select2-results').prepend "#{html}"
      return

    removeError = (element) ->
      element.removeClass('has-error')
      element.find('.help-block').remove()

    $('.type-of-service select').on 'select2-close', (e)->
      uniqueArray = _.compact(_.uniq($(this).val()))
      if uniqueArray.length > 0
        removeError($(this.parentElement))
        arrId = this.id.split('_')
        $("#edit_program_stream_#{arrId[arrId.length - 1]} input[type='submit']").removeAttr('disabled')

      if uniqueArray.length > 3
        $(this.parentElement).append "<p class='help-block'>#{$('input#confirm-question').val()}</p>" if $(this.parentElement).find('.help-block').length == 0
        $(this.parentElement).addClass('has-error')

      return

    $('.type-of-service select').on 'select2-removed', ->
      uniqueArray = _.compact(_.uniq($(this).val()))
      if uniqueArray.length <= 3
        removeError($(this.parentElement))

      if uniqueArray.length == 0
        arrId = this.id.split('_')
        $("#edit_program_stream_#{arrId[arrId.length - 1]} input[type='submit']").attr('disabled', 'disabled')

  _updateProgramStream = ->
    $('form.simple_form.program-stream').on 'submit', (e)->
      e.preventDefault

      uniqueArray = _.compact(_.uniq($("##{this.id} select").val()))
      if uniqueArray.length > 0
        $.ajax
          type: 'POST'
          url: "/api/#{$(@).attr('action')}"
          data: $(this).serialize()
          dataType: 'JSON'
          success: (json) ->
            successImg = '<img class="img-circle" src="/assets/success.png" alt="success">'
            $("#edit_program_stream_#{json.program_stream.id} input[type='submit']").replaceWith(successImg)
            return
          error: (response) ->
            $('.error-name').text ''
            $('.error-color').text ''
            if response.responseJSON.errors.name
              $('.error-name').text response.responseJSON.errors.name.join(' , ')
            if response.responseJSON.errors.color
              $('.error-color').text response.responseJSON.errors.color.join(' , ')
            return
      else
        $("##{this.id} .program_stream_services").append "<p class='help-block'>#{$("input#blank").val()}</p>" if $("##{this.id} .program_stream_services .help-block").length == 0
        $("##{this.id} .program_stream_services").addClass('has-error')


  { init: _init }
