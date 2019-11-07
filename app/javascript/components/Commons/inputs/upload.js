import React from 'react'

export default props => {
  const { label, required, ...rests } = props
  return (
    <>
      <label>
        { props.required && <abbr title='required'>* </abbr> }
        {label}
      </label>
      <div className='form-group file'>
        <input className='form-control optional' type='file' {...rests} />
      </div>
    </>
  )
}