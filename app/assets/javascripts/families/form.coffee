CIF.FamiliesNew = CIF.FamiliesCreate = CIF.FamiliesEdit = CIF.FamiliesUpdate = do ->
  _init = ->
    _initSelect2()
    _ajaxChangeDistrict()
    _cocoonCallback()
    _initDatePicker()

  _initSelect2 = ->
    $('select').select2
      allowClear: true
      _clearSelectedOption()

  _clearSelectedOption = ->
    formAction = $('body').attr('id')
    $('#family_family_type').val('') unless formAction.includes('edit') || formAction.includes('update')

  _cocoonCallback = ->
    $('#family-members').on 'cocoon:after-insert', ->
      _initDatePicker()

  _initDatePicker = ->
    $('.date-picker').datepicker
      autoclose: true,
      format: 'yyyy-mm-dd',
      todayHighlight: true,
      disableTouchKeyboard: true

  _ajaxChangeDistrict = ->
    $('#family_province_id').on 'change', ->
      province_id = $(@).val()
      $('select#family_district_id').val(null).trigger('change')
      $('select#family_district_id option[value!=""]').remove()
      if province_id != ''
        $.ajax
          method: 'GET'
          url: "/api/provinces/#{province_id}/districts"
          dataType: 'JSON'
          success: (response) ->
            districts = response.districts
            for district in districts
              $('select#family_district_id').append("<option value='#{district.id}'>#{district.name}</option>")

  { init: _init }
