CIF.Data_trackersIndex = do ->
  _init = ->
    _submitPerPageParams()
    
  _submitPerPageParams = ->
    $('#per_page_form form select').on 'change', ->
      $('#per_page_form form').submit();
    
  { init: _init }