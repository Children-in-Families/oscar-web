CIF.Custom_fieldsShow = do ->
  _init = ->
    _initFormBuilderWithData();

  _initFormBuilderWithData = ->
    $('.build-wrap').formBuilder
      dataType: 'json'
      formData: JSON.stringify($('.build-wrap').data('fields'))

  { init: _init }
