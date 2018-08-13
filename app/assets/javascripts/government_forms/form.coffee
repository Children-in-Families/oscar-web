CIF.Government_formsNew = CIF.Government_formsCreate = CIF.Government_formsEdit = CIF.Government_formsUpdate = do ->
  _init = ->
    _select2()
    _enableOtherOption()
    _enableOtherNeedOption()
    _enableOtherProblemdOption()
    _autoFillClientCode()
    _ajaxChangeDistrict()

  _ajaxChangeDistrict = ->
    mainAddress = $('#government_form_province_id, #government_form_district_id, #government_form_commune_id,
                  #government_form_interview_province_id, #government_form_interview_district_id, #government_form_interview_commune_id,
                  #government_form_primary_carer_province_id, #government_form_primary_carer_district_id, #government_form_primary_carer_commune_id,
                  #government_form_assessment_province_id, #government_form_assessment_district_id
                  ')
    mainAddress.on 'change', ->
      type       = $(@).data('type')
      typeId     = $(@).val()
      subAddress = $(@).data('subaddress')

      if type == 'provinces'
        subResources = 'districts'
        subAddress =  switch subAddress
                      when 'district' then $('#government_form_district_id')
                      when 'intervieweeDistrict' then $('#government_form_interview_district_id')
                      when 'primaryCarerDistrict' then $('#government_form_primary_carer_district_id')
                      when 'assessmentDistrict' then $('#government_form_assessment_district_id')

        $(subAddress).val(null).trigger('change')
        $(subAddress).find('option[value!=""]').remove()
      else if type == 'districts'
        subResources = 'communes'
        subAddress =  switch subAddress
                      when 'commune' then $('#government_form_commune_id')
                      when 'intervieweeCommune' then $('#government_form_interview_commune_id')
                      when 'primaryCarerCommune' then $('#government_form_primary_carer_commune_id')
                      when 'assessmentCommune' then $('#government_form_assessment_commune_id')

        $(subAddress).val(null).trigger('change')
        $(subAddress).find('option[value!=""]').remove()
      else if type == 'communes'
        subResources = 'villages'
        subAddress =  switch subAddress
                      when 'village' then $('#government_form_village_id')
                      when 'intervieweeVillage' then $('#government_form_interview_village_id')
                      when 'primaryCarerVillage' then $('#government_form_primary_carer_village_id')


        $(subAddress).val(null).trigger('change')
        $(subAddress).find('option[value!=""]').remove()

      if typeId != ''
        $.ajax
          method: 'GET'
          url: "/api/#{type}/#{typeId}/#{subResources}"
          dataType: 'JSON'
          success: (response) ->
            for address in response.data
              label = if subResources == 'villages' then address.code_format else address.name
              subAddress.append("<option value='#{address.id}' data-code=#{address.code}>#{label}</option>")

  _autoFillClientCode = ->
    $('#government_form_village_id').change ->
      if $(@).val() == ''
        $('#government_form_client_code_prefixed').text('')
      $('#government_form_client_code_prefixed').text($(@).find('option:selected').data('code'))
    .change()

  _removeReadOnlyAttr = (element) ->
    $(element).removeAttr('readonly')

  _addReadOnlyAttr = (element) ->
    $(element).attr('readonly', 'readonly').val('')

  _enableOtherNeedOption = ->
    $('.government_form_government_form_needs_rank').last().find('select').change ->
      if $(this).val() != ''
        _removeReadOnlyAttr('#government_form_other_need')
      else
        _addReadOnlyAttr('#government_form_other_need')
    .change()

  _enableOtherProblemdOption = ->
    $('.government_form_government_form_problems_rank').last().find('select').change ->
      if $(this).val() != ''
        _removeReadOnlyAttr('#government_form_other_problem')
      else
        _addReadOnlyAttr('#government_form_other_problem')
    .change()

  _changeMockOption = ->
    $('#mock_government_form_interviewee').change ->
      $('#government_form_other_interviewee').val($(this).val())

    $('#mock_government_form_client_type').change ->
      $('#government_form_other_client_type').val($(this).val())

    $('#mock_government_form_service_type').change ->
      $('#government_form_other_service_type').val($(this).val())

  _enableOtherOption = ->
    otherIntervieweeOption = $('.government_form_interviewees').children('span').last()
    otherIntervieweeVal    = $('#government_form_other_interviewee').val()
    otherClientTypeOption  = $('.government_form_client_types').children('span').last()
    otherClientTypeVal     = $('#government_form_other_client_type').val()
    otherServiceTypeOption = $('.government_form_service_types').children('span').last()
    otherServiceTypeVal    = $('#government_form_other_service_type').val()

    $(otherIntervieweeOption).append("<input readonly='readonly' placeholder='ផ្សេងៗ (សូមបញ្ជាក់)' style='margin-top:10px;' class='string optional form-control' type='text' value='#{otherIntervieweeVal}' id='mock_government_form_interviewee'>")
    $(otherClientTypeOption).append("<input readonly='readonly' placeholder='ផ្សេងៗ' style='margin-top:10px;' class='string optional form-control' type='text' value='#{otherClientTypeVal}' id='mock_government_form_client_type'>")
    $(otherServiceTypeOption).append("<input readonly='readonly' placeholder='ផ្សេងៗ' style='margin-top:10px;' class='string optional form-control' type='text' value='#{otherServiceTypeVal}' id='mock_government_form_service_type'>")

    if otherIntervieweeVal != ''
      _removeReadOnlyAttr('#mock_government_form_interviewee')

    if otherClientTypeVal != ''
      _removeReadOnlyAttr('#mock_government_form_client_type')

    if otherServiceTypeVal != ''
      _removeReadOnlyAttr('#mock_government_form_service_type')

    _changeMockOption()

    otherIntervieweeOption.on 'ifChecked', ->
      _removeReadOnlyAttr('#mock_government_form_interviewee')
      _changeMockOption()

    otherClientTypeOption.on 'ifChecked', ->
      _removeReadOnlyAttr('#mock_government_form_client_type')
      _changeMockOption()

    otherServiceTypeOption.on 'ifChecked', ->
      _removeReadOnlyAttr('#mock_government_form_service_type')
      _changeMockOption()

    otherIntervieweeOption.on 'ifUnchecked', ->
      _addReadOnlyAttr('#mock_government_form_interviewee')
      $('#government_form_other_interviewee').val('')

    otherClientTypeOption.on 'ifUnchecked', ->
      _addReadOnlyAttr('#mock_government_form_client_type')
      $('#government_form_other_client_type').val('')

    otherServiceTypeOption.on 'ifUnchecked', ->
      _addReadOnlyAttr('#mock_government_form_service_type')
      $('#government_form_other_service_type').val('')

  _select2 = ->
    $('select').select2
      minimumInputLength: 0
      allowClear: true

  { init: _init }
