import React, { useState, useEffect } from 'react'
import CheckboxGroup from 'react-checkbox-group'

export default props => {
  const { onChange, disabled = false, objectKey, data, label, name, inlineClassName, ...others } = props
  const [values, setValues] = useState(data)

  useEffect(() => {
    const timer = setTimeout(() => {
      useState(['apple', 'orange'])
    }, 5000)

    return () => clearTimeout(timer)
  }, [])

  return (
    <div className='form-group boolean optional i-checks'>
      <CheckboxGroup name={name} value={values} onChange={setValues}>
        {(Checkbox) => (
          data.map((obj, index) => (
            <label key={index}>
              <Checkbox value={obj.label} /> { obj.label }
            </label>
          ))
        )}
      </CheckboxGroup>
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
