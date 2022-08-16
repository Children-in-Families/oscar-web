import React, { useEffect, useState } from "react";
import { DateInput } from "semantic-ui-calendar-react";
import T from 'i18n-react'
import '../Commons/inputs/datepicker.scss'

export default (props) => {
  const {
    createTask
  } = props

  const [name, setName] = useState('')
  const [expectedDate, setExpectedDate] = useState(null)
  const [isError, setIsError] = useState(false)

  const handleAppendTasks = e => {
    e.preventDefault();
    if(name !== '' || expectedDate !== null) {
      createTask({name: name, expected_date: expectedDate})
      setName('')
      setExpectedDate(null)
    } else {
      setIsError(true)
    }
  }

  const onDateChange = (event, {name, value}) => {
    setExpectedDate(value)
  }

  return (
    <div className="row">
      <div className="col-xs-12 col-md-5 col-lg-5">
        <div className='form-group'>
          <label>Name</label>
          <input
            className={`${(isError && 'error')} form-control m-t-xs`}
            onChange={(e) => setName(e.target.value)}
            value={name}
          />
          {isError && (
            <span style={styles.errorText}>
              {T.translate("validation.cannot_blank")}
            </span>
          )}
        </div>
      </div>
      <div className="col-xs-12 col-md-5 col-lg-5">
        <DateInput
          label="Expected Date"
          className={`${(isError && 'error')} calendar-input`}
          placeholder="..../../.."
          name="date"
          dateFormat="YYYY-MM-DD"
          closable
          clearable={false}
          animation="scale"
          duration={200}
          hideMobileKeyboard
          value={expectedDate}
          iconPosition="left"
          onChange={onDateChange}
          minDate={new Date(1899, 12, 1)}
        />
        {isError && (
          <span style={styles.errorText}>
            {T.translate("validation.cannot_blank")}
          </span>
        )}
      </div>
      <div className="col-xs-12 col-md-2">
        <button
          className="btn btn-primary m-t-lg"
          onClick={handleAppendTasks}
        >Add tasks</button>
      </div>
    </div>
  )
}

const styles = {
  errorText: {
    color: "red",
  },
  errorInput: {
    borderColor: "red !important",
  },
  box: {
    boxShadow: "none",
  },
};

