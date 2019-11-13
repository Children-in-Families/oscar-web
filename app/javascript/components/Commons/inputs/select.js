import React from 'react'
import Select from 'react-select'

export default props => {
  const handleChange = selectedOption => {
    console.log('selectedOption', selectedOption)
  }

  const formatGroupLabel = data => (
    <div>
      <span><b>{data.label}</b></span>
    </div>
  )

  return (
    <div className='form-group'>
      <label>
        { props.required && <abbr title='required'>* </abbr> }
        {props.label}
      </label>

      <Select
        isMulti={props.isMulti}
        onChange={handleChange}
        options={props.collections}
        formatGroupLabel={props.asGroup && formatGroupLabel}
        styles={customStyles}
      />
    </div>
  )
}

const customStyles = {
  menu: (provided, state) => ({
    ...provided,
    zIndex: 90
  })
}
