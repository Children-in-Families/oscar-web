CIF.FamiliesNew = CIF.FamiliesCreate = CIF.FamiliesEdit = CIF.FamiliesUpdate = do ->
  _init = ->
    _initSelect2()
    _ajaxChangeDistrict()
    _cocoonCallback()
    _initDatePicker()
    _initIcheck()
    _hideMetaField()

  _initIcheck = ->
    $('.i-checks').iCheck
      checkboxClass: 'icheckbox_square-green'
      radioClass: 'iradio_square-green'

  _initSelect2 = ->
    $('select').select2
      allowClear: true
      # _clearSelectedOption()

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
      autoclose: true,
      format: 'yyyy-mm-dd',
      todayHighlight: true,
      disableTouchKeyboard: true

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

  _hideMetaField = ->
    meta_fields = $('#family-meta-field').data "meta-fields"
    meta_fields.forEach (meta_field) ->
      if meta_field.hidden == true && meta_field.required == false
        if meta_field.field_name == "family_members_attributes"
          $("#family-members").css 'display','none'
        if $(".family_#{meta_field.field_name}").hasClass "date"
          $(".family_#{meta_field.field_name}").css 'display','none'
        else
          $(".family_#{meta_field.field_name}").parent().css 'display','none'
          meta_field_filtered_id = meta_field.field_name.replace('_id','')
          $(".family_#{meta_field_filtered_id}").parent().css 'display','none'

  { init: _init }
