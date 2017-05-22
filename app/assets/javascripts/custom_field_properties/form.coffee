CIF.Custom_field_propertiesNew = CIF.Custom_field_propertiesCreate = CIF.Custom_field_propertiesEdit = CIF.Custom_field_propertiesUpdate = do ->
  _init = ->
    _initUploader()
    _handleCocoonAdd()

  _initUploader = ->
    $('.nested-fields').each (index, element)->
      image = $(element).find('.thumbnail')
      uploader = $(element).find('input[type="file"]')
      $(image).on 'click', ->
        $(image).previewImage
          uploader: uploader
        $(uploader).click()

    # $(".attachment-upload").fileinput
    #   showUpload: false
    #   theme: "explorer"

    # $('#custom_field_property_attachments').fileinput
    #   showUpload: false
    #   theme: "fa"
    #   console.log 's'
      

  #   image = $('.nested-fields img')
  #   uploader = $('.attachment-upload')
  #   $(image).previewImage
  #     uploader: uploader
  #   $(uploader).click()

  _handleCocoonAdd = ->
    $('#attachments').on 'cocoon:after-insert', (e, element)->
      image = $(element).find('img.thumbnail')
      uploader = $(element).find('input[type="file"]')
      $(uploader).click()
      $(image).previewImage
        uploader: uploader

      # input = element.find('input[type="file"]')
      # $(input).fileinput
      #   showUpload: false
      #   theme: "explorer"
  #     # debugger
  #     image = $(element).children().find('img')
  #     console.log image
  #     $(image).click ->

  #       uploader = $(element).find('input[type="hiddend"]')
  #       $(image).previewImage
  #         uploader: uploader
  #       $(uploader).click()

  { init: _init }