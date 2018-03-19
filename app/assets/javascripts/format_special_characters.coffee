class CIF.FormatSpecialCharacters
  formatSpecialCharacters: (fields, specialCharacters) ->
    for field in fields
      if field.type == 'radio-group' || field.type == 'checkbox-group' || field.type == 'select'
        for value in field.values
          value.label = value.label.allReplace(specialCharacters)
          value.value = value.value.allReplace(specialCharacters)
      if field.placeholder != undefined
        field.placeholder = field.placeholder.allReplace(specialCharacters)
    fields
