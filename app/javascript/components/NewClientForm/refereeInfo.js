import React, { useState, useEffect }       from 'react'
import {
  SelectInput,
  TextInput,
  Checkbox
}                   from '../Commons/inputs'
import Address      from './address'

export default props => {
  const { onChange, data: { referee, client, currentProvinces, referralSourceCategory, referralSource, currentDistricts, currentCommunes, currentVillages, birthProvinces, errorFields} } = props

  const genderLists = [{label: 'Female', value: 'female'}, {label: 'Male', value: 'male'}, {label: 'Other', value: 'other'}, {label: 'Unknown', value: 'unknown'}]
  const referralSourceCategoryLists = referralSourceCategory.map(catgeory => ({label: catgeory[0], value: catgeory[1]}))

  return (
    <div className="container">
      <legend>
        <div className="row">
          <div className="col-xs-3">
            <p>Referee Information</p>
          </div>
        </div>
      </legend>

      <div className="row">
        <div className="col-xs-3">
          <Checkbox label="Anonymous Referee" checked={referee.anonymous || false} onChange={onChange('referee', 'anonymous')} />
        </div>
      </div>
      <br/>
      <div className="row">
        <div className=" col-xs-3">
          <TextInput
            required
            // isError={errorFields.includes('referee_name')}
            isError={errorFields.includes('name_of_referee')}
            value={client.name_of_referee}
            label="Name"
            // onChange={onChange('referee', 'referee_name')}
            onChange={onChange('client', 'name_of_referee')}
          />
        </div>
        <div className="col-xs-3">
          <SelectInput label="Gender" options={genderLists} onChange={onChange('referee', 'gender')} value={referee.gender} />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-3">
          <TextInput label="Referee Phone Number" onChange={onChange('client', 'referral_phone')} value={client.referral_phone} />
        </div>
        <div className="col-xs-3">
          <TextInput label="Referee Email Address" onChange={onChange('referee', 'email')} value={referee.email} />
        </div>
        <div className="col-xs-3">
          <SelectInput
            required
            isError={errorFields.includes('referral_source_category_id')}
            label="Referral Source Catgeory"
            options={referralSourceCategoryLists}
            value={client.referral_source_category_id}
            onChange={onChange('client', 'referral_source_category_id')}
          />
        </div>
        <div className="col-xs-3">
          <SelectInput options={[]} label="Referral Source" onChange={onChange('client', 'referral_source_id')} value={client.referral_source_id} />
        </div>
      </div>
      <legend>
        <div className="row">
          <div className="col-xs-3">
            <p>Address</p>
          </div>
          <div className="col-xs-3">
            <Checkbox label="Outside Cambodia" checked={referee.outside || false} onChange={onChange('referee', 'outside')} />
          </div>
        </div>
      </legend>

      <Address outside={referee.outside || false} onChange={onChange} data={{currentDistricts, currentCommunes, currentVillages, currentProvinces, objectKey: 'referee', objectData: referee}} />
    </div>
  )
}
