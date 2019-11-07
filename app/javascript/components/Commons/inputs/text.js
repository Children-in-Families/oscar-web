import React from 'react'

export default props => {
  return (
    <div className='form-group'>
      <label>
        { props.required && <abbr title='required'>* </abbr> }
        {props.label}
      </label>
      <input className='form-control' onChange={props.onChange} />
    </div>
  )
}