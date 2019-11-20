import React from 'react'
import Select from 'react-select'

export default props => {
  const { label, required, onChange, asGroup,  ...others } = props

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
      <label>
        { required && <abbr title='required'>* </abbr> }
        { label }
      </label>

      <Select
        isClearable
        onChange={(option, {action}) => handleChange(option, action)}
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
