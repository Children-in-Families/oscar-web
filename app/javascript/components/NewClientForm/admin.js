import React from 'react'
import {
  SelectInput,
  DateInput
} from '../Commons/inputs'

export default props => {
  const { onChange, data: { users, client, errorFields } } = props
  // const userLists = users.map(user => ({label: user.first_name + ' ' + user.last_name, value: user.id}))
  const userLists = users.map(user => ({label: user[0], value: user[1], isFixed: user[2] === 'locked' ? true : false }))

  return (
    <>
      <legend className='legend'>
        <div className="row">
          <div className="col-xs-8">
            <p>Administrative Information</p>
          </div>
        </div>
      </legend>

      <div className='row'>
        <div className='col-xs-8'>
          <SelectInput
            required
            isError={errorFields.includes('received_by_id')}
            label='Receiving Staff Member'
            options={userLists}
            value={client.received_by_id}
            onChange={onChange('client', 'received_by_id')} />
        </div>
      </div>

      <div className='row'>
        <div className='col-xs-8'>
          <DateInput
            required
            isError={errorFields.includes('initial_referral_date')}
            label='Date of Referral'
            value={client.initial_referral_date}
            onChange={onChange('client', 'initial_referral_date')} />
        </div>
      </div>

      <div className='row'>
        <div className='col-xs-8'>
          <SelectInput
            required
            isError={errorFields.includes('user_ids')}
            label='Case Worker / Assigned Staff Manager'
            isMulti
            options={userLists}
            value={client.user_ids}
            onChange={onChange('client','user_ids')} />
        </div>
      </div>

      <div className='row'>
        <div className='col-xs-8'>
          <SelectInput label='First Follow Up by' options={userLists} onChange={onChange('client', 'followed_up_by_id')} />
        </div>
      </div>

      <div className='row'>
        <div className='col-xs-8'>
          <DateInput label='Date of First Follow Up' collections={userLists} onChange={onChange('client','follow_up_date')} />
        </div>
      </div>
    </>
  )
}
