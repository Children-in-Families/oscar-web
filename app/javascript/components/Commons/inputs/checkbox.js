import React, { useState } from 'react'
import Checkbox from 'react-simple-checkbox';

export default props => {
  const { onChange, setCheck } = props
  const [ checked, setChecked] = useState(false)

  const handleCheck = boolean => {
    setChecked(boolean)
    onChange(boolean)
    setCheck(boolean)
  }

  return (
    <>
      <Checkbox
        size='2'
        tickSize='3'
        color="#1AB394"
        tickAnimationDuration="100"
        borderThickness="2"
        checked={checked}
        onChange={handleCheck}
      />
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
