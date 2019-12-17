import React from 'react'
import Select from 'react-select'

export default props => {
  const { value, options, isMulti, isError, label, required, onChange, asGroup,  ...others } = props

  const getSeletedObject = () => {
    if(options) {
      let object        = []
      const optionLists = asGroup && options.map(option => option.options).flat() || options

      optionLists.forEach(option => {
        if (Array.isArray(value)) {
          if (value.includes(option.value))
            object.push(option)
        } else if (option.value == value)
          object = option
      })

      return $.isEmptyObject(object) ? null : object
    }
  }

  const handleChange = (selectedOption, { action, removedValue }) => {
    let data
    let removed = removedValue && removedValue.value

    if (isMulti) {
      switch(action) {
        case 'clear':
          selectedOption = options.filter(option => option.isFixed)
          removed = getSeletedObject().map(data => data.value)
          break
        case 'remove-value':
          if(removedValue.isFixed)
            return
          break
      }
      data = selectedOption === null ? [] : selectedOption.map(option => option.value)
    } else {
      data = action === 'clear' ? null : selectedOption.value
    }

    onChange({ data, removed, action, type: 'select' })
  }

  const formatGroupLabel = data => (
    <div>
      <span><b>{data.label}</b></span>
    </div>
  )

  return (
    <div className='form-group'>
      <label style={ isError && customError.errorText || {} }>
        { required && <abbr title='required'>* </abbr> }
        { label }
      </label>

      <Select
        isMulti={isMulti}
        isClearable={options.some(v => !v.isFixed)}
        onChange={handleChange}
        formatGroupLabel={asGroup && formatGroupLabel}
        value={getSeletedObject() || null}
        options={options}
        { ...others }
        styles={
          Object.assign({},
            customStyles,
            isError && customError
          )
        }
        theme={theme => ({
          ...theme,
          colors: {
            ...theme.colors,
            primary50: '#1ab394',
            primary25: '#1ab394',
            primary: '#1ab394',
          },
        })}
      />
      { isError && <span style={customError.errorText}>Cannot be blank.</span> }
    </div>
  )
}

const customStyles = {
  menu: (provided) => ({
    ...provided,
    zIndex: 1031
  }),
  control: (provided, styles) => ({
    ...provided,
    boxShadow: 'none',
    ':hover': {
      ...styles[':hover'],
      borderColor: '#1ab394',
    },
  }),
}

const customError = {
  control: (provided) => ({
    ...provided,
    borderColor: 'red',
  }),
  errorText: {
    color: 'red'
  }
}
