CIF.Common =
  init: ->
    @hideDynamicOperator()
    @validateFilterNumber()
    @customCheckBox()
    @initNotification()
    @autoCollapseManagMenu()
    @textShortener()
    @addLocalstorageAttribute()
    @checkValidationErrorExistOnSaving()
    @preventEditOnDatePicker()
    @confirmOnCancelBotton()
    @iCheckClearOptionSelect()
    @printDiv()

    @loadNotification()
    @loadSideMenuCountBadge()
    @handleNotificationOnClick()

  loadNotification: ->
    setTimeout (->
      if $('.lazy-load-notification').length > 0
        $.ajax(type: 'GET', url: '/dashboards/notification').done(->
          CIF.Common.handleNotificationOnClick()
          return
        ).fail (p1, p2, p3) ->
          console.log(p1, p2, p3)

    ), 1000

  loadSideMenuCountBadge: ->
    setTimeout (->
      if $('ul#side-menu').length > 0
        $.ajax(type: 'GET', url: '/dashboards/side_menu_data')
    ), 1000

  preventEditOnDatePicker: ->
    $('.date-picker').datepicker
      autoclose: true,
      format: 'yyyy-mm-dd'
      todayHighlight: true,
      disableTouchKeyboard: true,
      startDate: '1899,01,01',
      orientation: 'bottom',
      todayBtn: true
    .attr('readonly', 'true').attr("autocomplete", "off").css('background-color','#ffffff').keypress (e) ->
      if e.keyCode == 8
        e.preventDefault()
      return

  addLocalstorageAttribute: ->
    $('.btn-login').on 'click', ->
      localStorage.setItem('from login', true)

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

  autoCollapseManagMenu: ->
    active = $('.nav-second-level').find('.active')
    navThirdActive = $('.nav-third-level').find('.active')
    if active.length > 0
      $('#manage').trigger('click')
      if navThirdActive.length > 0
        setTimeout (->
          if $(navThirdActive).closest(".nav-third-level").prev("a")
            $(navThirdActive).closest(".nav-third-level").prev("a").trigger('click')
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

  checkValidationErrorExistOnSaving: ->
    imagePath = undefined
    setTimeout (->
      imagePath = $('.file-caption-main input').attr('value')
      return if imagePath == undefined
      if imagePath.length > 0
        $('.form-group.file .file-input.theme-explorer').removeClass('file-input-new')
        imagePreview = "<tr class='file-preview-frame explorer-frame  kv-preview-thumb' data-fileindex='0' data-template='image'><td class='kv-file-content'>
            <img src='#{imagePath}' class='file-preview-image kv-preview-data rotate-1' title='romchong_ads.jpg' alt='romchong_ads.jpg' style='width:auto;height:60px;'>
            </td>
            <td class='file-details-cell'><div class='explorer-caption' title='romchong_ads.jpg'>romchong_ads.jpg</div>  <samp>(64.8 KB)</samp></td><td class='file-actions-cell'><div class='file-upload-indicator' title='Not uploaded yet'><i class='glyphicon glyphicon-hand-down text-warning'></i></div>
              <div class='file-actions'>
              <div class='file-footer-buttons'>
              <button type='button' class='kv-file-zoom btn btn-xs btn-default' title='View Details'><i class='glyphicon glyphicon-zoom-in'></i></button>      </div>
              </div>
            </td>
          </tr>"

        $('.form-group.file .file-preview table > tbody.file-preview-thumbnails').append(imagePreview)
    ), 1000

    $('input[type="submit"]').on 'click', ->
      imagePath = $('.file-caption-main input').attr('value')
      return if imagePath == undefined
      if $('.form-group.file .file-preview table > tbody.file-preview-thumbnails').children().length == 0 && imagePath.length == 0
        $(@).removeAttr('data-disable-with')
      else
        $(@).attr('data-disable-with', "#{$(this).val()}...")

      return

  confirmOnCancelBotton: ->
    $(document).on 'click', 'a.btn.btn-default.form-btn:not(".btn-back"), form button.btn.btn-default:not(".editable-cancel"), a#btn-cancel', (e)->
      window.thisLink = $(@).attr('href')
      confirmText = $('#wrapper').data('confirm')
      textYes     = $('#wrapper').data('yes')
      textNo     = $('#wrapper').data('no')

      e.preventDefault();

      toastr.warning "<br /><button class='btn btn-success m-r-xs' type='button' value='yes'>#{textYes}</button><button class='btn btn-default btn-toastr-confirm' type='button'  value='no' >#{textNo}</button>", confirmText,
        preventDuplicates: true
        closeButton: true
        allowHtml: true
        timeOut: 0,
        extendedTimeOut: 0,
        showDuration: '400'
        tapToDismiss: false
        positionClass: 'toast-top-center'
        onclick: () ->
          value = event.target.value
          if value == 'yes'
            $('.modal').modal('hide')
            history.back()
            return true
          else
            $('.toast-close-button').closest('.toast').remove();
            return false

  iCheckClearOptionSelect: ->
    $(document).on('ifUnchecked', ".iradio_square-green input:not([name^='setting'])", (e) ->
      self = @
      setTimeout(->
        if self.type == 'radio' && confirm('Clear selection/លុបចោលការជ្រើសរើស?')
          $(self).closest('.radio_buttons.form-group').find('input').removeAttr('checked').iCheck('update');
        else
          return
      , 0)
    )

  printDiv: ->
    $('.printable-button').on 'click', ->
      printableId = $(@).data('printable-id')
      $("##{printableId}").print()
    return

  handleNotificationOnClick: ->
    $('a[data-remote="true"]').on 'click', () ->
      CIF.Common.loadingToastrOnNotificationClick()
    return

  loadingToastrOnNotificationClick: ->
    messageOption =
      'closeButton': true
      'debug': true
      'progressBar': true
      'positionClass': 'toast-top-center'
      'showEasing': 'swing'
      'hideEasing': 'linear'
      'showMethod': 'slideDown'
      'hideMethod': 'slideUp',
      'iconClass': "toast-custom-icon"

    toastr.options.escapeHtml = true;
    toastr.success('<i class="fa fa-spinner fa-spin" style="font-size:24px"></i> Loading...', '', messageOption)
