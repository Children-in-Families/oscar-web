class ImageUploadPreviewer
  constructor: (uploader, placeholder) ->
    @uploader = uploader
    @placeholder = placeholder

  perform: ->
    self = @
    @_selectFileWhenPlaceholderClick()
    @_showPreview()

  _selectFileWhenPlaceholderClick: ->
    self = @
    $(@placeholder).click ->
      $(self.uploader).trigger('click')

  _showPreview: ->
    self = @
    $(@uploader).change (e) ->
      files = e.target.files
      if FileReader && files && files.length
        reader = new FileReader()
        reader.onload = ->
          self.placeholder.src = reader.result
        reader.readAsDataURL(files[0])
      else
        alert('Your browser doesn\'t support file upload')
