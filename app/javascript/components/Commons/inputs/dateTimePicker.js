import React, {useState, useEffect} from 'react'
import DateTimePicker from 'react-datetime-picker';
import './dateTimePicker.scss'
import { formatTime } from './../../DetailCall/helper'

export default ({isError, required, label, onChange, value, T }) => {

  const onChangeDateTime = time => {
    onChange({data: time, type: 'datetime'})
  }

  const formatDateToString = () => {
    if(_isValidTime()) {
      return value
    } else {
      return formatTime(value)
    }
  }

  const _isValidTime = () => {
    let patt = new RegExp(/^(\d{1,}:\d{1,})$/g)
    let result = patt.test(value)
    return result
  }

  return (
    <div className='form-group' id="form-group-date-time-picker">
      <label style={isError && styles.errorText || {} }>
        { required && <abbr title='required'>* </abbr> }
        {label}
      </label>
      <DateTimePicker
        className={isError && "error" || ""}
        onChange={onChange}
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
