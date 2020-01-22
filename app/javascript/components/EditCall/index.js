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

  const callTypes = [
    T.translate("newCall.admin.calltypes.new_referral_case"),
    T.translate("newCall.admin.calltypes.new_referral_notifier"),
    T.translate("newCall.admin.calltypes.providing_update"),
    T.translate("newCall.admin.calltypes.phone_conseling"),
    T.translate("newCall.admin.calltypes.seeking_infomation"),
    T.translate("newCall.admin.calltypes.spam_call"),
    T.translate("newCall.admin.calltypes.wrong_number")
  ];

  const callTypeList = callTypes.map(type => (
    { label: type, value: type, isFixed: false }
  ));

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
        const message = T.translate("newCall.index.message.call_has_been_updated")
        
        document.location.href = `/calls/${response.call.id}?notice=${message}`
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
    const validationFields = ['phone_call_id', 'receiving_staff_id', 'date_of_call', 'start_datetime', 'end_datetime']
    const errors = []
    
    validationFields.forEach(field => {
      if(callData[field].length <= 0 || callData[field] === null) {
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
            <p>{T.translate("newCall.admin.call_information")}</p>
          </div>
        </div>
      </legend>

      <div className='row'>
        <div className='col-sm-12'>
          <TextInput
            T={T}
            required
            isError={errorFields.includes('phone_call_id')}
            label={T.translate("newCall.admin.phone_call")}
            onChange={onChange('call', 'phone_call_id')}
            value={callData.phone_call_id}
            />
        </div>
      </div>
      
      <div className='row'>
        <div className='col-sm-12'>
          <SelectInput
            T={T}
            required
            isError={errorFields.includes('receiving_staff_id')}
            label={T.translate("newCall.admin.receiving_staff")}
            options={userLists}
            value={callData.receiving_staff_id}
            onChange={onChange('call', 'receiving_staff_id')}
          />
        </div>
      </div>


      <div className='row'>
        <div className='col-sm-12'>
          <DateInput 
            T={T}
            required
            isError={errorFields.includes('date_of_call')}
            getCurrentDate 
            label="Date of Call" 
            onChange={onChange('call', 'date_of_call')} 
            value={callData.date_of_call} 
          />
        </div>
      </div>

      <div className='row'>
        <div className='col-sm-12'>
          <DateTimePicker
            T={T}
            isError={errorFields.includes('start_datetime')}
            label="Time Call Began"
            required={true}
            onChange={onChange('call', 'start_datetime')}
            value={callData.start_datetime}
          />
        </div>
      </div>

      <div className='row'>
        <div className='col-sm-12'>
         <DateTimePicker
            T={T}
            isError={errorFields.includes('end_datetime')}
            label="Time Call Ended"
            required={true}
            onChange={onChange('call', 'end_datetime')}
            value={callData.end_datetime}
          />
        </div>
      </div>

      <div className='row'>
        <div className='col-sm-12'>
          <RadioGroup
            disabled={true}
            T={T}
            required
            isError={errorFields.includes('call_type')}
            label={T.translate("newCall.admin.call_type")}
            options={callTypeList}
            value={callData.call_type}
            onChange={onChange('call','call_type')} />
        </div>
      </div>

      <div className="row">
        <div className="col-xs-12">
          <TextArea
            label
            placeholder={T.translate("newCall.referralMoreInfo.add_note_about_the_content")}
            label="Phone Counselling Summary"
            value={callData.phone_counselling_summary}
            onChange={onChange('call', 'phone_counselling_summary')} />
        </div>
      </div>

       <div className="row">
        <div className="col-xs-12">
          <TextArea
            placeholder={T.translate("newCall.referralMoreInfo.add_note_about_the_content")}
            label="Information Provided"
            value={callData.information_provided}
            onChange={onChange('call', 'information_provided')} />
        </div>
      </div>

      <div className='row'>
        <div className='col-sm-12'>
          <span className='btn btn-success btn-block' onClick={handleSave}>{T.translate("newCall.index.save")}</span>
        </div>
      </div>

      <br />

      <div className='row'>
        <div className='col-sm-12'>
          <span className='btn btn-default btn-block' onClick={() => {}}>{T.translate("newCall.index.cancel")}</span>
        </div>
      </div>
    </>
  
  )
}
