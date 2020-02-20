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
    @intAssessmentClientSelected()
    @preventEditOnDatePicker()

  preventEditOnDatePicker: ->
    $('.date-picker').datepicker
      autoclose: true,
      format: 'yyyy-mm-dd',
      todayHighlight: true,
      disableTouchKeyboard: true,
      startDate: '1899,01,01',
      orientation: 'bottom',
      todayBtn: true
    .attr('readonly', 'true').css('background-color','#ffffff').keypress (e) ->
      if e.keyCode == 8
        e.preventDefault()
      return

  addLocalstorageAttribute: ->
    $('.btn-login').on 'click', ->
      localStorage.setItem('from login', true)

  intAssessmentClientSelected: ->
    $('#client-select-assessment').on('select2-selected', (e) ->
      idClient = e.val
      if $('#csi-assessment-link').length
        csiLink = "/clients/#{idClient}/assessments/new?country=cambodia&default=true&from=dashboards"
        a = document.getElementById('csi-assessment-link').href = csiLink
      if $('.custom-assessment-link').length
        customAssessmentLinks = $('.custom-assessment-link')
        $.each customAssessmentLinks, (index, element) ->
          url = $(element).attr('href').replace(/\/\//, "/#{idClient}/")
          $(element).attr('href', url)

      $("#assessment-tab-dropdown").removeClass('disabled')
      $(this).val('')
    ).on 'select2-removed', () ->
      $("#assessment-tab-dropdown").addClass('disabled')

    $('#client-select-case-note').on 'select2-selected', (e) ->
      id = e.val
      csiLink = "/clients/#{id}/case_notes/new?country=cambodia&custom=false&from=dashboards"
      a = document.getElementById('csi-case-note-link').href = csiLink
      customLink = "/clients/#{id}/case_notes/new?country=cambodia&custom=true&from=dashboards"
      a = document.getElementById('custom-case-note-link').href = customLink
      $(this).val('')

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

