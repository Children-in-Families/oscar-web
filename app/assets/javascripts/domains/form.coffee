CIF.DomainsNew = CIF.DomainsCreate = CIF.DomainsEdit = CIF.DomainsUpdate = do ->
  _init = ->
    _initSelect2()
    _tinyMCE()

  _tinyMCE = ->
    tinymce.init
      selector: 'textarea.tinymce'
      plugins: 'lists'
      toolbar: 'bold italic numlist bullist'
      menubar: false

  _initSelect2 = ->
    $('.select2').select2();
  { init: _init }
