import React from 'react'
import Checkbox from 'react-simple-checkbox'

export default props => {
  const { onChange, ...others } = props

  return (
    <>
      <Checkbox
        size='2'
        tickSize='3'
        color="#1AB394"
        tickAnimationDuration="100"
        borderThickness="2"
        onChange={boolean => onChange({data: boolean, type: 'checkbox'})}
        {...others}
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
