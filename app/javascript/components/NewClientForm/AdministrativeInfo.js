import React from 'react'
import {
  SelectInput,
  DateInput
} from '../Commons/inputs'

export default props => {
  const { onChangeDate, onChangeSelect, data: { users, client } } = props
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
          <SelectInput label='Receiving Staff Member' collections={userLists} onChangeSelect={onChangeSelect} name='received_by_id' />
        </div>
      </div>

      <div className='row'>
        <div className='col-xs-8'>
          <DateInput label='Date of Referral' value={client.initial_referral_date} onChangeDate={onChangeDate} name='initial_referral_date' />
        </div>
      </div>

      <div className='row'>
        <div className='col-xs-8'>
          <SelectInput label='Case Worker / Assigned Staff Memger' isMulti collections={userLists} onChangeSelect={onChangeSelect} name='users' />
        </div>
      </div>

      <div className='row'>
        <div className='col-xs-8'>
          <SelectInput label='First Follow Up by' collections={userLists} onChangeSelect={onChangeSelect} name='followed_up_by_id' />
        </div>
      </div>

      <div className='row'>
        <div className='col-xs-8'>
          <DateInput label='Date of First Follow Up' collections={userLists} onChangeDate={onChangeDate} name='follow_up_date' />
        </div>
      </div>
    </>
  )
}
