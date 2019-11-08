import React from 'react'
import {
  SelectInput,
  DateInput
} from '../Commons/inputs'

export default props => {
  const { users } = props.data
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
          <SelectInput label='Receiving Staff Member' collections={userLists} />
        </div>
      </div>

      <div className='row'>
        <div className='col-xs-8'>
          <DateInput label='Date of Referral' />
        </div>
      </div>

      <div className='row'>
        <div className='col-xs-8'>
          <SelectInput label='Case Worker / Assigned Staff Memger' isMulti collections={userLists} />
        </div>
      </div>

      <div className='row'>
        <div className='col-xs-8'>
          <SelectInput label='First Follow Up by' collections={userLists} />
        </div>
      </div>

      <div className='row'>
        <div className='col-xs-8'>
          <DateInput label='Date of First Follow Up' collections={userLists} />
        </div>
      </div>
    </>
  )
}
