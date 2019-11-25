import React from 'react'
import Select from 'react-select'

export default props => {
  const { Multiple, isError, label, required, onChange, asGroup,  ...others } = props

  const handleChange = (selectedOption, action) => {
    let data = Array.isArray(selectedOption) ? selectedOption.map(option => option.value) : selectedOption
    data = action === 'clear' ? null : data.value
    onChange(data)
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
        isClearable
        onChange={(option, {action}) => handleChange(option, action)}
        formatGroupLabel={asGroup && formatGroupLabel}
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
