import React, { useState } from 'react'
import DatePicker from 'react-date-picker'
import './datepicker.scss'

export default props => {
  const formatStringToDate = value => {
    if(value) {
      // const toAarray = value.split('-')
      // const year = toAarray[0]
      // const month = toAarray[1] - 1
      // const day = toAarray[2]

      return new Date(value)
    }
  }

  const { isError, onChange, value, getCurrentDate, T, hintText,inlineClassName, ...others } = props
  const [currentDate, setDate] = useState(value)

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
    if(date && date.getFullYear() > 1900){
      onChange({data: formatDateToString(date), type: 'date'})
      setDate(date)
    } else if(value && new Date(value).getFullYear() > 1970){
      onChange({data: formatDateToString(new Date(value)), type: 'date'})
      setDate(value)
    } else {
      onChange({data: null, type: 'date'})
      setDate(null)
    }
  }

  return (
    <div className='form-group'>
      <label style={isError && styles.errorText || {} }>
        { props.required && <abbr title='required'>* </abbr> }
        {props.label}
      </label>
      {
        inlineClassName &&
        <a
          tabIndex="0"
          data-toggle="popover"
          role="button"
          data-html="true"
          data-placement="bottom"
          data-trigger="focus"
          data-content={ hintText || 'N/A' }>
          <i className={`fa fa-info-circle text-info m-xs ${inlineClassName}`}></i>
        </a>

      }
      <DatePicker
        className={isError && "error" || ""}
        onChange={onChangeDate}
        value={formatStringToDate(currentDate || value)}
        minDate={new Date(1899, 12, 1)}
        maxDate={getCurrentDate && new Date() || null}
        />
      { isError && <span style={ styles.errorText }>{ T.translate("validation.cannot_blank") }</span> }
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
