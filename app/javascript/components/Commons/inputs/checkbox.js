import React from 'react'

export default props => {
  return (
    <>
      <input type='checkbox' className='radio_buttons' />
      <label style={styles.font}>{props.label}</label>
    </>
  )
}

const styles = {
  font:{
    fontWeight: 'normal',
    fontSize: '14px'
  }
}
