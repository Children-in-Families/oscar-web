import React from 'react'
import DatePicker from 'react-date-picker'
import './datepicker.scss'

export default props => {
  const formatStringToDate = value => {
    if(value) {
      const toAarray = value.split('-')
      const year = toAarray[0]
      const month = toAarray[1] - 1
      const day = toAarray[2]

      return new Date(year, month, day)
    }
  }

  const { isError, onChange, value, getCurrentDate, T } = props

  const formatDateToString = value => {
    if(value) {
      const formatedDate = value.getDate()
      const formatedMonth = value.getMonth() + 1
      const formatedYear = value.getFullYear()

      return formatedYear + '-' + formatedMonth + '-' + formatedDate
    } else
      return null
  }

  const onChangeDate = date => {
    onChange({data: formatDateToString(date), type: 'date'})
  }

  return (
    <div className='form-group'>
      <label style={isError && styles.errorText || {} }>
        { props.required && <abbr title='required'>* </abbr> }
        {props.label}
      </label>

      <DatePicker
        className={isError && "error" || ""}
        onChange={onChangeDate}
        value={formatStringToDate(value)}
        minDate={new Date(1899, 12, 1)}
        maxDate={getCurrentDate && new Date() || null}
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
