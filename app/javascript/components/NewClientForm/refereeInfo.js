import React       from 'react'
import {
  SelectInput,
  TextInput,
  Checkbox
}                   from '../Commons/inputs'

export default props => {
  const { onChange, data: { client, birthProvinces, referralSourceCategory, referralSource, currentProvinces, district, commune, village, errorFields} } = props

  const blank = []
  const genderLists = [{label: 'Female', value: 'female'}, {label: 'Male', value: 'male'}, {label: 'Other', value: 'other'}, {label: 'Unknown', value: 'unknown'}]
  const addressType = [{label: 'Floor', value: 'floor'}, {label: 'Building', value: 'building'}, {label: 'Office', value: 'office'}]
  const birthProvincesLists = birthProvinces.map(province => ({label: province[0], options: province[1].map(value => ({label: value[0], value: value[1]}))}))
  const referralSourceCategorLists = referralSourceCategory.map(catgeory => ({label: catgeory[0], value: catgeory[1]}))
  const currentProvincesLists = currentProvinces.map(province => ({label: province.name, value: province.id}))

  return (
    <div className="container">
      <legend>
        <div className="row">
          <div className="col-xs-3">
            <p>Referee Information</p>
          </div>
          <div className="col-xs-3">
            <Checkbox label="Anonymous Referee" onChange={onChange('referee', 'referee_anonymous_referee')}/>
          </div>
        </div>
      </legend>

      <div className="row">
        <div className=" col-xs-3">
          <TextInput
            required
            // isError={errorFields.includes('referee_name')}
            isError={errorFields.includes('name_of_referee')}
            label="Name"
            // onChange={onChange('referee', 'referee_name')}
            onChange={onChange('client', 'name_of_referee')}
          />
        </div>
        <div className="col-xs-3">
          <SelectInput label="Gender" options={genderLists} onChange={onChange('referee', 'referee_gender')} />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-3">
          <TextInput label="Referee Phone Number" onChange={onChange('referee', 'referee_phone')} />
        </div>
        <div className="col-xs-3">
          <TextInput label="Referee Email Address" onChange={onChange('referee', 'referee_email')}/>
        </div>
        <div className="col-xs-3">
          <SelectInput
            required
            // isError={errorFields.includes('referee_referral_source_catgeory_id')}
            isError={errorFields.includes('referral_source_category_id')}
            label="Referral Source Catgeory"
            options={referralSourceCategorLists}
            // onChange={onChange('referee', 'referee_referral_source_catgeory_id')}
            onChange={onChange('client', 'referral_source_category_id')}
          />
        </div>
        <div className="col-xs-3">
          <SelectInput label="Referral Source" onChange={onChange('referee', 'referee_referral_source_id')} />
        </div>
      </div>
      <legend>
        <div className="row">
          <div className="col-xs-3">
            <p>Address</p>
          </div>
          <div className="col-xs-3">
            <Checkbox label="Outside Cambodia" onChange={onChange('referee', 'referee_outside_cambodia')} />
          </div>
        </div>
      </legend>
      <div className="row">
        <div className="col-xs-3">
          <SelectInput label="Province" asGroup options={currentProvincesLists} onChange={onChange('referee', 'referee_province_id')} />
        </div>
        <div className="col-xs-3">
          <SelectInput label="District / Khan" options={blank} onChange={onChange('referee', 'referee_district_id')} />
        </div>
        <div className="col-xs-3">
          <SelectInput label="Commune / Sangkat" options={blank} onChange={onChange('referee', 'referee_commune_id')} />
        </div>
        <div className="col-xs-3">
          <SelectInput label="Village" options={blank} onChange={onChange('referee', 'referee_village_id')} />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-3">
          <TextInput label="Street Number" onChange={onChange('referee', 'referee_street')} />
        </div>
        <div className="col-xs-3">
          <TextInput label="House Number" onChange={onChange('referee', 'referee_house')} />
        </div>
        <div className="col-xs-3">
          <TextInput label="Address Name" onChange={onChange('referee', 'referee_address')} />
        </div>
        <div className="col-xs-3">
          <SelectInput label="Address Type" options={addressType} onChange={onChange('referee', 'referee_address_type')}/>
        </div>
      </div>
    </div>
  )
}
