import React, { useState } from 'react'
import Calendar from 'react-calendar'

export default props => {
  const formatStringToDate = value => {
    if(value) {
      const toAarray = value.split('-')
      const year = toAarray[0]
      const month = toAarray[1]
      const day = toAarray[2]

      return new Date(year, month, day)
    }
  }

  const { isError, onChange, value, getCurrentDate } = props
  const [showDatePicker, setshowDatePicker] = useState(false)
  const [selectedDate, setselectedDate] = useState(formatStringToDate(value) || new Date())


  const formatDateToString = value => {
    const formatedDate = value.getDate()
    const formatedMonth = value.getMonth()
    const formatedYear = value.getFullYear()

    return formatedYear + '-' + formatedMonth + '-' + formatedDate
  }

  const onChangeDate = date => {
    onChange({data: formatDateToString(date), type: 'date'})
    setselectedDate(date)
    setshowDatePicker(false)
  }

  return (
    <div className='form-group'>
      <label style={isError && styles.errorText || {} }>
        { props.required && <abbr title='required'>* </abbr> }
        {props.label}
      </label>

      <input
        className='form-control'
        onFocus={() => setshowDatePicker(true)}
        value={value}
        style={
          Object.assign({},
            isError && styles.errorInput || {},
            styles.box
          )
        }
      />
      <div style={styles.calendar}>
        {showDatePicker && <Calendar onChange={onChangeDate} value={selectedDate} onFocus={() => setshowDatePicker(true)} minDate={new Date(1899, 12, 1)} maxDate={getCurrentDate && new Date() || null} /> }
      </div>
      {isError && <span style={styles.errorText}>Cannot be blank.</span>}
    </div>
  )
}

const styles = {
  calendar: {
    position: 'absolute',
    zIndex: 1031
  },
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
