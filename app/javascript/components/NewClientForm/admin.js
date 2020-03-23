import React, { useState } from 'react'
import {
  SelectInput,
  DateInput
} from '../Commons/inputs'

export default props => {
  const { onChange, translation, data: { users, client, errorFields, T } } = props
  const userLists = users.map(user => ({label: user[0], value: user[1], isFixed: user[2] === 'locked' ? true : false }))

  return (
    <>
      <legend className='legend'>
        <div className="row">
          <div className="col-md-12 col-lg-9">
            <p>{T.translate("admin.admin_information")}</p>
          </div>
        </div>
      </legend>

      <div className='row'>
        <div className='col-md-12 col-lg-9'>
          <SelectInput
            T={T}
            required
            isError={errorFields.includes('received_by_id')}
            label={T.translate("admin.receiving_staff")}
            options={userLists}
            value={client.received_by_id}
            onChange={onChange('client', 'received_by_id')} />
        </div>
      </div>

      <div className='row'>
        <div className='col-md-12 col-lg-9'>
          <DateInput
            T={T}
            required
            isError={errorFields.includes('initial_referral_date')}
            label={translation.clients.form.initial_referral_date}
            value={client.initial_referral_date}
            onChange={onChange('client', 'initial_referral_date')} />
        </div>
      </div>

      <div className='row'>
        <div className='col-md-12 col-lg-9'>
          <SelectInput
            T={T}
            required
            isError={errorFields.includes('user_ids')}
            label={translation.clients.form.user_ids}
            isMulti
            options={userLists}
            value={client.user_ids}
            onChange={onChange('client','user_ids')} />
        </div>
      </div>

      <div className='row'>
        <div className='col-md-12 col-lg-9'>
          <SelectInput label={T.translate("admin.first_follow_by")} options={userLists} onChange={onChange('client', 'followed_up_by_id')} value={client.followed_up_by_id} />
        </div>
      </div>

      <div className='row'>
        <div className='col-md-12 col-lg-9'>
          <DateInput label={T.translate("admin.first_follow_date")} onChange={onChange('client','follow_up_date')} value={client.follow_up_date} />
        </div>
      </div>
    </>
  )
}
