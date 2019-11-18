import React from 'react'
import Select from 'react-select'

export default props => {
  const { label, required, onChange, asGroup,  ...others } = props

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
      <label>
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
