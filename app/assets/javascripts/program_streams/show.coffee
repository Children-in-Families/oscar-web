CIF.Program_streamsShow = CIF.Program_streamsPreview = CIF.NotificationsProgram_stream_notify = do ->
  _init = ->
    _initFileInput()
    _initProgramRule()
    _handleDisabledInputs()
    _initSelect2()
    _initICheckBox()

  _initICheckBox = ->
    $('.i-checks').iCheck
      checkboxClass: 'icheckbox_square-green'
      radioClass: 'iradio_square-green'

  _initProgramRule = ->
    rules = $('#rules').data('program-rules')
    return if _.isEmpty(rules.rules)
    $.ajax
      url: '/api/program_stream_add_rule/get_fields'
      method: 'GET'
      success: (response) ->
        fieldList = response.program_stream_add_rule
        builder = new CIF.AdvancedFilterBuilder($('#program-rules'), fieldList, {})
        builder.initRule()
        setTimeout ( ->
          _initSelect2()
          _handleRemoveButtonOnProgramRules()
          _handleDisabledInputs()
          _handleRemoveConditionButton()
          )

        _handleSetRules()

  _handleRemoveConditionButton = ->
    rules = $('#rules').data('program-rules')
    return if $.isEmptyObject(rules)
    $('.btn-group.group-conditions label.active').siblings().remove()

  _builderTranslation = ->
    addFilter: $('#program-rule').data('filter-translation-add-filter')
    addGroup: $('#program-rule').data('filter-translation-add-group')
    deleteGroup: $('#program-rule').data('filter-translation-delete-group')

  _initFileInput = ->
    $('.file').fileinput
      showUpload: false
      removeClass: 'btn btn-danger btn-outline'
      browseLabel: 'Browse'
      theme: "explorer"

  _initSelect2 = ->
    $('.rule-filter-container select').select2(width: '220px')
    $('.rule-operator-container select, .rule-value-container select').select2(width: '180px')

  _handleSetRules = ->
    rules = $('#rules').data('program-rules')
    $('#program-rules').queryBuilder('setRules', rules) unless _.isEmpty(rules.rules)

  _handleRemoveButtonOnProgramRules = ->
    $('.program-show').find('#program-rules button').remove()

  _handleDisabledInputs = ->
    $('#program-stream-info :input').attr( 'disabled', 'disabled' )
    $('#program-stream-info .rules-group-header .group-conditions label').attr('disabled', 'disabled')

  { init: _init }
