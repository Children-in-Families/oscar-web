CIF.FamiliesNew = CIF.FamiliesCreate = CIF.FamiliesEdit = CIF.FamiliesUpdate = do ->
  _init = ->
    _initWizardForm()
    _initSelect2()
    _ajaxChangeDistrict()
    _cocoonCallback()
    _initDatePicker()
    _initIcheck()
    _onChangeReferralSourceCategory()
    _initUploader()
    _initSelect2SingleSelect()
    $('[data-toggle="popover"]').popover()

  _initSelect2SingleSelect = () ->
    $('select.single-select').select2
      maximumSelectionSize: 1
      allowClear: true

  _validateForm = (currentIndex) ->
    valid = true
    currentSection = "#family-wizard-form-p-#{currentIndex}"
    for select in $("#{currentSection} select.required, #{currentSection} input.required")
      $(select).trigger("validate")
      if $(select).hasClass("error") || $(select).closest(".form-group").find(".select2-choice").hasClass("error")
        valid = false

    if(currentIndex == 2)
      for select in $("#{currentSection} select.required, #{currentSection} input.required, #{currentSection} textarea.required")
        $(select).trigger("validate")
        if $(select).hasClass("error") || $(select).closest(".form-group").find(".select2-choice").hasClass("error")
          valid = false

    valid

  _toggleDisableFamilySelect = ->
    $(".nested-fields [name$='[client_id]']")
    $.each $(".nested-fields"), (index, row) ->
      memberRow = $(row)
      select = memberRow.find('[name$="[client_id]"]')
      select.find("option").attr("disabled", false)

      $.each $(".nested-fields"), (index, row) ->
        tmpMemberRow = $(row)
        tmpSelect = tmpMemberRow.find('[name$="[client_id]"]')

        if tmpSelect.val().length > 0 && tmpSelect.attr("id") != select.attr("id")
          select.find("option[value=#{tmpSelect.val()}]").attr("disabled", true)

  _initUploader = ->
    $('.file .optional').fileinput
      showUpload: false
      showPreview: false
      removeClass: 'btn btn-danger btn-outline'
      browseLabel: 'Browse'
      theme: "explorer"
      allowedFileExtensions: ['jpg', 'png', 'jpeg', 'doc', 'docx', 'xls', 'xlsx', 'pdf']

  _initWizardForm = ->
    window.savingFamily = false

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
      onInit: (event, currentIndex) ->
        _validateForm(currentIndex)
      onStepChanging: (event, currentIndex, newIndex) ->
        (currentIndex > newIndex) || _validateForm(currentIndex)
      onFinishing: (event, currentIndex) ->
        if window.savingFamily == false && _validateForm(currentIndex)
          $("#family-form").submit()
          window.savingFamily = true
        return true
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

    $('.i-checks.is-client').on "ifChecked", _onMarkAsClient
    $('.i-checks.is-client').on "ifUnchecked", _onUnmarkAsClient

    $.each $(".nested-fields"), (index, row) ->
      familyRow = $(row)
      select = familyRow.find('[name$="[client_id]"]')
      familyRow.find('[name$="[gender]"]').attr("disabled", !select.hasClass("hidden"))
      familyRow.find('[name$="[date_of_birth]"]').attr("disabled", !select.hasClass("hidden"))

      _onChangeClient(select)

  _onUnmarkAsClient = ->
    familyRow = $(@).closest(".nested-fields")
    familyRow.find('[name$="[client_id]"]').addClass("hidden")
    familyRow.find('[name$="[client_id]"]').val(null)
    familyRow.find('[name$="[client_id]"]').trigger('change')

    familyRow.find('[name$="[adult_name]"]').removeClass("hidden")
    familyRow.find('[name$="[adult_name]"]').attr("disabled", false)

    familyRow.find('[name$="[gender]"]').attr("disabled", false)
    familyRow.find('[name$="[date_of_birth]"]').attr("disabled", false)

  _onMarkAsClient = ->
    familyRow = $(@).closest(".nested-fields")

    familyRow.find('[name$="[client_id]"]').removeClass("hidden")
    familyRow.find('[name$="[adult_name]"]').addClass("hidden")
    familyRow.find('[name$="[adult_name]"]').attr("disabled", true)

    familyRow.find('[name$="[gender]"]').attr("disabled", true)
    familyRow.find('[name$="[date_of_birth]"]').attr("disabled", true)

    _onChangeClient(familyRow.find('[name$="[client_id]"]'))

  _onChangeClient = (select) ->
    $select = $(select)
    familyRow = $select.closest(".nested-fields")

    $select.change (e)->
      data = $(@).find("option:selected").data()

      familyRow.find('[name$="[gender]"]').val(data.gender)
      familyRow.find('[name$="[gender]"]').trigger('change')
      familyRow.find('[name$="[date_of_birth]"]').datepicker('update', data.dateOfBirth)

      _toggleDisableFamilySelect()

  _initSelect2 = ->
    $('select').select2
      allowClear: true
    .on 'select2-opening', ->
      if $('#family-wizard-form-p-1:visible').length > 0
        selectedValues = $.map($('select[id*=\'_client_id\']'), (element, index) ->
          $(element).val()
        )
        i = 1
        while i < @options.length
          if _.includes(selectedValues, @options[i].value)
            $(@options[i]).addClass('hidden')
          i++

    $('select.required').on "change", (e) ->
      $(@).trigger("validate")

    $('select.required, input.required, textarea.required').on "validate", (e) ->
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

      $.each $(".nested-fields"), (index, row) ->
        memberRow = $(row)
        select = memberRow.find('[name$="[client_id]"]')
        select.trigger("change") if select.val().length > 0

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
    mainAddress = $('#family_province_id, #family_city_id, #family_district_id, #family_commune_id')
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
