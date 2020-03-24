import React from 'react'

export default props => {
  return (
    <div className='form-group boolean optional'>
      <div className='checkbox'>
        <input value='0' type='hidden' />
        <label>
          <input className='boolean optional' type='checkbox' value='1' />
          {props.label}
        </label>
      </div>
    </div>
  )
}
