CIF.Client_booksIndex = do ->
  _init = ->
    _jumpToDate()
    _initSelect2()

    $(window).scroll ->
      if $(this).scrollTop() > 50
        $('#back-to-top').fadeIn()
      else
        $('#back-to-top').fadeOut()
      return
    # scroll body to 0px on click
    $('#back-to-top').click ->
      $('body,html').animate { scrollTop: 0 }, 300
      false

  _jumpToDate = ->
    $('#jum-to-date-picker .date-picker').datepicker
      autoclose: true,
      format: 'dd-mm-yyyy',
      todayHighlight: true,
      disableTouchKeyboard: true,
    .on 'hide', (event) ->
      selectedDate = Object.assign({}, event);
      elements = $('[data-anchor-date]').toArray()
      if _compareEqualDate(selectedDate, elements)
        return
      else if _compareEqualMonthYear(selectedDate, elements)
        return
      else
        _compareEqualYear(selectedDate, elements)
        return

      return

  _initSelect2 = ->
    $('select').select2()

  _compareEqualDate = (selectedDate, elements) ->
    i = 0
    while i < elements.length
      stringDate = $(elements[i]).data('anchor-date')
      date = new Date(stringDate)
      if date.toDateString() == selectedDate.date.toDateString()
        _scrollToAnchor(elements[i])
        return true
      i++
    return false

  _compareEqualMonthYear = (selectedDate, elements) ->
    i = 0
    while i < elements.length
      stringDate = $(elements[i]).data('anchor-date')
      date = new Date(stringDate)
      if date.getYear() && date.getMonth() == selectedDate.date.getMonth() && date.getYear() == selectedDate.date.getYear()
        _scrollToAnchor(elements[i])
        return true
      i++
    return false

  _compareEqualYear = (selectedDate, elements) ->
    i = 0
    while i < elements.length
      stringDate = $(elements[i]).data('anchor-date')
      date = new Date(stringDate)
      if date.getYear() == selectedDate.date.getYear()
        _scrollToAnchor(elements[i])
        return true
      i++
    return false

  _scrollToAnchor = (element) ->
    top = $(element).offset().top
    window.scrollTo(0, top);

  {init: _init}
