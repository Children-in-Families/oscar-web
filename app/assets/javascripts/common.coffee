CIF.Common =
  init: ->
    @hideNotification()
    @hideDynamicOperator()
    @menuDropDownClick()
    @validateFilterNumber()
    @customCheckBox()

  hideNotification: ->
    notice = $('p#notice')
    if notice
      setTimeout (->
        $(notice).fadeOut()
      ), 5000

  customCheckBox: ->
    $('.i-checks').iCheck
      checkboxClass: 'icheckbox_square-green'

  menuDropDownClick: ->
    $('#side-menu').metisMenu()

  hideDynamicOperator: ->
    $('.dynamic_filter').find('option[value="=~"]').remove('option')

  validateFilterNumber: ->
    $(window).load ->
      $('input[type="number"]').attr('min','0')
