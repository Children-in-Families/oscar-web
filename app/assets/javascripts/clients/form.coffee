CIF.ClientsNew = CIF.ClientsCreate = CIF.ClientsUpdate = CIF.ClientsEdit = do ->
  _init = ->
    @filterTranslation = ''
    _getTranslation()
    _initWizardForm()
    _initICheck()
    _ajaxCheckExistClient()
    _ajaxChangeDistrict()
    _initDatePicker()
    _replaceSpanBeforeLabel()
    _replaceSpanAfterRemoveField()
    _clientSelectOption()

  _ajaxChangeDistrict = ->
    $('#client_province_id').on 'change', ->
      province_id = $(@).val()
      $('select#client_district_id').val(null).trigger('change')
      $('select#client_district_id option[value!=""]').remove()
      if province_id != ''
        $.ajax
          method: 'GET'
          url: "/api/provinces/#{province_id}/districts"
          dataType: 'JSON'
          success: (response) ->
            districts = response.districts
            for district in districts
              $('select#client_district_id').append("<option value='#{district.id}'>#{district.name}</option>")

  _ajaxCheckExistClient = ->
    $("a[href='#finish']").click ->
      data = {
        given_name: $('#client_given_name').val()
        family_name: $('#client_family_name').val()
        local_given_name: $('#client_local_given_name').val()
        local_family_name: $('#client_local_family_name').val()
        birth_province_id: $('#client_birth_province_id').val()
        current_province_id: $('#client_province_id').val()
        date_of_birth: $('#client_date_of_birth').val()
        village: $('#client_village').val()
        commune: $('#client_commune').val()
      }
      if data.date_of_birth != '' or data.given_name != '' or data.birth_province_id != '' or data.family_name != '' or data.local_given_name != '' or data.local_family_name != '' or data.village != '' or data.commune != '' or data.current_province_id != ''
        $.ajax({
          type: 'GET'
          url: '/api/clients/compare'
          data: data
          dataType: "JSON"
        }).success((json)->
          clientId  = $('#client_id').val()
          clientIds = []
          clients   = json.clients
          for client in clients
            clientIds.push(String(client.id))

          if clients.length > 0 and clientId not in clientIds
            modalTitle      = $('#hidden_title').val()
            modalTextFirst  = $('#hidden_body_first').val()
            modalTextSecond = $('#hidden_body_second').val()
            modalTextThird  = $('#hidden_body_third').val()
            clientName      = $('#client_given_name').val()
            organizations   = []
            organizations.push(client.organization for client in clients)
            $.unique(organizations[0])
            modalText = []
            for organization in organizations[0]
              modalText.push("<p>#{modalTextFirst} #{organization}#{modalTextSecond} #{organization} #{modalTextThird}<p/>")

            $('#confirm-client-modal .modal-header .modal-title').text(modalTitle)
            $('#confirm-client-modal .modal-body').html(modalText)

            $('#confirm-client-modal').modal('show')
            $('#confirm-client-modal #confirm').on 'click', ->
              $('#client-wizard-form').submit()
          else
            $('#client-wizard-form').submit()
        )
      else
        $('#client-wizard-form').submit()

  _clientSelectOption = ->
    $('select').select2
      minimumInputLength: 0
      allowClear: true
      _clearSelectedOption()

    $('select.able-related-info').change ->
      qtSelectedSize = $('select.able-related-info option:selected').length

      if qtSelectedSize > 0
        $('#client_able').val(true)
        $('#fake_client_able').prop('checked', true)
      else
        $('#client_able').val(false)
        $('#fake_client_able').prop('checked', false)

  _clearSelectedOption = ->
    formAction = $('body').attr('id')
    $('#client_gender').val('') unless formAction.includes('edit')

  _getTranslation = ->
    @filterTranslation =
      done: $('.client-steps').data('done')
      next: $('.client-steps').data('next')
      previous: $('.client-steps').data('previous')
      blank: $('.client-steps').data('blank')

  _initICheck = ->
    $('.radio_buttons').iCheck
      checkboxClass: 'icheckbox_square-green'
      radioClass: 'iradio_square-green'

  _initDatePicker = ->
    $('.date-picker').datepicker
      autoclose: true,
      format: 'yyyy-mm-dd',
      todayHighlight: true,
      disableTouchKeyboard: true

  _initWizardForm = ->
    self = @
    form = $('#client-wizard-form')

    form.children('.client-steps').steps
      headerTag: 'h3'
      bodyTag: 'section'
      transitionEffect: 'slideLeft'
      enableKeyNavigation: false

      onStepChanging: (event, currentIndex, newIndex) ->
        if currentIndex == 0 and newIndex == 1 and $('#getting-started').is(':visible')
          _validateForm()
          form.valid()
          client_received_by_id         = $('#client_received_by_id').val() == ''
          client_user_ids               = $('#client_user_ids').val() == null
          client_initial_referral_date  = $('#client_initial_referral_date').val() == ''
          client_referral_source_id     = $('#client_referral_source_id').val() == ''
          client_name_of_referee        = $('#client_name_of_referee').val() == ''
          clientIsExited                = $('#client_status').val() == 'Exited'

          if clientIsExited
            if client_received_by_id or client_initial_referral_date or client_referral_source_id or client_name_of_referee
              return false
            else
              return true
          else
            if client_user_ids or client_received_by_id or client_initial_referral_date or client_referral_source_id or client_name_of_referee
              return false
            else
              return true

        else
          return true

      onFinishing: (event, currentIndex) ->
        _validateForm()
        form.valid()

      onFinished: (event, currentIndex) ->
        _ajaxCheckExistClient()

      labels:
        next: self.filterTranslation.next
        previous: self.filterTranslation.previous
        finish: self.filterTranslation.done

  _replaceSpanAfterRemoveField = ->
    $('#client_initial_referral_date').on 'input', ->
      if $(this).val() == ''
         $("a[href='#next']").click()

  _replaceSpanBeforeLabel = ->
    $("a[href='#next']").click ->
      inputGroupElement = $('.client_initial_referral_date > .input-group')
      labelElement      = $('#client_initial_referral_date-error')

      labelElement.insertAfter inputGroupElement

  _validateForm = ->
    self = @

    ruleRequired =
      required: true

    requiredMessage =
      required: self.filterTranslation.blank

    $('#client-wizard-form').validate
      ignore: []
      rules: {
        "client[received_by_id]": ruleRequired
        "client[user_ids]": ruleRequired
        "client[initial_referral_date]": ruleRequired
        "client[referral_source_id]":ruleRequired
        "client[name_of_referee]": ruleRequired

      }
      messages: {
        "client[received_by_id]": requiredMessage
        "client[user_ids][]": requiredMessage
        "client[initial_referral_date]": requiredMessage
        "client[referral_source_id]": requiredMessage
        "client[name_of_referee]": requiredMessage
      }

    $('#client_initial_referral_date, #client_user_ids, #client_received_by_id, #client_referral_source_id').change ->
      $(this).removeClass 'error'
      $(this).closest('.form-group').find('label.error').remove()

  { init: _init }
