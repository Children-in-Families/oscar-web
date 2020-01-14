import React, {useState, useEffect} from 'react'
import TimePicker from 'react-time-picker';
import './dateTimePicker.scss'

export default ({isError, required, label, onChange, value, T }) => {

  const onChangeDateTime = time => {
    onChange({data: time, type: 'datetime'})
  }

  return (
    <div className='form-group' id="form-group-date-time-picker">
      <label style={isError && styles.errorText || {} }>
        { required && <abbr title='required'>* </abbr> }
        {label}
      </label>

      <TimePicker
        className={isError && "error" || ""}
        onChange={onChangeDateTime}
        value={value}
      />
      {isError && <span style={styles.errorText}>{T.translate("validation.cannot_blank")}</span>}
    </div>
  )
}

const styles = {
  errorText: {
    color: 'red'
  },
  errorInput: {
    borderColor: 'red'
  },
  box: {
    boxShadow: 'none'
  }
}
