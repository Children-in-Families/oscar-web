CIF.ClientsNew = CIF.ClientsCreate = CIF.ClientsUpdate = CIF.ClientsEdit = do ->
  _init = ->
    @filterTranslation = ''
    _getTranslation()
    _initWizardForm()
    _initICheck()
    _ajaxChangeDistrict()
    _ajaxChangeSubDistrict()
    _ajaxChangeTownship()
    _initDatePicker()
    _replaceSpanBeforeLabel()
    _replaceSpanAfterRemoveField()
    _clientSelectOption()
    _removeSaveButton()
    _setSaveButton()
    _removeMarginOnNewForm()
    _setMarginToClassActions()
    _setCancelButtonPosition()
    _handReadonlySpecificPoint()
    _initUploader()
    _enableDoneButton()

  _handReadonlySpecificPoint = ->
    $('#specific-point select[data-readonly="true"]').select2('readonly', true)

  _ajaxChangeDistrict = ->
    mainAddress = $('#client_province_id, #client_district_id, #client_commune_id')
    mainAddress.on 'change', ->
      type       = $(@).data('type')
      typeId     = $(@).val()
      subAddress = $(@).data('subaddress')

      if type == 'provinces'
        subResources = 'districts'
        subAddress =  switch subAddress
                      when 'district' then $('#client_district_id')

        $(subAddress).val(null).trigger('change')
        $(subAddress).find('option[value!=""]').remove()
      else if type == 'districts'
        subResources = 'communes'
        subAddress =  switch subAddress
                      when 'commune' then $('#client_commune_id')

        $(subAddress).val(null).trigger('change')
        $(subAddress).find('option[value!=""]').remove()
      else if type == 'communes'
        subResources = 'villages'
        subAddress =  switch subAddress
                      when 'village' then $('#client_village_id')


        $(subAddress).val(null).trigger('change')
        $(subAddress).find('option[value!=""]').remove()

      if typeId != ''
        $.ajax
          method: 'GET'
          url: "/api/#{type}/#{typeId}/#{subResources}"
          dataType: 'JSON'
          success: (response) ->
            for address in response.data
              subAddress.append("<option value='#{address.id}'>#{address.name}</option>")
  _ajaxChangeSubDistrict = ->
    $('#client_district_id').on 'change', ->
      district_id = $(@).val()
      $('select#client_subdistrict_id').val(null).trigger('change')
      $('select#client_subdistrict_id option[value!=""]').remove()
      if district_id != ''
        $.ajax
          method: 'GET'
          url: "/api/districts/#{district_id}/subdistricts"
          dataType: 'JSON'
          success: (response) ->
            subdistricts = response.subdistricts
            for subdistrict in subdistricts
              $('select#client_subdistrict_id').append("<option value='#{subdistrict.id}'>#{subdistrict.name}</option>")

  _ajaxChangeTownship = ->
    $('#client_state_id').on 'change', ->
      state_id = $(@).val()
      $('select#client_township_id').val(null).trigger('change')
      $('select#client_township_id option[value!=""]').remove()
      if state_id != ''
        $.ajax
          method: 'GET'
          url: "/api/states/#{state_id}/townships"
          dataType: 'JSON'
          success: (response) ->
            townships = response.townships
            for township in townships
              $('select#client_township_id').append("<option value='#{township.id}'>#{township.name}</option>")

  _ajaxCheckExistClient = ->
    $("a[href='#finish']").text(filterTranslation.done).append('...').attr("disabled","disabled");
    data = {
      given_name: $('#client_given_name').val()
      family_name: $('#client_family_name').val()
      local_given_name: $('#client_local_given_name').val()
      local_family_name: $('#client_local_family_name').val()
      date_of_birth: $('#client_date_of_birth').val()
      birth_province: $('#client_birth_province_id').find(':selected').text()
      current_province: $('#client_province_id').find(':selected').text()
      village: $('#client_village_id').find(':selected').text()
      commune: $('#client_commune_id').find(':selected').text()
    }

    if data.date_of_birth != '' or data.given_name != '' or data.birth_province != '' or data.family_name != '' or data.local_given_name != '' or data.local_family_name != '' or data.village != '' or data.commune != '' or data.current_province != ''
      $.ajax({
        type: 'GET'
        url: '/api/clients/compare'
        data: data
        dataType: "JSON"
      }).success((json)->
        clientId  = $('#client_slug').val()
        organizations   = json.organizations
        if clientId == '' and organizations.length > 0
          modalTitle      = $('#hidden_title').val()
          modalTextFirst  = $('#hidden_body_first').val()
          modalTextSecond = $('#hidden_body_second').val()
          modalTextThird  = $('#hidden_body_third').val()
          clientName      = $('#client_given_name').val()

          modalText = []
          for organization in organizations
            modalText.push("<p>#{modalTextFirst} #{organization}#{modalTextSecond} #{organization} #{modalTextThird}<p/>")

          $('#confirm-client-modal .modal-header .modal-title').text(modalTitle)
          $('#confirm-client-modal .modal-body').html(modalText)

          $('#confirm-client-modal').modal('show')
          $('#confirm-client-modal #confirm').on 'click', ->
            $(@).text($(@).data('confirm')).append('...').attr("disabled","disabled");
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

    $('.select2-locked div').attr 'title', $('#hidden_text').val()
    $('select.able-related-info').change ->
      qtSelectedSize = $('select.able-related-info option:selected').length

      if qtSelectedSize > 0
        $('#client_able').val(true)
        $('#fake_client_able').prop('checked', true)
      else
        $('#client_able').val(false)
        $('#fake_client_able').prop('checked', false)

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
      enableKeyNavigation: true
      enableAllSteps: true

      onStepChanging: (event, currentIndex, newIndex) ->
        if currentIndex == 0 and (1 <= newIndex <=3 ) and $('#getting-started').is(':visible')
          _validateForm()
          form.valid()
          client_received_by_id         = $('#client_received_by_id').val() == ''
          client_user_ids               = $('#client_user_ids').val() == null
          client_initial_referral_date  = $('#client_initial_referral_date').val() == ''
          client_referral_source_id     = $('#client_referral_source_id').val() == ''
          client_name_of_referee        = $('#client_name_of_referee').val() == ''
          client_gender                 = $('#client_gender').val() == ''
          clientIsExited                = $('#client_status').val() == 'Exited'

          if clientIsExited
            if client_received_by_id or client_initial_referral_date or client_referral_source_id or client_name_of_referee or client_gender
              return false
            else
              return true
          else
            if client_user_ids or client_received_by_id or client_initial_referral_date or client_referral_source_id or client_name_of_referee or client_gender
              return false
            else
              return true
        else
          return true

      onFinishing: (event, currentIndex) ->
        _validateForm()
        form.valid()

      onFinished: (event, currentIndex) ->
        form.valid()
        _ajaxCheckExistClient()

      labels:
        next: self.filterTranslation.next
        previous: self.filterTranslation.previous
        finish: self.filterTranslation.done

      $(document).keydown (e) ->
        if !($('.form-control').is(':focus'))
          if e.keyCode == 39
            $('.current').next().focus()

          if e.keyCode == 37
            $('.current').prev().focus()

  _replaceSpanAfterRemoveField = ->
    $('#client_initial_referral_date').on 'input', ->
      if $(this).val() == ''
        $("a[href='#next']").click()

  _replaceSpanBeforeLabel = ->
    $("a[href='#next']").click ->
      inputGroupElement = $('.client_initial_referral_date > .input-group')
      labelElement      = $('#client_initial_referral_date-error')

      labelElement.insertAfter inputGroupElement

    $("a[href='#steps-uid-0-h-1']").click ->
      inputGroupElement = $('.client_initial_referral_date > .input-group')
      labelElement      = $('#client_initial_referral_date-error')

      labelElement.insertAfter inputGroupElement

  _removeSaveButton = ->
    $("a[href='#next']").click ->
      if $(".last").attr('aria-selected') == 'true'
        $('.save-edit-client').hide()
        $('.actions').css 'margin-left', '0'
        $('.cancel-client-button').css 'margin-top', '-67px'

    $("a[href='#steps-uid-0-h-3']").click ->
      if $(".last").attr('aria-selected') == 'true'
        $('.save-edit-client').hide()
        $('.actions').css 'margin-left', '0'
        $('.cancel-client-button').css 'margin-top', '-67px'

  _setSaveButton = ->
    current_url = window.location.href
    if $('.edit-form').length
      $("a[href='#previous']").click ->
        if $(".last").attr('aria-selected') != 'true'
          _saveButton()
      $("a[href='#steps-uid-0-h-0']").click ->
        _saveButton()
      $("a[href='#steps-uid-0-h-1']").click ->
        _saveButton()
      $("a[href='#steps-uid-0-h-2']").click ->
        _saveButton()

  _saveButton = ->
    current_url = window.location.href
    if $(".last").attr('aria-selected') != 'true'
      $('.save-edit-client').show()
      $('.cancel-client-button').css 'margin-top', '-97px'
      if current_url.includes('locale=my')
        $('.actions').css 'margin-left', '-155px'
      else if current_url.includes('locale=km')
        $('.actions').css 'margin-left', '-75px'
      else
        $('.actions').css 'margin-left', '-65px'

  _setMarginToClassActions = ->
    current_url = window.location.href
    if $('.edit-form').length
      if current_url.includes('locale=my')
        $('.actions').css 'margin-left', '-155px'
      else if current_url.includes('locale=km')
        $('.actions').css 'margin-left', '-75px'
      else
        $('.actions').css 'margin-left', '-65px'

  _removeMarginOnNewForm = ->
    if $('.client-form-title').length
      $('.actions').css 'margin-left', '0px'

  _setCancelButtonPosition = ->
    $('.cancel-client-button').css 'margin-left', '8px'
    if $('.edit-form').length
      $('.cancel-client-button').css 'margin-top', '-97px'
    else
      $('.cancel-client-button').css 'margin-top', '-67px'

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
        "client[gender]": ruleRequired

      }
      messages: {
        "client[received_by_id]": requiredMessage
        "client[user_ids][]": requiredMessage
        "client[initial_referral_date]": requiredMessage
        "client[referral_source_id]": requiredMessage
        "client[name_of_referee]": requiredMessage
        "client[gender]": requiredMessage
      }

    $('#client_initial_referral_date, #client_user_ids, #client_received_by_id, #client_referral_source_id, #client_gender').change ->
      $(this).removeClass 'error'
      $(this).closest('.form-group').find('label.error').remove()

  _initUploader = ->
    path = $('#client_profile').data('img-src')
    $('.file .optional').fileinput
      showUpload: false
      removeClass: 'btn btn-danger btn-outline'
      browseLabel: 'Browse'
      theme: "explorer"
      allowedFileExtensions: ['jpg', 'png', 'jpeg']
      initialPreview: ["<img src=#{path} class='file-preview-image'>"] if path != '' and path != 'image-placeholder.png'

  _enableDoneButton = ->
    $("a[href='#previous'], .btn-modal-cancel").on 'click', ->
      $("a[href='#finish']").removeAttr("disabled").text(filterTranslation.done);

  { init: _init }
