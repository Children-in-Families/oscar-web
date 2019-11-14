import React, { useState } from 'react'
import Calendar from 'react-calendar'

export default props => {
  const { onChange, value } = props
  const [showDatePicker, setshowDatePicker] = useState(false)
  const [selectedDate, setselectedDate] = useState(value || new Date())

  const formatDate = value => {
    const formatedDate = value.getDate()
    const formatedMonth = value.getMonth()
    const formatedYear = value.getFullYear()

    return formatedYear + '-' + formatedMonth + '-' + formatedDate
  }

  const onChangeDate = date => {
    onChange(formatDate(date))
    setselectedDate(date)
    setshowDatePicker(false)
  }
  // onBlur={() => setshowDatePicker(false)}
  return (
    <div className='form-group'>
      <label>
        { props.required && <abbr title='required'>* </abbr> }
        {props.label}
      </label>

      {/* <div onFocus={() => setshowDatePicker(true)} onBlur={() => setshowDatePicker(false)} > */}
      <input className='form-control' onFocus={() => setshowDatePicker(true)} value={formatDate(selectedDate)} />
      <div style={styles.calendar}>
        {showDatePicker && <Calendar onChange={onChangeDate} value={selectedDate} onFocus={() => setshowDatePicker(true)} /> }
      </div>
      {/* </div> */}
    </div>
  )
}

const styles = {
  calendar: {
    position: 'absolute',
    zIndex: 1031
  }
}
