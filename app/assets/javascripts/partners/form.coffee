CIF.PartnersNew = CIF.PartnersCreate = CIF.PartnersEdit = CIF.PartnersUpdate = do ->
  _init = ->
    _initSelect2()
    _hideMetaField()

  _initSelect2 = ->
    $('select').select2
      allowClear: true

  _hideMetaField = ->
    meta_fields = $('#partner-meta-field').data "meta-fields"
    meta_fields.forEach (meta_field) ->
      if meta_field.hidden == true && meta_field.required == false
        if $(".partner_#{meta_field.field_name}").hasClass "date"
          $(".partner_#{meta_field.field_name}").css 'display','none'
        else
          $(".partner_#{meta_field.field_name}").parent().css 'display','none'
          meta_field_filtered_id = meta_field.field_name.replace('_id','')
          $(".partner_#{meta_field_filtered_id}").parent().css 'display','none'

  { init: _init }
