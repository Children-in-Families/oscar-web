import React, { useState }       from 'react'
import {
  SelectInput,
  TextInput,
  Checkbox
}                   from '../Commons/inputs'
import Address from './address';

export default props => {
  const { onChange, data: { client, referralSourceCategory, referralSource, currentProvinces, district, commune, village, errorFields} } = props

  const [checked, setCheckBox] = useState(false)
  const genderLists = [{label: 'Female', value: 'female'}, {label: 'Male', value: 'male'}, {label: 'Other', value: 'other'}, {label: 'Unknown', value: 'unknown'}]
  const referralSourceCategorLists = referralSourceCategory.map(cat => ({label: cat[0], value: cat[1]}))

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
          <Checkbox label="Anonymous Referee" onChange={onChange('client', 'anonymous_referee')} />
        </div>
      </div>
      <br/>
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
          <SelectInput label="Gender" options={genderLists} onChange={onChange('client', 'gender_of_referee')} />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-3">
          <TextInput label="Referee Phone Number" onChange={onChange('client', 'number_of_referee')} />
        </div>
        <div className="col-xs-3">
          <TextInput label="Referee Email Address" onChange={onChange('referee', 'email_of_referee')}/>
        </div>
        <div className="col-xs-3">
          <SelectInput
            required
            isError={errorFields.includes('referral_source_category_id')}
            options={referralSourceCategorLists}
            label="Referral Source Catgeory"
            onChange={onChange('client', 'referral_source_category_id')}
          />
        </div>
        <div className="col-xs-3">
          <SelectInput
            label="Referral Source"
            onChange={onChange('client', 'referral_source_id')}
          />
        </div>
      </div>
      <legend>
        <div className="row">
          <div className="col-xs-3">
            <p>Address</p>
          </div>
          <div className="col-xs-3">
            <Checkbox label="Outside Cambodia" setCheck={setCheckBox} onChange={onChange('client', 'outside_referee')} />
          </div>
        </div>
      </legend>
      <Address checked={checked} onChange={onChange} data={{ currentProvinces, client }} />
    </div>
  )
}
