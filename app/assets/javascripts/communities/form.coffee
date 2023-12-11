CIF.CommunitiesNew = CIF.CommunitiesCreate = CIF.CommunitiesEdit = CIF.CommunitiesUpdate = do ->
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

    for select in $("select.received-by.required, select.referral-date.required, select.caseworker.required, input.required")
      $(select).trigger("validate")
      if $(select).hasClass("error") || $(select).closest(".form-group").find(".select2-choice").hasClass("error")
        valid = false

    if(currentIndex == 2)
      for select in $("select.required, input.required, textarea.required")
        $(select).trigger("validate")
        if $(select).hasClass("error") || $(select).closest(".form-group").find(".select2-choice").hasClass("error")
          valid = false

    valid

  _initUploader = ->
    $('.file .optional').fileinput
      showUpload: false
      showPreview: false
      removeClass: 'btn btn-danger btn-outline'
      browseLabel: 'Browse'
      theme: "explorer"
      allowedFileExtensions: ['jpg', 'png', 'jpeg', 'doc', 'docx', 'xls', 'xlsx', 'pdf']

  _initWizardForm = ->
    window.savingCommunity = false

    $("#community-wizard-form").steps
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
        (currentIndex > newIndex) || _validateForm(currentIndex)
      onFinishing: (event, currentIndex) ->
        if window.savingCommunity == false && _validateForm(currentIndex)
          $("#community-form").submit()
          window.savingCommunity = true
        return true
      onCanceled: ->
        result = confirm('Are you sure?')
        if result
          window.location = $("#community-form").data("cancelUrl")

  _onChangeReferralSourceCategory = ->
    referralSources = $("#community_referral_source_id").data("sources")

    $('#community_referral_source_category_id').change ->
      $("#community_referral_source_id").val(null).trigger('change')
      $("#community_referral_source_id").find('option[value!=""]').remove()

      for categorySource in referralSources
        if $(@).val() == categorySource[2]
          $("#community_referral_source_id").append("<option value='#{categorySource[0]}'>#{categorySource[1]}</option>")

  _initIcheck = ->
    $('.i-checks').iCheck
      checkboxClass: 'icheckbox_square-green'
      radioClass: 'iradio_square-green'

    $('.i-checks.is-family').on "ifChecked", _onMarkAsFamily
    $('.i-checks.is-family').on "ifUnchecked", _onUnmarkAsFamily

    $.each $(".nested-fields"), (index, row) ->
      memberRow = $(row)
      select = memberRow.find('[name$="[family_id]"]')

      memberRow.find('[name$="[adule_male_count]"]').attr("disabled", !select.hasClass("hidden"))
      memberRow.find('[name$="[adule_female_count]"]').attr("disabled", !select.hasClass("hidden"))
      memberRow.find('[name$="[kid_male_count]"]').attr("disabled", !select.hasClass("hidden"))
      memberRow.find('[name$="[kid_female_count]"]').attr("disabled", !select.hasClass("hidden"))

      _onChangeFamily(select)

  _onUnmarkAsFamily = ->
    memberRow = $(@).closest(".nested-fields")
    memberRow.find('[name$="[family_id]"]').addClass("hidden")
    memberRow.find('[name$="[family_id]"]').val(null)
    memberRow.find('[name$="[family_id]"]').trigger('change')
    memberRow.find('[name$="[name]"]').removeClass("hidden")
    memberRow.find('[name$="[name]"]').attr("disabled", false)

    memberRow.find('[name$="[adule_male_count]"]').attr("disabled", false)
    memberRow.find('[name$="[adule_female_count]"]').attr("disabled", false)
    memberRow.find('[name$="[kid_male_count]"]').attr("disabled", false)
    memberRow.find('[name$="[kid_female_count]"]').attr("disabled", false)

  _onMarkAsFamily = ->
    memberRow = $(@).closest(".nested-fields")

    memberRow.find('[name$="[family_id]"]').removeClass("hidden")
    memberRow.find('[name$="[name]"]').addClass("hidden")
    memberRow.find('[name$="[name]"]').attr("disabled", true)

    memberRow.find('[name$="[adule_male_count]"]').attr("disabled", true)
    memberRow.find('[name$="[adule_female_count]"]').attr("disabled", true)
    memberRow.find('[name$="[kid_male_count]"]').attr("disabled", true)
    memberRow.find('[name$="[kid_female_count]"]').attr("disabled", true)

    _onChangeFamily(memberRow.find('[name$="[family_id]"]'))

  _onChangeFamily = (select) ->
    $select = $(select)
    memberRow = $select.closest(".nested-fields")

    $select.change (e)->
      data = $(@).find("option:selected").data()
      memberRow.find('[name$="[adule_male_count]"]').val(data.maleAdultCount)
      memberRow.find('[name$="[adule_female_count]"]').val(data.femaleAdultCount)
      memberRow.find('[name$="[kid_male_count]"]').val(data.maleChildrenCount)
      memberRow.find('[name$="[kid_female_count]"]').val(data.femaleChildrenCount)

      _toggleDisableFamilySelect()

  _initSelect2 = ->
    $('select').select2
      allowClear: true

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

  _toggleDisableFamilySelect = ->
    $(".nested-fields [name$='[family_id]']")
    $.each $(".nested-fields"), (index, row) ->
      memberRow = $(row)
      select = memberRow.find('[name$="[family_id]"]')
      select.find("option").attr("disabled", false)

      $.each $(".nested-fields"), (index, row) ->
        tmpMemberRow = $(row)
        tmpSelect = tmpMemberRow.find('[name$="[family_id]"]')

        if tmpSelect.val().length > 0 && tmpSelect.attr("id") != select.attr("id")
          select.find("option[value=#{tmpSelect.val()}]").attr("disabled", true)

  _cocoonCallback = ->
    $('#community-members').on 'cocoon:after-insert', ->
      _initSelect2()
      _initDatePicker()
      _initIcheck()

      $.each $(".nested-fields"), (index, row) ->
        memberRow = $(row)
        select = memberRow.find('[name$="[family_id]"]')
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
    mainAddress = $('#community_province_id, #community_city_id, #community_district_id, #community_commune_id')
    resourceMapping = { cities: 'community_city_id', districts: 'community_district_id', subdistricts: 'community_subdistrict_id', communes: 'community_commune_id', villages: 'family_village_id' }
    mainAddress.on 'change', ->
      type       = $(@).data('type')
      typeId     = $(@).val()
      subAddresses = $(@).data('subaddresses')
      subResource = subAddresses[0]

      $(subAddresses || []).each (index, subAddress) =>
        $("##{resourceMapping[subAddress]}").val(null).trigger('change')
        $("##{resourceMapping[subAddress]}").find('option[value!=""]').remove()

      if typeId != ''
        $.ajax
          method: 'GET'
          url: "/api/#{type}/#{typeId}/#{subResource}"
          dataType: 'JSON'
          success: (response) ->
            for address in response.data
              $("##{resourceMapping[subResource]}").append("<option value='#{address.id}'>#{address.name}</option>")

  { init: _init }
