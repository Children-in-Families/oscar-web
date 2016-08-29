CIF.Common =
  init: ->
    @hideNotification()
    @hideDynamicOperator()
    @validateFilterNumber()

  hideNotification: ->
    notice = $('p#notice')
    if notice
      setTimeout (->
        $(notice).fadeOut()
      ), 5000

  hideDynamicOperator: ->
    $('.dynamic_filter').find('option[value="=~"]').remove('option')

  validateFilterNumber: ->
    $(window).load ->
      $('input[type="number"]').attr('min','0')
      ($('input[type="number"]') && $('.dynamic_filter.value')).keydown (e) ->
        if $.inArray(e.keyCode, [
            46
            8
            9
            27
            13
            110
            190
          ]) != -1 or e.keyCode == 65 and e.ctrlKey == true or e.keyCode == 67 and e.ctrlKey == true or e.keyCode == 88 and e.ctrlKey == true or e.keyCode >= 35 and e.keyCode <= 41
          return
        if (e.shiftKey or e.keyCode < 48 or e.keyCode > 57) and (e.keyCode < 96 or e.keyCode > 105)
          e.preventDefault()
        return


