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
    onChange, protectionConcerns, historyOfHarms, historyOfHighRiskBehaviours, reasonForFamilySeparations, historyOfDisabilities,
    setRiskAssessmentData, isError, setIsError,
    data: {
      assessment_date, protection_concern, other_protection_concern_specification, client_perspective, has_known_chronic_disease,
      has_disability, has_hiv_or_aid, known_chronic_disease_specification, disability_specification, hiv_or_aid_specification,
      relevant_referral_information, level_of_risk, history_of_disability_id, history_of_harm_id, history_of_high_risk_behaviour_id,
      history_of_family_separation_id, tasks_attributes: tasks
    }
  } = props

  const [riskLevel, setRiskLevel] = useState(level_of_risk === 'high')

  const createTask = (task) => {
    const newTasks = [...tasks, { ...task, complete: false }];

    setRiskAssessmentData(prev => ({...prev, tasks_attributes: newTasks}))
  };

  const deleteTask = (index) => {
    const newTasks = [...tasks]
    const removedTask = newTasks.splice(index, 1)

    const updatedTasks = tasks.map( task => {
      if (task.id === removedTask[0].id || task.id === undefined)
        return {
          id: removedTask[0].id,
          _destroy: true
        }
      else
        return task
    })

    setRiskAssessmentData(prev => ({...prev, tasks_attributes: updatedTasks}))
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

    setRiskAssessmentData(prev => ({...prev, level_of_risk: e.data}))
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
            value={assessment_date}
            onChange={onChange("riskAssessment", "assessment_date")}
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
            value={protection_concern}
            onChange={onChange('riskAssessment', 'protection_concern')}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-6">
          <TextInput
            label={"If other, please specify"}
            onChange={onChange("riskAssessment", "other_protection_concern_specification")}
            value={other_protection_concern_specification}
          />
        </div>
      </div>
      <div className="row">
        <div className="col-md-12 col-lg-6">
          <SelectInput
            isError={false}
            label={"Level of Risk"}
            options={levelOfRisk}
            value={level_of_risk}
            onChange={onLevelOfRiskSelected}
          />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-12">
          <TextArea
            label={"Client’s perspective on their problem and needs"}
            onChange={onChange("riskAssessment", "client_perspective")}
            value={client_perspective}
          />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-12 col-md-6">
          <RadioGroup
            inline
            label={"Does client have a known chronic disease?"}
            options={yesNoOpts}
            onChange={onChange("riskAssessment", "has_known_chronic_disease")}
            value={has_known_chronic_disease}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-6">
          <TextInput
            inline
            label={"If yes, please specify"}
            onChange={onChange("riskAssessment", "")}
            value={known_chronic_disease_specification}
          />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-12 col-md-6">
          <RadioGroup
            inline
            label={"Does client have disability?"}
            options={yesNoOpts}
            onChange={onChange("riskAssessment", "has_disability")}
            value={has_disability}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-6">
          <TextInput
            inline
            label={"If yes, please specify"}
            onChange={onChange("riskAssessment", "disability_specification")}
            value={disability_specification}
          />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-12 col-md-6">
          <RadioGroup
            inline
            label={"Does client have HIV/AID?"}
            options={yesNoOpts}
            onChange={onChange("riskAssessment", "hiv_or_aid_specification")}
            value={has_hiv_or_aid}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-6">
          <TextInput
            inline
            label={"Immediate Recomme ndation"}
            onChange={onChange("riskAssessment", "hiv_or_aid_specification")}
            value={hiv_or_aid_specification}
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
            value={history_of_disability_id}
            onChange={onChange("riskAssessment", "history_of_disability_id")}
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
            value={history_of_harm_id}
            onChange={onChange("riskAssessment", "history_of_harm_id")}
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
            value={history_of_high_risk_behaviour_id}
            onChange={onChange("riskAssessment", "history_of_high_risk_behaviour_id")}
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
            value={history_of_family_separation_id}
            onChange={onChange("riskAssessment", "history_of_family_separation_id")}
          />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-12">
          <TextArea
            label={"Relevant Referral Information"}
            onChange={onChange("riskAssessment", "relevant_referral_information")}
            value={relevant_referral_information}
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
                tasks.filter(task => task._destroy === undefined ).map((task, index) => {
                  return (
                    <TaskList task={task} deleteTask={deleteTask} key={`task-${index}`} index={index} />
                  )
                })
              }
              <TaskForm createTask={createTask} isError={isError} setIsError={setIsError} />
            </div>
          </div>
        </div>
      }
    </div>
  )
}
