import React, { useEffect, useState } from "react";
import {
  SelectInput,
  DateInput,
  TextInput,
  RadioGroup,
  TextArea,
} from "../Commons/inputs";
import T from 'i18n-react'
import { t } from "../../utils/i18n";
import TaskForm from "./taskForm";
import TaskList from "./taskList";

export default (props) => {
  const {
    onChange, protectionConcerns, historyOfHarms, historyOfHighRiskBehaviours, reasonForFamilySeparations, historyOfDisabilities
  } = props

  const taskProps = [{name: 'Test', expected_date: '2022-08-01', completed: true}]
  const [tasks, setTasks] = useState(taskProps)
  const [riskLevel, setRiskLevel] = useState(false)

  const createTask = (task) => {
    const newTasks = [...tasks, { ...task, complete: false }];
    setTasks(newTasks);
  };

  const deleteTask = (index) => {
    const newTasks = [...tasks]
    newTasks.splice(index, 1)
    setTasks(newTasks)
  }

  const yesNoOpts = [
    { label: T.translate("newCall.refereeInfo.yes"), value: true },
    { label: T.translate("newCall.refereeInfo.no"), value: false },
  ];

  const levelOfRisk = [
    { label: 'High', value: 'high'},
    { label: 'Medium', value: 'medium'},
    { label: 'Low', value: 'low'},
    { label: 'No Action', value: 'no action'},
  ]

  const onLevelOfRiskSelected = (e) => {
    if (e.data === 'high')
      setRiskLevel(true)
    else
      setRiskLevel(false)
  }


  return (
    <div className="containerClass">
      <legend>
        <div className="row">
          <div className="col-xs-6">
            <p>Protection Concern</p>

          </div>
        </div>
      </legend>
      <div className="row">
        <div className="col-md-12 col-lg-5">
          <DateInput
            T={'Assessment Date'}
            isError={false}
            label={"Assessment Date"}
            value={'2022-07-20'}
            onChange={onChange("client", "")}
            />
          </div>
        </div>
      <div className="row">
        <div className="col-md-12 col-lg-6">
          <SelectInput
            isError={false}
            isMulti
            label={"Protection Concern"}
            asGroup
            options={protectionConcerns}
            value={''}
            onChange={onChange('risk_assessment', '')}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-6">
          <TextInput
            label={"If other, please specify"}
            onChange={onChange("client", "")}
            value={''}
          />
        </div>
      </div>
      <div className="row">
        <div className="col-md-12 col-lg-6">
          <SelectInput
            isError={false}
            label={"Level of Risk"}
            options={levelOfRisk}
            value={''}
            onChange={onLevelOfRiskSelected}
          />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-12">
          <TextArea
            label={"Client’s perspective on their problem and needs"}
            onChange={onChange("client", "")}
            value={''}
            inlineClassName="client-perspective"
          />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-12 col-md-6">
          <RadioGroup
            inline
            label={"Does client have a known chronic disease?"}
            options={yesNoOpts}
            onChange={onChange()}
            value={false}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-6">
          <TextInput
            inline
            label={"If yes, please specify"}
            onChange={onChange("client", "")}
            value={''}
          />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-12 col-md-6">
          <RadioGroup
            inline
            label={"Does client have disability?"}
            options={yesNoOpts}
            onChange={onChange()}
            value={false}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-6">
          <TextInput
            inline
            label={"If yes, please specify"}
            onChange={onChange("client", "")}
            value={''}
          />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-12 col-md-6">
          <RadioGroup
            inline
            label={"Does client have HIV/AID?"}
            options={yesNoOpts}
            onChange={onChange()}
            value={false}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-6">
          <TextInput
            inline
            label={"Immediate Recommendation"}
            onChange={onChange("client", "")}
            value={''}
          />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-12">
          <SelectInput
            inline
            isError={false}
            label={"History of disability and/or illness"}
            options={historyOfDisabilities}
            value={''}
            width={'45%'}
            onChange={onChange("client", "")}
          />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-12">
          <SelectInput
            inline
            isError={false}
            label={"History of Harm"}
            options={historyOfHarms}
            value={''}
            onChange={onChange("client", "")}
          />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-12">
          <SelectInput
            inline
            isError={false}
            label={"History of high-risk behaviours"}
            options={historyOfHighRiskBehaviours}
            value={''}
            onChange={onChange("client", "")}
          />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-12">
          <SelectInput
            inline
            isError={false}
            label={"Reason for Family Separation"}
            options={reasonForFamilySeparations}
            value={''}
            onChange={onChange("client", "")}
          />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-12">
          <TextArea
            label={"Relevant Referral Information"}
            onChange={onChange("client", "")}
            value={''}
          />
        </div>
      </div>
      {
        riskLevel && <div className="containerClass">
          <legend>
            <div className="row">
              <div className="col-xs-12">
                <p>Tasks</p>

              </div>
            </div>
          </legend>
          <div className="row">
            <div className="col-xs-12 col-md-10">
              {
                tasks.map((task, index) => {
                  return (
                    <TaskList task={task} deleteTask={deleteTask} key={`task-${index}`} index={index} />
                  )
                })
              }
              <TaskForm createTask={createTask} />
            </div>
          </div>
        </div>
      }
    </div>
  )
}
