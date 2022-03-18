CIF.Screening_assessmentsNew = CIF.Screening_assessmentsCreate = CIF.Screening_assessmentsUpdate = CIF.Screening_assessmentsEdit = do ->
  _init = ->
    _handleMileStoneAgeSelect()
    _initDatePicker()
    _cocoonCallback()
    _handleCheckBox()

  _handleMileStoneAgeSelect = ->
    mileStoneAge = $('#screening_assessment_client_milestone_age').val()
    _removeClassFieldSet(mileStoneAge)

    $('#screening_assessment_client_milestone_age').on 'change', ->
      $('fieldset').addClass('hidden')
      $('fieldset input[type="hidden"]').val('true')

      value = @.value
      _removeClassFieldSet(value)

  _removeClassFieldSet = (value)->
    _handleCheckBox()
    $("fieldset[data-developmental-marker-screening-assessment-name='#{value}']").removeClass('hidden')
    $("fieldset[data-developmental-marker-screening-assessment-name='#{value}'] input").removeAttr('disabled')
    $("fieldset[data-developmental-marker-screening-assessment-name='#{value}'] input[type='hidden']").val('false')

  _initDatePicker = ->
    $('.date-picker').datepicker
      autoclose: true,
      format: 'yyyy-mm-dd',
      todayHighlight: true,
      disableTouchKeyboard: true,
      startDate: '1899,01,01',
      todayBtn: true,
    .attr('readonly', 'true').css('background-color','#ffffff').keypress (e) ->
      if e.keyCode == 8
        e.preventDefault()
      return

   _cocoonCallback = ->
    $('#tasks').on 'cocoon:after-insert', ->
      _initDatePicker()

  _handleCheckBox = ->
    $('#tasks').removeClass('hide') unless _.every(_isInputRadioAllUnChecked())

    $(document).on 'change', 'fieldset input:radio:visible', (event) ->
      if eval(event.target.value)
        $('#tasks').removeClass('hide')
      else
        $('#tasks').addClass('hide') if _.every(_isInputRadioAllUnChecked())

  _isInputRadioAllUnChecked = ->
    nameAttributes = $('fieldset input:radio:visible').map( ->
      $(this).prop('name')
    ).get()

    nameValue = _.uniq(nameAttributes).map (element) ->
                  "input:radio[name='" + element + "']"

    nameValue.map (value) ->
      !$(value).prop('checked')

  { init: _init }
