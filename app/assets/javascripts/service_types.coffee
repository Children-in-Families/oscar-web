class CIF.ServiceTypes
  constructor: (args)->
    @isFromDashboard = args['isFromDashboard']
    @element         = args['element']
    window.getServiceData = (td = undefined, select_id = null) ->
      if td == undefined
        return

      data = { id: td.children[0].value, text: td.children[0].text }
      # Append it to the select
      typeOfServiceSelect = if select_id == null then $('#type-of-service select') else $(".type-of-service select##{select_id && select_id.id}")
      # Set the value, creating a new option if necessary
      if typeOfServiceSelect.select2().val() == null
        typeOfServiceSelect.val(data.id)
      else
        typeOfServiceSelect.val(_.uniq(_.concat(typeOfServiceSelect.select2().val(), data.id)))

      typeOfServiceSelect.trigger('change')

  selectServiceTypeTableResult: ->
    isFromDashboard = @isFromDashboard
    element = @element
    if $('li').hasClass('first current') or $('#program-stream-service').length or $('.referral_services').length
      # $('#type-of-service select').select2()

      format = (state) ->
        if !state.id
          return state.text

      serviceFormatSelection = (service) ->
        service.text

      $("#{element} select").select2
        width: '100%'
        templateSelection: serviceFormatSelection
        escapeMarkup: (m) ->
          m

      createHeaderElement = (options, indexes)->
        html = ""
        indexes.forEach (entry) ->
          html += "<th><b>#{options[entry][0]}</b></th>"
        html

      createRowElement = (options, indexes, select_id=null) ->
        html = ""
        indexes.forEach (entries) ->
          td = ""
          entries.forEach (index) ->
            td += "<td width='' onclick='getServiceData(this, #{select_id})'><option value='#{options[index][1]}'>#{options[index][0]}</option></td>"

          html += "<tr>#{td}</tr>"
        html

      $("#{element} select").on 'select2:open', (e) ->
        arr = []
        i = 0
        while i < $(element).data('custom').length
          arr.push i
          i++

        options = $(element).data('custom')
        results = []
        chunk_size = 13
        while arr.length > 0
          results.push arr.splice(0, chunk_size)

        indexes = results.shift()
        th  = createHeaderElement(options, indexes)
        elementId = if isFromDashboard then @id else null
        row = createRowElement(options, results, elementId)

        html = '<table class="table table-bordered" style="margin-top: 5px;margin-bottom: 0px;"><thead>' + th + '</thead><tbody>' + row + '</tbody></table>'
        $('.select2-dropdown .select2-results').html $(html)
        # $('.select2-results').prepend "#{html}"
        return

      removeError = (element) ->
        element.removeClass('has-error')
        element.find('.help-block').remove()

      $("#{element} select").on 'select2:close', (e)->
        uniqueArray = _.compact(_.uniq($(this).val()))
        if uniqueArray.length > 3
          $(this.parentElement).append "<p class='help-block'>#{$('input#confirm-question').val()}</p>" if $(this.parentElement).find('.help-block').length == 0
          $(this.parentElement).addClass('has-error')

        if uniqueArray.length > 0
          removeError($(this.parentElement))
          arrId = this.id.split('_')
          $("#edit_program_stream_#{arrId[arrId.length - 1]} input[type='submit']").removeAttr('disabled')

        return

      $("#{element} select").on 'select2:unselect', ->
        uniqueArray = _.compact(_.uniq($(this).val()))
        if uniqueArray.length <= 3
          removeError($(this.parentElement))

        if uniqueArray.length == 0
          arrId = this.id.split('_')
          $("#edit_program_stream_#{arrId[arrId.length - 1]} input[type='submit']").attr('disabled', 'disabled')
