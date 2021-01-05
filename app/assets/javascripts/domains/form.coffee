CIF.DomainsNew = CIF.DomainsCreate = CIF.DomainsEdit = CIF.DomainsUpdate = do ->
  _init = ->
    _initSelect2()
    _tinyMCE()
    _domainTypeSelect2()

  _tinyMCE = ->
    tinymce.init
      selector: 'textarea.tinymce'
      plugins: 'lists'
      height : '480'
      toolbar: 'bold italic numlist bullist'
      menubar: false

  _initSelect2 = ->
    $('select').select2();

  _domainTypeSelect2 = ->
    $("select#domain_domain_type").select2("enable", true).on 'select2-selecting', (event) ->
      if event.choice.id == 'client'
        $("#domain_custom_assessment_setting").attr('class', '').show()
      else
        $("#domain_custom_assessment_setting").hide()

      return

  { init: _init }
