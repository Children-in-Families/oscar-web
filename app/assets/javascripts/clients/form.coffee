CIF.ClientsNew = CIF.ClientsCreate = CIF.ClientsUpdate = CIF.ClientsEdit = do ->
  _init = ->
    _ajaxCheckExistClient()
    _clientSelectOption()
    _ajaxChangeDistrict()

  _ajaxChangeDistrict = ->
    $('#client_province_id').on 'change', ->
      province_id = $(@).val()
      $.ajax({
        type: 'GET'
        url: "/api/provinces/#{province_id}/districts"
        dataType: "JSON"
      }).success((json)->
        $('select#client_district_id').val(null).trigger('change')
        $('select#client_district_id option[value!=""]').remove()
        districts = json.districts
        for district in districts
          $('select#client_district_id').append("<option value='#{district.id}'>#{district.name}</option>")
      )

  _ajaxCheckExistClient = ->
    $('#submit-button').on 'click', ->
      data = {
        given_name: $('#client_given_name').val()
        family_name: $('#client_family_name').val()
        local_given_name: $('#client_local_given_name').val()
        local_family_name: $('#client_local_family_name').val()
        birth_province_id: $('#client_birth_province_id').val()
        current_province_id: $('#client_province_id').val()
        date_of_birth: $('#client_date_of_birth').val()
        village: $('#client_village').val()
        commune: $('#client_commune').val()
      }
      if data.date_of_birth != '' or data.given_name != '' or data.birth_province_id != '' or data.family_name != '' or data.local_given_name != '' or data.local_family_name != '' or data.village != '' or data.commune != '' or data.current_province_id != ''
        $.ajax({
          type: 'GET'
          url: '/api/clients/compare'
          data: data
          dataType: "JSON"
        }).success((json)->
          clientId = $('#client_id').val()
          clientIds = []
          clients = json.clients
          for client in clients
            clientIds.push(String(client.id))

          if clients.length > 0 and clientId not in clientIds
            modalTitle      = $('#hidden_title').val()
            modalTextFirst  = $('#hidden_body_first').val()
            modalTextSecond = $('#hidden_body_second').val()
            modalTextThird = $('#hidden_body_third').val()
            clientName      = $('#client_given_name').val()
            organizations   = []
            organizations.push(client.organization for client in clients)
            $.unique(organizations[0])
            modalText = []
            for organization in organizations[0]
              modalText.push("<p>#{modalTextFirst} #{organization}#{modalTextSecond} #{organization} #{modalTextThird}<p/>")

            $('#confirm-client-modal .modal-header .modal-title').text(modalTitle)
            $('#confirm-client-modal .modal-body').html(modalText)

            $('#confirm-client-modal').modal('show')
            $('#confirm-client-modal #confirm').on 'click', ->
              $('form.client-form').submit()
          else
            $('form.client-form').submit()
        )
      else
        $('form.client-form').submit()

  _clientSelectOption = ->
    $('select').select2
      minimumInputLength: 0
      allowClear: true
      _clearSelectedOption()

    $('select.able-related-info').change ->
      qtSelectedSize = $('select.able-related-info option:selected').length

      if qtSelectedSize > 0
        $('#client_able').val(true)
        $('#fake_client_able').prop('checked', true)
      else
        $('#client_able').val(false)
        $('#fake_client_able').prop('checked', false)

  _clearSelectedOption = ->
    formAction = $('body').attr('id')
    $('#client_gender').val('') unless formAction.includes('edit')

  { init: _init }
