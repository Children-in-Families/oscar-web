import React, { useState } from 'react'
import { RadioButton } from 'primereact/radiobutton'
import './radioButton.scss'

export default props => {
  const { onChange, options, inline, value, isError, required, disabled } = props
  const [values, setValue] = useState(value)
  const handleOnChange = event => {
    setValue(event.value)
    onChange({ data: event.value, type: 'radio' })
  }

  return (
    <div style={inline ? styles.inlineWrapper : styles.wrapper} className="form-group">
      <label style={ isError && customError.errorText || {} }>
        { required && <abbr title='required'>* </abbr> }
        { props.label }
      </label>

      {
        options.length > 0 &&
        options.map((option, index) => (
          <div key={index} style={styles.radioWrapper}>
            <RadioButton
              disabled={disabled}
              required
              value={option.value}
              checked={option.value === values}
              onChange={handleOnChange}
            />
            <span style={styles.label}>{option.label}</span>
          </div>
        ))
      }
    </div>
  )
}

const styles = {
  inlineWrapper: {
    display: 'flex',
    flexDirection: 'row',
    alignItems: 'center'
  },
  wrapper: {
    display: 'flex',
    flexDirection: 'column'
  },
  radioWrapper: {
    margin: 5,
    padding: 5,
    alignItems: 'center',
    display: 'flex'
  },
  label: {
    marginLeft: 5
  }
}

const customError = {
  control: (provided) => ({
    ...provided,
    borderColor: 'red',
  }),
  errorText: {
    color: 'red'
  }
}
