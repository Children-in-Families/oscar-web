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
      <div className="row">
        <div className="col-xs-3">
          <TextInput label="Name" onChange={onChange('referee', 'name')} />
        </div>
        <div className="col-xs-3">
          <SelectInput label="Gender" options={genderLists} onChange={onChange('referee', 'gender')} />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-3">
          <TextInput label="Carer Phone Number" onChange={onChange('referee', 'carer_phone_number')} />
        </div>
        <div className="col-xs-3">
          <TextInput label="Carer Email Address" onChange={onChange('referee', 'carer_email')} />
        </div>
        <div className="col-xs-3">
          <SelectInput label="Relationship to Client" options={blank} onChange={onChange('referee', 'relationship_client')} />
        </div>
        <div className="col-xs-3">
          <SelectInput label="Carer Phone Number" options={blank} onChange={onChange('referee', 'carer_phone_number')} />
        </div>
      </div>
      <legend>
        <div className="row">
          <div className="col-xs-3">
            <p>Address</p>
          </div>
          <div className="col-xs-3">
            <Checkbox label="Same as Client" onChange={onChange('referee', 'same_client')} />
          </div>
          <div className="col-xs-3">
            <Checkbox label="Outside Cambodia" onChange={onChange('referee', 'outside_cambodia')} />
          </div>
        </div>
      </legend>
      <div className="row">
        <div className="col-xs-3">
          <SelectInput label="Province" options={birthProvincesLists} onChange={onChange('referee', 'province_id')} />
        </div>
        <div className="col-xs-3">
          <SelectInput label="District / Khan" options={blank} onChange={onChange('referee', 'district_id')} />
        </div>
        <div className="col-xs-3">
          <SelectInput label="Commune / Sangkat" options={blank} onChange={onChange('referee', 'commune_id')} />
        </div>
        <div className="col-xs-3">
          <SelectInput label="Village" options={blank} onChange={onChange('referee', 'village_id')} />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-3">
          <TextInput label="Street Number" onChange={onChange('referee', 'street_number')} />
        </div>
        <div className="col-xs-3">
          <TextInput label="House Number" onChange={onChange('referee', 'house_number')} />
        </div>
        <div className="col-xs-3">
          <TextInput label="Address Name" onChange={onChange('referee', 'address_name')} />
        </div>
        <div className="col-xs-3">
          <SelectInput label="Address Type" options={blank} onChange={onChange('referee', 'address_type')} />
        </div>
      </div>
    </div>
  )
}
