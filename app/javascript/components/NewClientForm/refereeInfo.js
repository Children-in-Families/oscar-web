import React       from 'react'
import {
  SelectInput,
  TextInput,
  Checkbox,
  CheckBoxUpload
}                   from '../Commons/inputs'

export default props => {
  const { onChange, data: { client, birthProvinces } } = props

  const blank = []
  const genderLists = [{label: 'Female', value: 'female'}, {label: 'Male', value: 'male'}, {label: 'Other', value: 'other'}, {label: 'Unknown', value: 'unknown'}]
  const addressType = [{label: 'Floor', value: 'floor'}, {label: 'Building', value: 'building'}, {label: 'Office', value: 'office'}]
  const birthProvincesLists = birthProvinces.map(province => ({label: province[0], options: province[1].map(value => ({label: value[0], value: value[1]}))}))

  return (
    <div className="container">
      <legend>
        <div className="row">
          <div className="col-xs-3">
            <p>Referee Information</p>
          </div>
          <div className="col-xs-3">
            <Checkbox label="Anonymous Referee" onChange={onChange('referee', 'anonymous_referee')}/>
          </div>
        </div>
      </legend>

      <div className="row">
        <div className=" col-xs-3">
          <TextInput required label="Name" onChange={onChange('referee', 'name')} />
        </div>
        <div className="col-xs-3">
          <SelectInput label="Gender" collections={genderLists} onChange={onChange('referee', 'gender')} />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-3">
          <TextInput label="Referee Phone Number" onChange={onChange('referee', 'phone')} />
        </div>
        <div className="col-xs-3">
          <TextInput label="Referee Email Address" onChange={onChange('referee', 'email')}/>
        </div>
        <div className="col-xs-3">
          <SelectInput required label="Referral Source Catgeory" collections={blank} onChange={onChange('referee', 'referral_source_category_id')} />
        </div>
        <div className="col-xs-3">
          <SelectInput required label="Referral Source" collections={blank} onChange={onChange('referee', 'referral_source_id')} />
        </div>
      </div>
      <legend>
        <div className="row">
          <div className="col-xs-3">
            <p>Address</p>
          </div>
          <div className="col-xs-3">
            <Checkbox label="Outside Cambodia" onChange={onChange('referee', 'outside_cambodia')} />
          </div>
        </div>
      </legend>
      <div className="row">
        <div className="col-xs-3">
          <SelectInput required label="Province" asGroup collections={birthProvincesLists} onChange={onChange('referee', 'province_id')} />
        </div>
        <div className="col-xs-3">
          <SelectInput label="District / Khan" collections={blank} onChange={onChange('referee', 'district_id')} />
        </div>
        <div className="col-xs-3">
          <SelectInput label="Commune / Sangkat" collections={blank} onChange={onChange('referee', 'commune_id')} />
        </div>
        <div className="col-xs-3">
          <SelectInput label="Village" collections={blank} onChange={onChange('referee', 'village_id')} />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-3">
          <TextInput label="Street Number" onChange={onChange('referee', 'street')} />
        </div>
        <div className="col-xs-3">
          <TextInput label="House Number" onChange={onChange('referee', 'house')} />
        </div>
        <div className="col-xs-3">
          <TextInput label="Address Name" onChange={onChange('referee', 'address')} />
        </div>
        <div className="col-xs-3">
          <SelectInput label="Address Type" collections={addressType}  onChange={onChange('referee', 'address_type')}/>
        </div>
      </div>
    </div>
  )
}
