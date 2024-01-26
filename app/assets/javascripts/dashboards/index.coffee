CIF.DashboardsIndex = do ->
  @window.getService = (td, select_id)->
    data = {id: td.children[0].value, text: td.children[0].text }

    newOption = new Option(data.text, data.id, true, true)

    # Append it to the select
    $(".type-of-service select##{select_id.id}").append(newOption).trigger 'change'

  _init = ->
    # _clientGenderChart()
    # _clientStatusChart()
    loadFamilyTab()
    _resizeChart()
    # _clientProgramStreamByGender()
    _clientProgramStream()
    _initSelect2()
    _openTaskListModal()
    _handleApplyFilter()
    _initICheckBox()
    _initTrackingDatatable()
    _handleMultiForm()
    _handleProgramStreamServiceShow()
    _handleProgramStreamServiceSelect2()
    _updateProgramStream()
    _enableSaveReferralSource()
    _clickSaveReferral()
    _loadModalReminder()
    _handleSearchClient()
    _handleMultiFormAssessmentCaseNote()
    _loadSteps()
    _search_client_date_logic_error()
    _familyInActiveProgramStream()

  loadFamilyTab = ->
    if $('.lazy-load-family-tab').length > 0
      $.ajax
        type: 'GET'
        url: '/dashboards/family_tab'
        dataType: 'JSON'
        success: (response) ->
          $(".lazy-load-family-tab").html(response.data)
          _familyType()
    else
      _familyType()
      _handleFamilyProgramStreamChart()

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

  _familyType = ->
    element = $('#family-type')
    data    = $(element).data('content-count')
    report = new CIF.ReportCreator(data, '', '', element)
    report.pieChart(option: true)

  _clientProgramStreamByGender = ->
    element = $('#client-program-stream')
    data    = $(element).data('content-count')
    title    = $(element).data('title')

    programNames = [
                  data[0].active_data.map(({name}) ->
                    name
                  )
                  data[1].active_data.map(({name}) ->
                    name
                  )
                  data[2].active_data.map(({name}) ->
                    name
                  )
                ]

    categories = _.uniq(_.flatten(programNames))
    data =
      categories: categories
      series: data.map (element, index) ->
        {
          name: element['name']
          data: data[index].active_data.map((subElement) ->
            subElement['y']
          )
          color: if index == 0 then '#f9c00c' else if index == 1 then '#4caf50' else '#00695c'
        }

    report = new CIF.ReportCreator(data, title, '', element)
    report.barChart()

  _clientProgramStream = ->
    element = $('#client-by-program-stream')
    data    = $(element).data('content-count')
    title    = $(element).data('title')
    report = new CIF.ReportCreator(data, title, '', element)
    report.pieChart(option: true)

  _handleMultiForm = ->
    _initMultiFormDatatable('#custom-fields-table')
    _initMultiFormDatatable('#family-table')
    _initMultiFormDatatable('#partner-table')
    _initMultiFormDatatable('#user-table')
    _initMultiFormDatatable('#program-enrollment-table')

  _initTrackingDatatable = ->
    self = $('#program-streams-table')
    $(self).DataTable
      bFilter: false
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

  _initMultiFormDatatable = (tableId) ->
    self = $(tableId)
    $(self).DataTable
      bFilter: false
      bInfo: false
      processing: true
      serverSide: true
      ajax: $(self).data('url')
      columns: [
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
    $('#program-stream-service-modal.modal-popup').modal('show')

    $('#referral-source-category-reminder button[data-dismiss=modal]').click ->
      $('#program-stream-service-modal').modal('show') if $('#program-stream-service-modal .modal-body .row').length > 0
      return

    $('#program-stream-service-modal button[data-dismiss=modal]').click ->
      $('.modal.in').removeClass('modal-popup')
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
      $('#select2-drop').addClass('drop')
      arr = []
      i = 0
      while i < $('.type-of-service').data('custom').length
        arr.push i
        i++

      options = $('.type-of-service').data('custom')
      results = []
      chunk_size = 13
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
          url: $(@).attr('action')
          data: $(this).serialize()
          dataType: 'JSON'
          success: (json) ->
            successImg = $("#edit_program_stream_#{json.program_stream.id} .save-success-#{json.program_stream.id}").removeClass('hide')
            $("#edit_program_stream_#{json.program_stream.id} input[type='submit']").replaceWith(successImg)
            return
          error: (response, status, msg) ->
            $("form[action='#{@url}'] .program_stream_services").append "<p class='help-block'>Failed to update program stream.</p>" if $(this.parentElement).find('.help-block').length == 0
            $("form[action='#{@url}'] .program_stream_services").addClass('has-error')
            return
      else
        $("##{this.id} .program_stream_services").append "<p class='help-block'>#{$("input#blank").val()}</p>" if $("##{this.id} .program_stream_services .help-block").length == 0
        $("##{this.id} .program_stream_services").addClass('has-error')

  _handleSearchClient = ->
    $('#client-search.modal').on 'shown.bs.modal', (e) ->
      searchForClient = $("#search_for_client_format-input").val()
      searchingClient = $("#searching_format-input").val()
      notFoundClient = $("#not_found_format-input").val()
      enterCharacters = $("#please_enter_more_char_format-input").val()
      $('#search-client-select2').select2(
        placeholder: searchForClient
        minimumInputLength: 1
        formatSearching: searchingClient
        formatNoMatches: notFoundClient
        formatInputTooShort: enterCharacters
        ajax:
          url: '/api/clients/search_client'
          dataType: 'json'
          quietMillis: 250
          data: (term, page) ->
            { q: term }
          results: (data, page) ->
            { results: data }
          cache: true
        initSelection: (element, callback) ->
            id = $(element).select2('data', null).trigger("change")
            return
        formatResult: (client) ->
          en_full_name = "#{client.given_name} #{client.family_name}"
          local_full_name = "#{client.local_given_name} #{client.local_family_name}"
          markup = "<a href='clients/#{client.slug}'>#{en_full_name} | #{local_full_name} (#{client.id})</a>"

          return markup
        formatSelection: (client) ->
          win = window.open("clients/#{client.slug}", '_blank')
          $('#search-client-select2').trigger("change")
      ).on 'select2-blur select2-focus', ->
        $(@).trigger("change")
        return

      $(window).focus(->
        $('#search-client-select2').trigger("change")
        return
      ).blur ->
        $('#s2id_search-client-select2 .select2-chosen').attr('style', 'color: #999999').text(searchForClient) if $('#s2id_search-client-select2 .select2-chosen').val().length == 0
        return

  _handleMultiFormAssessmentCaseNote = ->
    $('#client-select-assessment').on('select2-selected', (e) ->
      $("ul#assessment-tab-dropdown a").removeClass('disabled')
      idClient = e.val
      if $('#csi-assessment-link').length
        csiLink = "/clients/#{idClient}/assessments/new?country=cambodia&default=true&from=dashboards"
        a = document.getElementById('csi-assessment-link').href = csiLink
      if $('ul#assessment-tab-dropdown .custom-assessment-link').length
        customAssessmentLinks = $('ul#assessment-tab-dropdown .custom-assessment-link')
        $.each customAssessmentLinks, (index, element) ->
          url = $(element).attr('href').replace(/\/\//, "/#{idClient}/")
          $(element).attr('href', url)

      $("#assessment-tab-dropdown").removeClass('disabled')
      $(this).val('')
    ).on 'select2-removed', () ->
      $("ul#assessment-tab-dropdown a").attr('href', "javascript:void(0)")
      $("ul#assessment-tab-dropdown a").addClass('disabled')

    $('#client-select-case-note').on('select2-selected', (e) ->
      $("ul#casenote-tab-dropdown a").removeClass('disabled')
      idClient = e.val
      if $('#csi-case-note-link').length
        csiLink = "/clients/#{idClient}/assessments/new?country=cambodia&default=true&from=dashboards"
        a = document.getElementById('csi-case-note-link').href = csiLink
      if $('ul#casenote-tab-dropdown .custom-assessment-link').length
        customAssessmentLinks = $('ul#casenote-tab-dropdown .custom-assessment-link')
        $.each customAssessmentLinks, (index, element) ->
          url = $(element).attr('href').replace(/\/\//, "/#{idClient}/")
          $(element).attr('href', url)
      $(this).val('')
    ).on 'select2-removed', () ->
      $("ul#casenote-tab-dropdown a").attr('href', "javascript:void(0)")
      $("ul#casenote-tab-dropdown a").addClass('disabled')


  _loadSteps = (form) ->
    bodyTag = 'div'
    rootId = "#rootwizard"
    that = @
    $(rootId).steps
      headerTag: 'h4'
      bodyTag: bodyTag
      enableAllSteps: true
      transitionEffect: 'slideLeft'
      autoFocus: true
      titleTemplate: '#title#'
      labels:
        finish: $(rootId).data('finish')
        next: $(rootId).data('next')
        previous: $(rootId).data('previous')
      onInit: (event, currentIndex) ->
        currentTab  = "#{rootId}-p-#{currentIndex}"
        _clientProgramStreamByGender()
        return

      onStepChanging: (event, currentIndex, newIndex) ->
        console.log 'onStepChanging'
        currentTab  = "#{rootId}-p-#{currentIndex}"
        return true

      onStepChanged: (event, currentIndex, priorIndex) ->
        console.log 'onStepChanged'
        currentTab  = "#{rootId}-p-#{currentIndex}"
        currentStep = $("#{rootId}-p-" + currentIndex)
        if $("#{currentTab} #active-client:visible").length
          url = $("#active-client").data('url')
          _active_client_by_gender(url)
        else if $("#{currentTab} #active-case-by-donor:visible").length
          url = $("#active-case-by-donor").data('url')
          _active_case_by_donor(url)

  _active_client_by_gender = (url) ->
    element = $('#active-client')
    male = $("#rootwizard").data('male')
    female = $("#rootwizard").data('female')
    other = $("#rootwizard").data('other')
    title = element.data('title')
    $.ajax
      type: 'get'
      url: url
      dataType: 'JSON'
      success: (response) ->
        data =
          categories: [
            'Children'
            'Adult'
            'Other'
          ]
          series: [
            {
              name: female
              data: [
                response.girls
                response.adult_females
                0
              ]
              color: '#f9c00c'
            }
            {
              name: male
              data: [
                response.boys
                response.adult_males
                0
              ]
              color: '#4caf50'
            },
            {
              name: other
              data: [0, 0, response.others]
              color: '#00695c'
            }
          ]

        report = new CIF.ReportCreator(data, title, '', element)
        report.columnChart()
      error: (response, status, msg) ->
        return

  _active_case_by_donor = (url) ->
    element = $('#active-case-by-donor')
    title = element.data('title')
    $.ajax
      type: 'get'
      url: url
      dataType: 'JSON'
      success: (response) ->
        report = new CIF.ReportCreator(response.data, title, '', element)
        report._highChartsPieChart()
      error: (response, status, msg) ->
        return

  # Make monochrome colors
  _pieColors = do ->
    colors = []
    base = Highcharts.getOptions().colors[2]
    i = undefined
    i = 0
    while i < 50
      # Start out with a darkened base color (negative brighten), and end
      # up with a much brighter color
      colors.push Highcharts.color(base).brighten((i - 5) / 7).get()
      i += 1
    colors

  _search_client_date_logic_error = ->
    $('a[href="#data-validation"]').on 'click', ->
      $('#client-date-logic-error').submit()

  _highChartsPieChart = (data, title, element) ->
    $(element).highcharts
      chart:
        plotBackgroundColor: null
        plotBorderWidth: null
        plotShadow: false
        type: 'pie'
      title: text: title
      tooltip: pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
      accessibility: point: valueSuffix: '%'
      plotOptions: pie:
        allowPointSelect: true
        cursor: 'pointer'
        showInLegend: true
        dataLabels:
          enabled: true
          format: '<b>{point.name}</b><br>{point.percentage:.1f} %'
          filter:
            property: 'percentage'
            operator: '>'
            value: 4
        series:
          colorByPoint: true
      series: [ {
        name: title
        data: data
      } ]
    $('.highcharts-credits').css('display', 'none')

  _familyInActiveProgramStream = () ->
    $(document).on 'shown.bs.tab', 'a[aria-controls="family-tab"]', _handleFamilyProgramStreamChart

  _handleFamilyProgramStreamChart = () ->
      url = '/api/program_streams/generate_family_program_stream'
      $.ajax
        type: 'GET'
        url: url
        data: $(this).serialize()
        dataType: 'JSON'
        success: (json) ->
          element = $('#family-program-stream')
          data    = json.data
          title    = $(element).data('title')

          $('#family-active-program-stream h2.font-bold').html(json.program_stream_count)
          report = new CIF.ReportCreator(data, title, '', element)
          report.pieChart(option: true)
          return
        error: (response, status, msg) ->
          console.log(msg)
          return
      return

  { init: _init }
