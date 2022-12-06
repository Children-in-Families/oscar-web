CIF.ReferralsNew = CIF.ReferralsCreate = CIF.ReferralsUpdate = CIF.ReferralsEdit = do ->
  @window.getServiceData = (td)->
    data = {id: td.children[0].value, text: td.children[0].text }

    newOption = new Option(data.text, data.id, true, true)
    # Append it to the select
    $('#type-of-service select').append(newOption).trigger 'change'

  _init = ->
    _initSelect2()
    _initExternalReferral()
    _handleExternalReferralSelected()
    _initUploader()
    _selectServiceTypeTableResult()

  _handleExternalReferralSelected = ->
    $('.referral_referred_to').on 'change', ->
      _initExternalReferral()

  _initSelect2 = ->
    $('select').select2().on 'select2-opening', (e) ->
      return true if @.id == 'referral_level_of_risk'

      if $('#type-of-service').data('single-selected') && $(this).select2('val').length > 0
        e.preventDefault()
        return
      else
        return true

  _initExternalReferral = ->
    referredTo = document.getElementById('referral_referred_to')
    if referredTo.textContent == ''
      $('.external-referral-warning').removeClass 'text-hide'
    else
      $('.external-referral-warning').addClass 'text-hide'

  _initUploader = ->
    $('#referral_consent_form').fileinput
      showUpload: false
      removeClass: 'btn btn-danger btn-outline'
      browseLabel: 'Browse'
      theme: "explorer"
      allowedFileExtensions: ['jpg', 'png', 'jpeg', 'doc', 'docx', 'xls', 'xlsx', 'pdf']

  _selectServiceTypeTableResult = () ->
    format = (state) ->
      if !state.id
        return state.text

    serviceFormatSelection = (service) ->
      service.text

    $('#type-of-service select').select2
      width: '100%'
      formatSelection: serviceFormatSelection
      escapeMarkup: (m) ->
        m

    createHeaderElement = (options, indexes)->
      html = ""
      indexes.forEach (entry) ->
        html += "<th><b>#{options[entry][0]}</b></th>"
      html

    createRowElement = (options, indexes) ->
      html = ""
      indexes.forEach (entries) ->
        td = ""
        entries.forEach (index) ->
          td += "<td width='' onclick='getServiceData(this)'><option value='#{options[index][1]}'>#{options[index][0]}</option></td>"

        html += "<tr>#{td}</tr>"
      html

    $('#type-of-service select').on 'select2-open', (e) ->
      arr = []
      i = 0
      while i < $('#type-of-service').data('custom').length
        arr.push i
        i++

      options = $('#type-of-service').data('custom')
      results = []
      chunk_size = 13
      while arr.length > 0
        results.push arr.splice(0, chunk_size)

      indexes = results.shift()
      th  = createHeaderElement(options, indexes)
      row = createRowElement(options, results)

      html = '<table class="table table-bordered" style="margin-top: 5px;margin-bottom: 0px;"><thead>' + th + '</thead><tbody>' + row + '</tbody></table>'
      $('#select2-drop .select2-results').html $(html)
      # $('.select2-results').prepend "#{html}"
      return

    removeError = (element) ->
      element.removeClass('has-error')
      element.find('.help-block').remove()

    $('#type-of-service select').on 'select2-close', (e)->
      uniqueArray = _.compact(_.uniq($(this).val()))

      if uniqueArray.length > 3
        $(this.parentElement).append "<p class='help-block'>#{$('input#confirm-question').val()}</p>" if $(this.parentElement).find('.help-block').length == 0
        $(this.parentElement).addClass('has-error')

      return

    $('#type-of-service select').on 'select2-removed', ->
      uniqueArray = _.compact(_.uniq($(this).val()))
      if uniqueArray.length <= 3
        removeError($(this.parentElement))

  { init: _init }
