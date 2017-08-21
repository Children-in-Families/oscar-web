class CIF.PreventRequiredFileUploader
  preventFileUploader: ->
    form = $('form.simple_form')
    $(form).on 'submit', (e) ->
      requiredFields = $('input[type="file"]').parents('div.required')
      for requiredField in requiredFields
        continue if $(requiredField).parent().data('used')
        if $(requiredField).find('input').val() == ''
          $(requiredField).parent().addClass('has-error')
          $(requiredField).siblings('.help-block').removeClass('hidden')
          e.preventDefault()
        else
          $(requiredField).parent().removeClass('has-error')
          $(requiredField).siblings('.help-block').addClass('hidden')
