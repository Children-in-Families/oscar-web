import React from 'react'
import {
  SelectInput,
  TextInput
} from '../Commons/inputs'

export default props => {
  const { onChange, data: { users, call, errorFields } } = props
  const userLists = users.map(user => ({label: user[0], value: user[1], isFixed: user[2] === 'locked' ? true : false }))
  const callTypes = ['case_action_required', 'notifier_concern', 'providing_update',
                    'phone_counseling', 'seeking_information', 'spam_call', 'wrong_number'];
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
              label="Phone Call ID #"
              onChange={onChange('call', 'phone_call_id')}
              value={call.phone_call_id}
            />
        </div>
      </div>

      <div className='row'>
        <div className='col-md-12 col-lg-9'>
          <SelectInput
            required
            isError={errorFields.includes('receiving_staff_id')}
            label='Receiving Staff'
            options={userLists}
            value={call.receiving_staff_id}
            onChange={onChange('call', 'receiving_staff_id')} />
        </div>
      </div>

      <div className='row'>
        <div className='col-md-12 col-lg-9'>
          <SelectInput
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
