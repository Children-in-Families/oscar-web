import React, { useState, useEffect } from 'react'
import {
  SelectInput,
  TextInput,
  RadioGroup,
  DateInput,
  TextArea,
  DateTimePicker
} from '../Commons/inputs'

import './styles.scss'

import { setDefaultLanguage } from './helper'

export default props => {
  const { data: { users, call, step } } = props

  const [loading, setLoading] = useState(false)
  const [errorFields, setErrorFields] = useState([])
  const [callData, setCallData] = useState(call)
  const userLists = users.map(user => ({label: user[0], value: user[1], isFixed: user[2] === 'locked' ? true : false }))
  var url = window.location.href.split("&").slice(-1)[0].split("=")[1]

  let T = setDefaultLanguage(url)

  const answeredCallOpts = [
    { label: T.translate("newCall.refereeInfo.answeredCallOpts.call_answered"), value: true },
    { label: T.translate("newCall.refereeInfo.answeredCallOpts.return_missed_call"), value: false }
  ];

  const calledBeforeOpts = [
    { label: T.translate("newCall.refereeInfo.yes"), value: true },
    { label: T.translate("newCall.refereeInfo.no"), value: false }
  ];

  const callTypes = [
    T.translate("editCall.index.calltypes.new_referral_case"),
    T.translate("editCall.index.calltypes.new_referral_notifier"),
    T.translate("editCall.index.calltypes.providing_update"),
    T.translate("editCall.index.calltypes.phone_conseling"),
    T.translate("editCall.index.calltypes.seeking_information"),
    T.translate("editCall.index.calltypes.spam_call"),
    T.translate("editCall.index.calltypes.wrong_number")
  ];

  const callTypeList = callTypes.map(type => (
    { label: type, value: type, isFixed: false }
  ));

  const noClientAttached = callData.call_type === "Seeking Information" || callData.call_type === "Spam Call" || callData.call_type === "Wrong Number"
  const seekingInformation = callData.call_type === "Seeking Information"

  const onChange = (obj, field) => event => {
    const inputType = ['date', 'select', 'checkbox', 'radio', 'datetime']
    const value = inputType.includes(event.type) ? event.data : event.target.value

    if (typeof field !== 'object')
      field = { [field]: value }

    switch (obj) {
      case 'call':
        setCallData({...callData, ...field})
        break;
    }
  }

  const handleCancel = () => {
    document.location.href = `/calls/${callData.id}${window.location.search}`
  }

  const handleSave = () => {
    if(handleValidation()) {
      $.ajax({
        url: `/api/v1/calls/${callData.id}`,
        type: 'PUT',
        data: {
          call: { ...callData }
        },
        beforeSend: (req) => {
          setLoading(true)
        }
      })
      .success(response => {
        const clientUrls = response.client_urls;
        const message = T.translate("editCall.index.message.call_has_been_updated")

        document.location.href = `/calls/${response.call.id}?notice=${message}&locale=${url}`
        if (clientUrls) {
          clientUrls.forEach(url => {
            window.open(`${url}?notice=${message}`, '_blank');
          });
        }
      })
      .error(err => {
        console.log("err: ", err);
      })
    }
  }

  const handleValidation = () => {
    const validationFields = seekingInformation ? ['receiving_staff_id', 'date_of_call', 'start_datetime', 'information_provided'] : ['receiving_staff_id', 'date_of_call', 'start_datetime']
    const errors = []

    validationFields.forEach(field => {
      if (callData[field] === null) {
        errors.push(field)
      } else if(callData[field].length < 1) {
        errors.push(field)
      }
    })

    if(errors.length > 0) {
      setErrorFields(errors)
      return false
    } else {
      setErrorFields([])
      return true
    }
  }

  return (
      <>
      <legend className='legend'>
        <div className="row">
          <div className="col-sm-12">
            <p>{T.translate("editCall.index.call_information")}</p>
          </div>
        </div>
      </legend>

      <div className="row">
        <div className="col-xs-12">
          <RadioGroup
            inline
            required
            isError={errorFields.includes("answered_call")}
            options={answeredCallOpts}
            label={T.translate("newCall.admin.referee_answered_call")}
            value={callData.answered_call}
            onChange={onChange("call", "answered_call")}
          />
        </div>
      </div>

      <div className="row">
        <div className="col-xs-12">
          <RadioGroup
            inline
            required
            isError={errorFields.includes("called_before")}
            label={T.translate("newCall.admin.referee_called_before")}
            options={calledBeforeOpts}
            value={callData.called_before}
            onChange={onChange("call", "called_before")}
          />
        </div>
      </div>

      <div className='row'>
        <div className='col-sm-12 col-md-6'>
          <SelectInput
            T={T}
            required
            isError={errorFields.includes('receiving_staff_id')}
            label={T.translate("editCall.index.receiving_staff")}
            options={userLists}
            value={callData.receiving_staff_id}
            onChange={onChange('call', 'receiving_staff_id')}
          />
        </div>
        <div className='col-sm-12 col-md-6'>
          {/* <DateInput
            T={T}
            required
            isError={errorFields.includes('date_of_call')}
            getCurrentDate
            label="Date of Call"
            onChange={onChange('call', 'date_of_call')}
            value={callData.date_of_call}
          /> */}
          <TextInput
            T={T}
            type="date"
            required
            isError={errorFields.includes('date_of_call')}
            label={T.translate("editCall.index.date_of_call")}
            onChange={onChange('call', 'date_of_call')}
            value={callData.date_of_call}
          />
        </div>
      </div>

      <div className='row'>
        <div className='col-sm-12 col-md-6'>
          {/* <DateTimePicker
            T={T}
            isError={errorFields.includes('start_datetime')}
            label="Time Call Began"
            required={true}
            onChange={onChange('call', 'start_datetime')}
            value={callData.start_datetime}
          /> */}
          <TextInput
            type="time"
            T={T}
            isError={errorFields.includes('start_datetime')}
            label={T.translate("editCall.index.time_call_began")}
            required={true}
            onChange={onChange('call', 'start_datetime')}
            value={callData.start_datetime}
          />
        </div>
      </div>

      <div className='row'>
        <div className='col-sm-12 col-md-6'>
          <RadioGroup
            disabled={true}
            T={T}
            required
            isError={errorFields.includes('call_type')}
            label={T.translate("editCall.index.call_type")}
            options={callTypeList}
            value={callData.call_type}
            onChange={onChange('call','call_type')} />
        </div>
        { noClientAttached ?
          <div className="col-xs-12 col-md-6">
            <TextArea
              T={T}
              required={ seekingInformation }
              isError={errorFields.includes('information_provided')}
              placeholder={T.translate("newCall.admin.add_note_about_the_content")}
              label={T.translate("editCall.index.information_provided")}
              value={callData.information_provided}
              onChange={onChange('call', 'information_provided')} />
          </div>
          :
          <div></div>
        }
      </div>

      {/* <div className="row">
        <div className="col-xs-12">
          <Checkbox
            disabled={true}
            label={T.translate("newCall.refereeInfo.this_caller_has_requested")}
            checked={callData.requested_update || false}
            onChange={onChange("call", "requested_update")}
          />
        </div>
      </div> */}

      <div className='row'>
        <div className='col-sm-12 text-right'>
          <span className='btn btn-success form-btn' onClick={handleSave}>{T.translate("editCall.index.save")}</span>
          <span className='btn btn-default form-btn' onClick={handleCancel}>{T.translate("editCall.index.cancel")}</span>
        </div>
      </div>
    </>
  )
}
