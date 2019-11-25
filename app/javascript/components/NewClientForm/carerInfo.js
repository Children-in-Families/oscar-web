import React from 'react'
import {
  SelectInput,
  TextInput,
  Checkbox
}             from '../Commons/inputs'

export default props => {
  const { onChange, id, data: { birthProvinces } } = props
  const blank = []
  const genderLists = [{label: 'Female', value: 'female'}, {label: 'Male', value: 'male'}, {label: 'Other', value: 'other'}, {label: 'Unknown', value: 'unknown'}]
  const birthProvincesLists = birthProvinces.map(province => ({label: province[0], options: province[1].map(value => ({label: value[0], value: value[1]}))}))

  return (
    <div id={id} className="collapse">
      <br/>
      <div className="row">
        <div className="col-xs-3">
          <TextInput label="Name" onChange={onChange('client', 'gov_carer_name')} />
        </div>
        <div className="col-xs-3">
          <SelectInput label="Gender" options={genderLists} onChange={onChange('client', 'gov_carer_gender')} />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-3">
          <TextInput label="Carer Phone Number" onChange={onChange('client', 'gov_carer_phone')} />
        </div>
        <div className="col-xs-3">
          <TextInput label="Carer Email Address" onChange={onChange('client', 'gov_carer_email')} />
        </div>
        <div className="col-xs-3">
          <SelectInput label="Relationship to Client" options={blank} onChange={onChange('client', 'gov_carer_relationship')} />
        </div>
        <div className="col-xs-3">
          <SelectInput label="Family Record" options={blank} onChange={onChange('client', 'family_name')} />
        </div>
      </div>
      <legend>
        <div className="row">
          <div className="col-xs-3">
            <p>Address</p>
          </div>
          <div className="col-xs-3">
            <Checkbox label="Same as Client" onChange={onChange('client', 'same_client')} />
          </div>
          <div className="col-xs-3">
            <Checkbox label="Outside Cambodia" onChange={onChange('client', 'outside_cambodia')} />
          </div>
        </div>
      </legend>
      <div className="row">
        <div className="col-xs-3">
          <SelectInput label="Province" options={birthProvincesLists} onChange={onChange('client', 'gov_carer_city')} />
        </div>
        <div className="col-xs-3">
          <SelectInput label="District / Khan" options={blank} onChange={onChange('client', 'gov_carer_district')} />
        </div>
        <div className="col-xs-3">
          <SelectInput label="Commune / Sangkat" options={blank} onChange={onChange('client', 'gov_carer_commune')} />
        </div>
        <div className="col-xs-3">
          <SelectInput label="Village" options={blank} onChange={onChange('client', 'gov_carer_village')} />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-3">
          <TextInput label="Street Number" onChange={onChange('client', 'gov_carer_street')} />
        </div>
        <div className="col-xs-3">
          <TextInput label="House Number" onChange={onChange('client', 'gov_carer_home')} />
        </div>
        <div className="col-xs-3">
          <TextInput label="Address Name" onChange={onChange('client', 'address_name')} />
        </div>
        <div className="col-xs-3">
          <SelectInput label="Address Type" options={blank} onChange={onChange('client', 'address_type')} />
        </div>
      </div>
    </div>
  )
}
