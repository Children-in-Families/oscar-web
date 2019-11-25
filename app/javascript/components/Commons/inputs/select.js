import React, { useState } from 'react'
import Select from 'react-select'

export default props => {
  const { value, options, isMulti, isError, label, required, onChange, asGroup,  ...others } = props


  const getSeletedObject = () => {
    if(options) {
      let object = []

      options.forEach(option => {
        if (Array.isArray(value)) {
          if (value.includes(option.value))
          object.push(option)
        } else if (option.value === value)
        object = option
      })

      return $.isEmptyObject(object) ? null : object
    }
  }

  const [selected, setselected] = useState(getSeletedObject(props.value) || null)

  const handleChange = (selectedOption, { action, removedValue }) => {
    console.log("TCL: handleChange -> selectedOption", selectedOption)
    console.log("TCL: handleChange -> removedValue", removedValue)
    console.log("TCL: handleChange -> action", action)
    let data

    // if (Array.isArray(selectedOption)) {
    //   switch(action) {
    //     case 'clear':
    //       selectedOption = options.filter(option => option.isFixed)
    //       break
    //     case 'remove-value':
    //       if(removedValue.isFixed)
    //         return
    //       break
    //   }
    //   data = selectedOption.map(option => option.value)
    // }

    if (isMulti) {
      switch(action) {
        case 'clear':
          selectedOption = options.filter(option => option.isFixed)
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

    // got error when selectedOption === null
    // } else if (selectedOption === null)
    //   data = []
    // else
    //   data = action === 'clear' ? null : selectedOption.value

    setselected(selectedOption)
    onChange(data)
  }

  const formatGroupLabel = data => (
    <div>
      <span><b>{data.label}</b></span>
    </div>
  )

  return (
    <div className='form-group'>
      <label style={ isError && customStyles.errorText || {} }>
        { required && <abbr title='required'>* </abbr> }
        { label }
      </label>

      <Select
        isMulti={isMulti}
        isClearable={options.some(v => !v.isFixed)}
        onChange={handleChange}
        formatGroupLabel={asGroup && formatGroupLabel}
        value={selected}
        options={options}
        { ...others }
        styles={ isError && customError }
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
      { isError && <span style={customStyles.errorText}>Cannot be blank.</span> }
    </div>
  )
}

const customStyles = {
  menu: (provided) => ({
    ...provided,
    zIndex: 1031,
  }),
  control: (provided, styles) => ({
    ...provided,
    boxShadow: 'none',
    borderColor: 'red',
    ':hover': {
      ...styles[':hover'],
      borderColor: '#1ab394',
    },
  }),
  errorText: {
    color: 'red'
  },
}

const customError = {
  control: (provided) => ({
    ...provided,
    borderColor: 'red',
  }),
}
