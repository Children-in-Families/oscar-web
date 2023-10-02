import React from 'react'
import Checkbox from 'react-simple-checkbox'

export default props => {
  const { onChange, disabled = false, objectKey, data, label, inlineClassName, ...others } = props

  return (
    <div className='form-group boolean optional i-checks'>
      <label>{label}</label>
      {
        data.map((obj, index) => (
          <li key={index} className='i-checks'>
            <Checkbox
              size='2'
              tickSize='3'
              color={ disabled ? '#a6a6a6' : "#1AB394" }
              tickAnimationDuration="100"
              borderThickness="2"
              checked={obj.selected || false}
              label={obj.label}
              value={obj.value}
              onChange={boolean => disabled ? '' : onChange({data: boolean, type: 'checkbox'})}
              {...others}
            />
            <label style={ styles.font }>{ obj.label }</label>
          </li>
        ))
      }
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
