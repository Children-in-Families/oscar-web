CIF.Client_booksIndex = do ->
  _init = ->
    _jumpToDate()

  _jumpToDate = ->
    $('.jump-to-date').datepicker
      showOn: 'focus'
      dateFormat: 'mm-dd-yy'
      changeMonth: true
      changeYear: true
      onSelect: ->
        event = undefined
        if typeof window.Event == 'function'
          event = new Event('change')
          @dispatchEvent event
        else
          event = document.createEvent('HTMLEvents')
          event.initEvent 'change', false, false
          @dispatchEvent event
        return

  {init: _init}
