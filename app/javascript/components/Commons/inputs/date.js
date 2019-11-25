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

  const {isError, onChange, value } = props
  const [showDatePicker, setshowDatePicker] = useState(false)
  const [selectedDate, setselectedDate] = useState(formatStringToDate(value) || new Date())


  const formatDateToString = value => {
    const formatedDate = value.getDate()
    const formatedMonth = value.getMonth()
    const formatedYear = value.getFullYear()

    return formatedYear + '-' + formatedMonth + '-' + formatedDate
  }

  const onChangeDate = date => {
    onChange(formatDateToString(date))
    setselectedDate(date)
    setshowDatePicker(false)
  }

  return (
    <div className='form-group'>
      <label style={isError && styles.errorText || {} }>
        { props.required && <abbr title='required'>* </abbr> }
        {props.label}
      </label>

      <input className='form-control' onFocus={() => setshowDatePicker(true)} value={formatDateToString(selectedDate)} style={ isError && styles.errorInput || {} }/>
      <div style={styles.calendar}>
        {showDatePicker && <Calendar onChange={onChangeDate} value={selectedDate} onFocus={() => setshowDatePicker(true)} /> }
      </div>
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
  }
}
