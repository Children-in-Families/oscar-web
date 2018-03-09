CIF.ClientsNew = CIF.ClientsCreate = CIF.ClientsUpdate = CIF.ClientsEdit = do ->
  _init = ->
    _initWizardForm()
    _ajaxCheckExistClient()
    _ajaxChangeDistrict()
    _validateForm()
    _initDatePicker()
    _replaceSpanBeforeLabel()
    _clientSelectOption()


  _customCheckBox = ->
    $('.i-check-red').iCheck
      radioClass: 'iradio_square-red'

    $('.i-check-brown').iCheck
      radioClass: 'iradio_square-brown'

    $('.i-check-orange').iCheck
      radioClass: 'iradio_square-orange'

    $('.i-checks').iCheck
      checkboxClass: 'icheckbox_square-green'
      radioClass: 'iradio_square-green'

  _initDatePicker = ->
    $('.date-picker').datepicker
      autoclose: true,
      format: 'yyyy-mm-dd',
      todayHighlight: true,
      disableTouchKeyboard: true

  _initWizardForm = ->
    form = $('#client-wizard-form')

    form.children('.client-steps').steps
      headerTag: 'h3'
      bodyTag: 'section'
      transitionEffect: 'slideLeft'
      enableKeyNavigation: false

      onStepChanging: (event, currentIndex, newIndex) ->

        if currentIndex == 0 and newIndex == 1 and $('#getting-started').is(':visible')
          # $('h5.client-form-title').text 'New Client - Page 1: Getting Started'
          form.valid()
          _validateForm()
          client_received_by_id         = $('#client_received_by_id').val() == ''
          client_user_ids               = $('#client_user_ids').val() == ''
          client_initial_referral_date  = $('#client_initial_referral_date').val() == ''
          client_referral_source_id     = $('#client_referral_source_id').val() == ''
          client_name_of_referee        = $('#client_name_of_referee').val() == ''

          if !$('#client_user_ids').val()
            return false
          else if client_user_ids or client_received_by_id or client_initial_referral_date or client_referral_source_id or client_name_of_referee
            return false
          else
            return true

        else if $('#living-detail').is(':visible')
          # $('h5.client-form-title').text 'New Client - Page 2: Living Detail'
          return true
        else if $('#other-detail').is(':visible')
          # $('h5.client-form-title').text 'New Client - Page 3: Other Detail'
          return true
        else if $('#specific-point').is(':visible')
          # $('h5.client-form-title').text 'New Client - Page 4: Specific Point'
          return true

      onFinishing: (event, currentIndex) ->
        form.valid()

      onFinished: (event, currentIndex) ->
        _ajaxCheckExistClient()

  _validateForm = ->
    $('#client-wizard-form').validate
      ignore: []
      rules: {
        "client[received_by_id]":
          required: true
        "client[user_ids]":
          required: true
        "client[initial_referral_date]":
          required: true
        "client[referral_source_id]":
          required: true
        "client[name_of_referee]":
          required: true

      }
      messages: {
        "client[received_by_id]":
          required: "This field is required."
        "client[user_ids]":
          required: "This field is required."
        "client[initial_referral_date]":
          required: "This field is required."
        "client[referral_source_id]":
          required: "This field is required."
        "client[name_of_referee]":
          required: "This field is required."
      }

    $('#client_initial_referral_date').change ->
      $(this).removeClass 'error'
      $(this).closest('.form-group').find('label.error').remove()

    $('select').change ->
      $(this).removeClass 'error'
      $(this).closest('.form-group').find('label.error').remove()

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

  _replaceSpanBeforeLabel = ->
     $("a[href='#next']").click ->
      inputGroupElement = $('.client_initial_referral_date > .input-group')
      labelElement = $('#client_initial_referral_date-error')

      labelElement.insertAfter inputGroupElement

  { init: _init }
