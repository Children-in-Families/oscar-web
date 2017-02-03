CIF.Progress_notesNew = CIF.Progress_notesCreate = CIF.Progress_notesEdit = CIF.Progress_notesUpdate = do ->
  _init = ->
    _select2()
    _toggleOtherLocation()
    _triggerLocationChanged()
    _initDropzone()

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
    # $('#new_progress_note').dropzone =
    #   autoProcessQueue: false
    #   uploadMultiple: true
    #   parallelUploads: 100
    #   maxFiles: 100
    #   init: ->
    #     myDropzone = this
    #     @element.querySelector('button[type=submit]').addEventListener 'click', (e) ->
    #       e.preventDefault()
    #       e.stopPropagation()
    #       myDropzone.processQueue()
    #       return
    #     @on 'sendingmultiple', ->
    #       return
    #     @on 'successmultiple', (files, response) ->
    #       return
    #     @on 'errormultiple', (files, response) ->
    #       return
    #     return
    #
    Dropzone.autoDiscover = false
    $('#upload-attachment').dropzone =
      url: ''
      maxFilesize: 5
      paramName: 'attachments[photo]'
      addRemoveLinks: true
      dictDefaultMessage: 'Arrastre sus fotos aqui.'
      autoProcessQueue: false
      uploadMultiple: true
      parallelUploads: 5
      maxFiles: 5
      init: ->
        myDropzone = this
        @element.querySelector('button[type=submit]').addEventListener 'click', (e) ->
          e.preventDefault()
          e.stopPropagation()
          myDropzone.processQueue()
          return
        @on 'sendingmultiple', ->
          return
        @on 'successmultiple', (files, response) ->
          return
        @on 'errormultiple', (files, response) ->
          return
        return
  { init: _init }
