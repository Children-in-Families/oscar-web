import React from 'react'
import Checkbox from 'react-simple-checkbox'

export default props => {
  const { onChange, disabled = false, objectKey, inlineClassName, ...others } = props

  const handleLabelStyle = () => {
    return objectKey == 'referee' ? styles.fontBold : styles.font
  }

  return (
    <div className='form-group boolean optional'>
      <Checkbox
        size='2'
        tickSize='3'
        color={ disabled ? '#a6a6a6' : "#1AB394" }
        tickAnimationDuration="100"
        borderThickness="2"
        onChange={boolean => disabled ? '' : onChange({data: boolean, type: 'checkbox'})}
        {...others}
      />
      <label style={disabled ? styles.disabled : handleLabelStyle() }> {props.label} </label>
      { inlineClassName && <i className={`fa fa-info-circle text-info m-xs ${inlineClassName}`}></i> }
    </div>
  )
}

const styles = {
  font:{
    fontWeight: 'normal',
    fontSize: '14px'
  },

  fontBold:{
    fontWeight: 'bold',
    fontSize: '14px'
  },

  disabled: {
    color: '#a6a6a6',
    fontWeight: 'normal',
    fontSize: '14px'
  }
}
