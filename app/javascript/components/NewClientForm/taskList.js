import React, { useEffect } from "react";
import {
  DateInput,
  TextInput,
} from "../Commons/inputs";
import T from 'i18n-react'

export default (props) => {
  const {
    task, deleteTask, index, labels
  } = props

  const handleRemoveTask = index => {
    let isYes = confirm("Are you sure to delete task?");
    if (isYes)
      deleteTask(index)
  }

  const onChange = (e) => {
    if (e.type === 'date')
      task.expected_date = e.data
    else
      task.name = e.target.value
  }

  return (
    <div className="row">
      <div className="col-xs-12 col-md-5 col-lg-5">
        {
          task.completed ? <div>
            <label>{labels.title}</label>
            <p>{task.name}</p>
          </div>
          :
          <TextInput
            label={labels.title}
            onChange={onChange}
            value={task.name}
          />
        }

      </div>
      <div className="col-xs-12 col-md-5 col-lg-5">
        { task.completed ? <div>
            <label>{labels.expected_date}</label>
            <p>{task.expected_date}</p>
          </div>
          :
          <DateInput
            isError={false}
            label={labels.expected_date}
            value={task.expected_date}
            onChange={onChange}
          />
        }
      </div>
      <div className="col-xs-12 col-md-2">
        { !task.completed && <button
          className="btn btn-danger m-t-lg"
          onClick={(e) => { e.preventDefault(); handleRemoveTask(index) }}
        >
          <i className="fa fa-trash"></i>
        </button> }
      </div>
    </div>
  )
}

