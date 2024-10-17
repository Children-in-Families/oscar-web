import React, { useState, useEffect } from "react";
import { DateInput, TextInput } from "../Commons/inputs";

export default (props) => {
  const {
    T,
    tasks,
    task,
    setNewTasks,
    setRiskAssessmentData,
    deleteTask,
    index,
    labels
  } = props;

  const [name, setName] = useState(task.name);
  const [expectedDate, setExpectedDate] = useState(task.expected_date);

  useEffect(() => {
    let newTasks = [];
    if (name || expectedDate) {
      if (task.id) {
        newTasks = tasks.map((obj) =>
          obj.id === task.id
            ? { ...obj, name: name, expected_date: expectedDate }
            : obj
        );
        setNewTasks(newTasks);
        setRiskAssessmentData((prev) => ({
          ...prev,
          tasks_attributes: newTasks
        }));
      } else {
        const newTask = tasks.splice(index, 1)[0] || {};
        newTask.name = name;
        newTask.expected_date = expectedDate;

        newTasks = [...tasks, newTask];
        setNewTasks(newTasks);
        setRiskAssessmentData((prev) => ({
          ...prev,
          tasks_attributes: newTasks
        }));
      }
    }
  }, [name, expectedDate]);

  const handleChange = (e) => {
    if (e.type === "date") setExpectedDate(e.data);
    else setName(e.target.value);
  };

  const handleRemoveTask = (index) => {
    let isYes = confirm("Are you sure to delete task?");
    if (isYes) deleteTask(index);
  };

  return (
    <div className="row">
      <div className="col-xs-12 col-md-5 col-lg-5">
        {task.completed ? (
          <div>
            <label>{labels.title}</label>
            <p>{task.name}</p>
          </div>
        ) : (
          <TextInput
            label={labels.title}
            required={true}
            isError={name == undefined || name.length == 0}
            onChange={handleChange}
            value={name}
          />
        )}
      </div>
      <div className="col-xs-12 col-md-5 col-lg-5">
        {task.completed ? (
          <div>
            <label>{labels.expected_date}</label>
            <p>{task.expected_date}</p>
          </div>
        ) : (
          <DateInput
            label={labels.expected_date}
            required={true}
            value={expectedDate}
            isError={expectedDate == undefined || expectedDate.length == 0}
            onChange={handleChange}
          />
        )}
      </div>
      <div className="col-xs-12 col-md-2">
        {!task.completed && (
          <button
            className="btn btn-danger m-t-lg"
            onClick={(e) => {
              e.preventDefault();
              handleRemoveTask(index);
            }}
          >
            <i className="fa fa-trash"></i>
          </button>
        )}
      </div>
    </div>
  );
};
