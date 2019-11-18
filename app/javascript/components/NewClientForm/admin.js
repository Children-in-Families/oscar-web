import React from 'react'
import {
  SelectInput,
  DateInput
} from '../Commons/inputs'

export default props => {
  const { onChange, data: { users, client } } = props
  const userLists = users.map(user => ({label: user.first_name + ' ' + user.last_name, value: user.id}))

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
          <SelectInput label='Receiving Staff Member' options={userLists} onChange={onChange('client', 'received_by_id')} />
        </div>
      </div>

      <div className='row'>
        <div className='col-xs-8'>
          <DateInput label='Date of Referral' value={client.initial_referral_date} onChange={onChange('client', 'initial_referral_date')} />
        </div>
      </div>

      <div className='row'>
        <div className='col-xs-8'>
          <SelectInput label='Case Worker / Assigned Staff Memger' isMulti options={userLists} onChange={onChange('referee','users')} />
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
