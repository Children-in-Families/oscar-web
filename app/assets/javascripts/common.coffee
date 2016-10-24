CIF.Common =
  init: ->
    @hideNotification()
    @hideDynamicOperator()
    @menuDropDownClick()
    @validateFilterNumber()
    @miniNavbar()
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

  SmoothlyMenu: ->
    if !$('body').hasClass('mini-navbar') or $('body').hasClass('body-small')
      $('#side-menu').hide()
      setTimeout (->
        $('#side-menu').fadeIn 400
      ), 200
    else if $('body').hasClass('fixed-sidebar')
      $('#side-menu').hide()
      setTimeout (->
        $('#side-menu').fadeIn 400
      ), 100
    else
      $('#side-menu').removeAttr 'style'
    return

  miniNavbar: ->
    self = @
    $('.navbar-minimalize').on 'click', ->
      $('body').toggleClass 'mini-navbar'
      self.SmoothlyMenu()
