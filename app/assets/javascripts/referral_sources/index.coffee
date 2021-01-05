CIF.Referral_sourcesIndex = do ->
  _init = ->
    _initSelect2()
    _newReferralSourceValidation()
    _editReferralSourceValidation()

  _initSelect2 = ->
    $('select').select2()

  _newReferralSourceValidation = ->
    data = {
      name: '#new_referral_source #referral_source_name',
      category: '#new_referral_source #s2id_referral_source_ancestry'
      form: '#new_referral_source'
      btn: '.form-btn'
    }
    _modalFormValidator(data)

  _editReferralSourceValidation = ->
    $('.btn-edit').on 'click', (e) ->
      modalId = e.currentTarget.dataset.target
      data = {
        name: "#{modalId} #referral_source_name",
        category: "#{modalId} #s2id_referral_source_ancestry"
        form: modalId
        btn: '.form-btn'
      }
      _modalFormValidator(data)

  _modalFormValidator = (data)->
    name = data['name']
    category = data['category']
    form = data['form']
    btn = data['btn']

    _modalButtonAction(form, btn, name, category)
    $(name).add(category).bind 'keyup change', ->
      _modalButtonAction(form, btn, name, category)
    $('select').on 'select2:select', ->
      _modalButtonAction(form, btn, name, category)

  _modalButtonAction = (form, btn, name, category) ->
    name = $(name).val()
    category = $(category).find('.select2-chosen').text()
    if (name == '' or name == null) or (category == '' or category == null)
      $(form).find(btn).attr 'disabled', 'disabled'
    else
      $(form).find(btn).removeAttr 'disabled'



  { init: _init }
