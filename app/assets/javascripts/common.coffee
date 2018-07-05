CIF.Common =
  init: ->
    @hideDynamicOperator()
    @validateFilterNumber()
    @customCheckBox()
    @initNotification()
    @autoCollapseManagMenu()
    @textShortener()
    @_ajaxChangeDistrict()
    @_initSelect2()

  _initSelect2: ->
    $('.select2').select2()

  _ajaxChangeDistrict: ->
    $('#setting_province_id').on 'change', ->
      province_id = $(@).val()
      $('select#setting_district_id').val(null).trigger('change')
      $('select#setting_district_id option[value!=""]').remove()
      if province_id != ''
        $.ajax
          method: 'GET'
          url: "/api/provinces/#{province_id}/districts"
          dataType: 'JSON'
          success: (response) ->
            districts = response.districts
            for district in districts
              $('select#setting_district_id').append("<option value='#{district.id}'>#{district.name}</option>")

  textShortener: ->
    if $('.clients-table').is(':visible')
      moreText = $('.clients-table').attr('data-read-more')
      lessText = $('.clients-table').attr('data-read-less')
      new CIF.ShowMore('.td-content', 57, moreText, lessText)


  customCheckBox: ->
    $('.i-check-red').iCheck
      radioClass: 'iradio_square-red'

    $('.i-check-brown').iCheck
      radioClass: 'iradio_square-brown'

    $('.i-check-orange').iCheck
      radioClass: 'iradio_square-orange'

    $('.i-checks').iCheck
      checkboxClass: 'icheckbox_square-green'
      radioClass: 'iradio_square-green'

  autoCollapseManagMenu: ->
    active = $('.nav-second-level').find('.active')
    navThirdActive = $('.nav-third-level').find('.active')
    if active.length > 0
      $('#manage').trigger('click')
      if navThirdActive.length > 0
        setTimeout (->
          $('#pro-nav').trigger('click')
        ), 400

  hideDynamicOperator: ->
    $('.dynamic_filter').find('option[value="=~"]').remove('option')

  validateFilterNumber: ->
    $(window).load ->
      $('input[type="number"]').attr('min','0')

  initNotification: ->
    messageOption = {
      "closeButton": true,
      "debug": true,
      "progressBar": true,
      "positionClass": "toast-top-center",
      "showDuration": "400",
      "hideDuration": "1000",
      "timeOut": "7000",
      "extendedTimeOut": "1000",
      "showEasing": "swing",
      "hideEasing": "linear",
      "showMethod": "fadeIn",
      "hideMethod": "fadeOut"
    }
    messageInfo = $("#wrapper").data()
    if Object.keys(messageInfo).length > 0
      if messageInfo.messageType == 'notice'
        toastr.success(messageInfo.message, '', messageOption)
      else if messageInfo.messageType == 'alert'
        toastr.error(messageInfo.message, '', messageOption)
