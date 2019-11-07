import React from 'react'

export default props => {
  return (
    <>
      <input type='checkbox' className='radio_buttons' />
      <labe>{props.label}</labe>
    </>
  )
}