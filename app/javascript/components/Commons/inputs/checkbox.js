import React from 'react'
import Checkbox from 'react-simple-checkbox'

export default props => {
  const { onChange, disabled = false, ...others } = props

  return (
    <>
      <Checkbox
        size='2'
        tickSize='3'
        color={ disabled ? '#a6a6a6' : "#1AB394" }
        tickAnimationDuration="100"
        borderThickness="2"
        onChange={boolean => disabled ? '' : onChange({data: boolean, type: 'checkbox'})}
        {...others}
      />
      <label style={disabled ? styles.disabled : styles.font}> {props.label} </label>
    </>
  )
}

const styles = {
  font:{
    fontWeight: 'normal',
    fontSize: '14px'
  },

  disabled: {
    color: '#a6a6a6',
    fontWeight: 'normal',
    fontSize: '14px'
  }
}
