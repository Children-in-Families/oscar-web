import React from 'react'
import {
  SelectInput,
  TextInput,
  RadioGroup,
  DateInput,
  DateTimePicker
} from '../Commons/inputs'

export default props => {
  const { onChange, data: { users, call, errorFields, T } } = props
  const userLists = users.map(user => ({label: user[0], value: user[1], isFixed: user[2] === 'locked' ? true : false }))
  // const callTypes = ['case_action_required', 'notifier_concern', 'providing_update',
  //                   'phone_counseling', 'seeking_information', 'spam_call', 'wrong_number'];

  const callTypes = [
                    "New Referral: Case Action Required", "New Referral: Notifier Concern",
                    "Providing Update", "Phone Counseling",
                    "Seeking Information", "Spam Call", "Wrong Number"];

  const callTypeList = callTypes.map(type => (
    { label: type, value: type, isFixed: false }
  ));

  return (
    <>
      <legend className='legend'>
        <div className="row">
          <div className="col-md-12 col-lg-9">
            <p>Call Information</p>
          </div>
        </div>
      </legend>

      <div className='row'>
        <div className='col-md-12 col-lg-9'>
          <TextInput
            T={T}
            required
            isError={errorFields.includes('phone_call_id')}
            label="Phone Call ID #"
            onChange={onChange('call', 'phone_call_id')}
            value={call.phone_call_id}
            />
        </div>
      </div>

      <div className='row'>
        <div className='col-md-12 col-lg-9'>
          <SelectInput
            T={T}
            required
            isError={errorFields.includes('receiving_staff_id')}
            label='Receiving Staff'
            options={userLists}
            value={call.receiving_staff_id}
            onChange={onChange('call', 'receiving_staff_id')} />

          {/* 2. Is Receiving Staff of hotline the same as Receving Staff Member in AHT?
          If yes, use the following instead. */}
          {/* <SelectInput
            T={T}
            required
            isError={errorFields.includes('receiving_staff_id')}
            label='Receiving Staff'
            options={userLists}
            value={call.receiving_staff_id}
            onChange={(value) => { onChange('call', 'receiving_staff_id')(value); onChange('client', 'received_by_id')(value) }}
            /> */}
        </div>
      </div>


      <div className='row'>
        <div className='col-md-12 col-lg-9'>
          <DateInput
            T={T}
            required
            isError={errorFields.includes('date_of_call')}
            getCurrentDate
            label="Date of Call"
            onChange={onChange('call', 'date_of_call')}
            value={call.date_of_call}
          />
        </div>
      </div>

      <div className='row'>
        <div className='col-md-12 col-lg-9'>
          <DateTimePicker
            T={T}
            isError={errorFields.includes('start_datetime')}
            label="Time Call Began"
            required={true}
            onChange={onChange('call', 'start_datetime')}
            value={call.start_datetime}
          />
        </div>
      </div>

      <div className='row'>
        <div className='col-md-12 col-lg-9'>
          <DateTimePicker
            T={T}
            isError={errorFields.includes('end_datetime')}
            label="Time Call Ended"
            required={true}
            onChange={onChange('call', 'end_datetime')}
            value={call.end_datetime}
          />
        </div>
      </div>

      <div className='row'>
        <div className='col-md-12 col-lg-9'>
          <RadioGroup
            T={T}
            required
            isError={errorFields.includes('call_type')}
            label='Call Type'
            options={callTypeList}
            value={call.call_type}
            onChange={onChange('call','call_type')} />
        </div>
      </div>
    </>
  )
}
