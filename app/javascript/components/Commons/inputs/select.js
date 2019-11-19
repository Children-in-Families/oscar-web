import React from 'react'
import Select from 'react-select'

export default props => {
  const { isError, label, required, onChange, asGroup,  ...others } = props

  const handleChange = selectedOption => {
    const value = Array.isArray(selectedOption) ? selectedOption.map(option => option.value) : selectedOption.value
    onChange(value)
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
        // id={props.id}
        // isMulti={props.isMulti}
        onChange={handleChange}
        // options={props.collections}
        formatGroupLabel={asGroup && formatGroupLabel}
        { ...others }
        styles={ customStyles }
      />
      { isError && <span style={customStyles.errorText}>Cannot be blank.</span> }
    </div>
  )
}

const customStyles = {
  menu: (provided, state) => ({
    ...provided,
    zIndex: 1031
  }),
  // control: (provided, styles, state) => ({
  //   ...provided,
  //   ':hover': {
  //     ...styles[':hover'],
  //     borderColor: '#1ab394'
  //   },
  //   ':focus': {
  //     ...styles[':hover'],
  //     borderColor: '#1ab394'
  //   }
  // }),
  errorText: {
    color: 'red'
  },
  // errorInput: {
  //   borderColor: 'red'
  // }
}
