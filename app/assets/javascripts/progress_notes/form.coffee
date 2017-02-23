CIF.Progress_notesNew = CIF.Progress_notesCreate = CIF.Progress_notesEdit = CIF.Progress_notesUpdate = do ->
  _init = ->
    self.removeFile = []
    _initDropzone()
    _select2()
    _toggleOtherLocation()
    _triggerLocationChanged()
    _handleSubmitForm()

  _handleSubmitForm = ->
    self = @
    $('#only-submit').on 'click', ->
      _handleRemoveImageFileById()
      $('input[type=submit]').click()

  _handleCollectingRemoveFileId = ->
    $('.dz-remove').on 'click', ->
      file_id = $(@).closest('.dz-preview').data('id')
      self.removeFile.push(file_id)


  _handleRemoveImageFileById = ->
    if self.removeFile != undefined
      id = $('#progress_note_id').val()
      $.ajax(
        type: 'GET'
        url: "/attachments/delete"
        data: { attachments: self.removeFile, progress_note_id: id }
        dataType: 'JSON'
      ).success((json) ->
        return false
      )

  _select2 = ->
    $('.progress_note_progress_note_type select, .progress_note_location select, .progress_note_material select, .progress_note_interventions select, .progress_note_assessment_domains select').select2
      minimumInputLength: 0
      allowClear: true

  _toggleOtherLocation = ->
    selectedOption = $('.progress_note_location select option:selected')
    if selectedOption.text().toLowerCase().indexOf('other') >= 0
      $('input#progress_note_other_location').removeAttr('disabled')
    else
      $('input#progress_note_other_location').attr('disabled', 'disabled')
        .val('')

  _triggerLocationChanged = ->
    $('.progress_note_location select').change ->
      _toggleOtherLocation()

  _initDropzone = ->
    successCallBackCount = 1
    Dropzone.autoDiscover = false
    form = $('.dropzone')
    form.dropzone(
      autoProcessQueue: false
      maxFilesize: 100
      paramName: "attachments[file][]",
      addRemoveLinks: true
      uploadMultiple: true
      parallelUploads: 25
      maxFiles: 25
      init: ->
        myDropzone = this
        progressNoteId = $('#progress_note_id').val()
        if typeof(progressNoteId) != 'undefined'
          data = { progress_note_id: progressNoteId }
          $.ajax(
            type: 'GET'
            url: '/attachments/'
            data: data
            dataType: 'JSON'
          ).success((json) ->
            attachments = json.attachments
            beforeUrls = []
            for attachment in attachments
              mockFile =
                name: attachment.name
                size: attachment.size
                url: attachment.file.file.url
                status: Dropzone.ADDED

              myDropzone.options.addedfile.call(myDropzone, mockFile)
              myDropzone.options.thumbnail.call(myDropzone, mockFile, attachment.file.file.dropzonethumb.url)
              myDropzone.files.push(mockFile)
              beforeUrls.push(attachment.name)
              $(".dz-preview:last-child").attr('data-id', attachment.id)

            form.append("<input type='hidden' name='beforeEdit' value='#{beforeUrls}' />");
            _handleCollectingRemoveFileId()
          )
        @element.querySelector('input[type=submit]').addEventListener 'click', (e) ->
          e.preventDefault()
          e.stopPropagation()
          form = $(this).closest('.dropzone')
          if form.valid() == true
            imgs = $(".dz-preview .dz-details .dz-filename span")
            filenames = []
            for img in imgs
              filenames.push($(img).text())
            form.append("<input type='hidden' name='afterEdit' value='#{filenames}'/>");
            progressNoteId = $('#progress_note_id').val()
            if typeof(progressNoteId) != 'undefined' && myDropzone.files.length >= 1
              myDropzone.uploadFiles(myDropzone.files)
            else if (myDropzone.getQueuedFiles().length > 0)
              myDropzone.processQueue()
            else
              form.submit()
        @on 'success', (file, response) ->
          successCallBackCount += 1
          text         = response.text
          slugId       = response.slug_id
          progressNote = response.progress_note
          if text != '' && successCallBackCount == this.files.length
            $('#wrapper').data(
              message: text
              messageType: "notice"
              )
            CIF.Common.initNotification()
          setTimeout(->
            window.location.href = "/clients/#{slugId}/progress_notes/#{progressNote.id}"
          ,1500)
      )


  { init: _init }
