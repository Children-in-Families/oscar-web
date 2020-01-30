import React from 'react'
import {
  SelectInput,
  TextInput,
  RadioGroup,
  DateInput,
  DateTimePicker
} from '../Commons/inputs'

export default props => {
  const { onChange, data: { users, call, errorFields, T, step } } = props
  const userLists = users.map(user => ({label: user[0], value: user[1], isFixed: user[2] === 'locked' ? true : false }))
  // const callTypes = ['case_action_required', 'notifier_concern', 'providing_update',
  //                   'phone_counseling', 'seeking_information', 'spam_call', 'wrong_number'];

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

  return (
    <>
      <legend className='legend'>
        <div className="row">
          <div className="col-md-12 col-lg-9">
            <p>{T.translate("newCall.admin.call_information")}</p>
          </div>
        </div>
      </legend>

      {/* removed since it should be set after the call is saved */}
      {/* <div className='row'>
        <div className='col-md-12 col-lg-9'>
          <TextInput
            T={T}
            required
            isError={errorFields.includes('phone_call_id')}
            label={T.translate("newCall.admin.phone_call")}
            onChange={onChange('call', 'phone_call_id')}
            value={call.phone_call_id}
            />
        </div>
      </div> */}

      <div className='row'>
        <div className='col-md-12 col-lg-9'>
          <SelectInput
            T={T}
            required
            isError={errorFields.includes('receiving_staff_id')}
            label={T.translate("newCall.admin.receiving_staff")}
            options={userLists}
            value={call.receiving_staff_id}
            onChange={onChange('call', 'receiving_staff_id')}
          />

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
            disabled={step > 1}
            T={T}
            required
            isError={errorFields.includes('call_type')}
            label={T.translate("newCall.admin.call_type")}
            options={callTypeList}
            value={call.call_type}
            onChange={onChange('call','call_type')} />
        </div>
      </div>
    </>
  )
}
