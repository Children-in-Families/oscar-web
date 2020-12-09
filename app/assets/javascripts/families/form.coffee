CIF.FamiliesNew = CIF.FamiliesCreate = CIF.FamiliesEdit = CIF.FamiliesUpdate = do ->
  _init = ->
    _initWizardForm()
    _initSelect2()
    _ajaxChangeDistrict()
    _cocoonCallback()
    _initDatePicker()
    _initIcheck()
    _onChangeReferralSourceCategory()


  _validateForm = ->
    valid = true

    for select in $("select.required, input.required")
      $(select).trigger("validate")
      if $(select).hasClass("error") || $(select).closest(".form-group").find(".select2-choice").hasClass("error")
        valid = false

    valid

  _initWizardForm = ->
    $("#family-wizard-form").steps
      headerTag: 'h3'
      bodyTag: 'section'
      enableAllSteps: true
      transitionEffect: 'slideLeft'
      autoFocus: true
      titleTemplate: '#title#'
      enableCancelButton: true
      labels:
        finish: 'Save'
      onStepChanging: (event, currentIndex, newIndex) ->
        (currentIndex > newIndex) || _validateForm()
      onFinishing: (event, currentIndex) ->
        $("#family-form").submit()
      onCanceled: ->
        result = confirm('Are you sure?')
        if result
          window.location = $("#family-form").data("cancelUrl")

  _onChangeReferralSourceCategory = ->
    referralSources = $("#family_referral_source_id").data("sources")

    $('#family_referral_source_category_id').change ->
      $("#family_referral_source_id").val(null).trigger('change')
      $("#family_referral_source_id").find('option[value!=""]').remove()

      for categorySource in referralSources
        if $(@).val() == categorySource[2]
          $("#family_referral_source_id").append("<option value='#{categorySource[0]}'>#{categorySource[1]}</option>")

  _initIcheck = ->
    $('.i-checks').iCheck
      checkboxClass: 'icheckbox_square-green'
      radioClass: 'iradio_square-green'

  _initSelect2 = ->
    $('select').select2
      allowClear: true

    $('select.required').on "change", (e) ->
      $(@).trigger("validate")

    $('select.required, input.required').on "validate", (e) ->
      $select = $(@)
      $select.removeClass("error")
      $select.closest(".form-group").find(".select2-choice, .select2-choices").removeClass("error")
      $select.closest(".form-group").find("label.control-label").removeClass("error")
      $select.closest(".form-group").find("label.error").remove()

      if $select.val() == null || $select.val().length == 0
        $select.addClass("error")
        $select.closest(".form-group").find(".select2-choice, .select2-choices").addClass("error")
        $select.closest(".form-group").find("label.control-label").addClass("error")
        $select.closest(".form-group").append("<label class='error'>This field is required.</label>")

  _clearSelectedOption = ->
    formAction = $('body').attr('id')
    $('#family_family_type').val('') unless formAction.includes('edit') || formAction.includes('update')

  _cocoonCallback = ->
    $('#family-members').on 'cocoon:after-insert', ->
      _initSelect2()
      _initDatePicker()
      _initIcheck()

  _initDatePicker = ->
    $('.date-picker').datepicker
      autoclose: true
      format: 'yyyy-mm-dd'
      todayHighlight: true
      startDate: '1899,01,01'
      clearBtn: true
      disableTouchKeyboard: true

    $('.date-picker').on "hide", (e) ->
      $(e.currentTarget).trigger("validate")

  _ajaxChangeDistrict = ->
    mainAddress = $('#family_province_id, #family_district_id, #family_commune_id')
    mainAddress.on 'change', ->
      type       = $(@).data('type')
      typeId     = $(@).val()
      subAddress = $(@).data('subaddress')

      if type == 'provinces'
        subResources = 'districts'
        subAddress =  switch subAddress
                      when 'district' then $('#family_district_id')

        $(subAddress).val(null).trigger('change')
        $(subAddress).find('option[value!=""]').remove()
      else if type == 'districts'
        subResources = 'communes'
        subAddress =  switch subAddress
                      when 'commune' then $('#family_commune_id')

        $(subAddress).val(null).trigger('change')
        $(subAddress).find('option[value!=""]').remove()
      else if type == 'communes'
        subResources = 'villages'
        subAddress =  switch subAddress
                      when 'village' then $('#family_village_id')


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

  { init: _init }
