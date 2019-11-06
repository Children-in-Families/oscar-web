import React from 'react'

export default props => {
  return (
    <div className='form-group'>
      <label>
        { props.required && <abbr title='required'>* </abbr> }
        {props.label}
      </label>
      <div className='input-group date'>
        <input className='date optional form-control date-picker' />
        <span className='input-group-addon'>
          <i className='fa fa-calendar-check-o' />
        </span>
      </div>
    </div>
  )
}