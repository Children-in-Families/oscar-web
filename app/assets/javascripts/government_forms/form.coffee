CIF.Government_formsNew = CIF.Government_formsCreate = CIF.Government_formsEdit = CIF.Government_formsUpdate = do ->
  _init = ->
    _select2()
    _enableOtherOption()
    _enableOtherNeedOption()
    _enableOtherProblemdOption()

  _enableOtherNeedOption = ->
    $('.government_form_government_form_needs_rank').last().find('select').change ->
      if $(this).val() != ''
        $('#government_form_other_need').removeAttr('readonly')
      else
        $('#government_form_other_need').attr('readonly', 'readonly').val('')
    .change()

  _enableOtherProblemdOption = ->
    $('.government_form_government_form_problems_rank').last().find('select').change ->
      if $(this).val() != ''
        $('#government_form_other_problem').removeAttr('readonly')
      else
        $('#government_form_other_problem').attr('readonly', 'readonly').val('')
    .change()

  _changeMockOption = ->
    $('#mock_government_form_interviewee').change ->
      $('#government_form_other_interviewee').val($(this).val())

    $('#mock_government_form_client_type').change ->
      $('#government_form_other_client_type').val($(this).val())

  _removeReadOnlyInterviewAttr = ->
    $('#mock_government_form_interviewee').removeAttr('readonly')
  _removeReadOnlyClientTypeAttr = ->
    $('#mock_government_form_client_type').removeAttr('readonly')

  _enableOtherOption = ->
    otherIntervieweeOption = $('.government_form_interviewees').children('span').last()
    otherIntervieweeVal    = $('#government_form_other_interviewee').val()
    otherClientTypeOption  = $('.government_form_client_types').children('span').last()
    otherClientTypeVal     = $('#government_form_other_client_type').val()

    $(otherIntervieweeOption).append("<input readonly='readonly' placeholder='ផ្សេងៗ (សូមបញ្ជាក់)' style='margin-top:10px;' class='string optional form-control' type='text' value='#{otherIntervieweeVal}' id='mock_government_form_interviewee'>")
    $(otherClientTypeOption).append("<input readonly='readonly' placeholder='ផ្សេងៗ' style='margin-top:10px;' class='string optional form-control' type='text' value='#{otherClientTypeVal}' id='mock_government_form_client_type'>")

    if otherIntervieweeVal != ''
      _removeReadOnlyInterviewAttr()

    if otherClientTypeVal != ''
      _removeReadOnlyClientTypeAttr()

    _changeMockOption()

    otherIntervieweeOption.on 'ifChecked', ->
      _removeReadOnlyInterviewAttr()
      _changeMockOption()

    otherClientTypeOption.on 'ifChecked', ->
      _removeReadOnlyClientTypeAttr()
      _changeMockOption()

    otherIntervieweeOption.on 'ifUnchecked', ->
      $('#mock_government_form_interviewee').attr('readonly', 'readonly').val('')
      $('#government_form_other_interviewee').val('')

    otherClientTypeOption.on 'ifUnchecked', ->
      $('#mock_government_form_client_type').attr('readonly', 'readonly').val('')
      $('#government_form_other_client_type').val('')

  _select2 = ->
    $('select').select2
      minimumInputLength: 0
      allowClear: true

  { init: _init }
