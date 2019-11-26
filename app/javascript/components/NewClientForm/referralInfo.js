import React       from 'react'
import {
  SelectInput,
  DateInput,
  TextInput,
  Checkbox
}                   from '../Commons/inputs'
import Address from './address'

export default props => {
  const { onChange, data: { client, birthProvinces, currentProvinces, errorFields, ratePoor } } = props

  const blank = []
  const rateLists = ratePoor.map(rate => ({ label: rate[0], value: rate[1] }))
  const genderLists = [{label: 'Female', value: 'female'}, {label: 'Male', value: 'male'}, {label: 'Other', value: 'other'}, {label: 'Unknown', value: 'unknown'}]
  const birthProvincesLists = birthProvinces.map(province => ({label: province[0], options: province[1].map(value => ({label: value[0], value: value[1]}))}))

  return (
    <div className="container">
      <legend>
        <div className="row">
          <div className="col-xs-4">
            <p>Client / Referral Information</p>
          </div>
        </div>
      </legend>

      <div className="row">
        <div className="col-xs-3">
          <TextInput label="Given Name (Latin)" onChange={onChange('client', 'given_name')} />
        </div>
        <div className="col-xs-3">
          <TextInput label="Family Name (Latin)" onChange={onChange('client', 'family_name')} />
        </div>
        <div className="col-xs-3">
          <TextInput label="Given Name(Khmer)" onChange={onChange('client', 'local_given_name')} />
        </div>
        <div className="col-xs-3">
          <TextInput label="Family Name (Khmer)" onChange={onChange('client', 'local_family_name')}  />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-3">
          <SelectInput
            required
            isError={errorFields.includes('gender')}
            label="Gender"
            options={genderLists}
            onChange={onChange('client', 'gender')}
          />
        </div>
        <div className="col-xs-3">
          <DateInput label="Date of Birth" onChange={onChange('client', 'date_of_birth')} />
        </div>
        <div className="col-xs-3">
          <SelectInput
            asGroup
            label="Birth Province"
            options={birthProvincesLists}
            onChange={onChange('client', 'birth_province_id')}
          />
        </div>
        <div className="col-xs-3">
          <SelectInput label="Is client rated for ID Poor?" options={rateLists} onChange={onChange('client', 'rated_for_id_poor')} />
        </div>
      </div>
      <legend>
        <div className="row">
          <div className="col-xs-3">
            <p>Contact Information</p>
          </div>
          <div className="col-xs-6">
            <Checkbox label="Client is outside Cambodia" onChange={onChange('referee', 'outside_client')}/>
          </div>
        </div>
      </legend>
      <Address onChange={onChange} data={{ currentProvinces, client }} />
      <div className="row">
        <div className="col-xs-3">
          <TextInput label="What3Words" onChange={onChange('client', 'what3words')} />
        </div>
        <div className="col-xs-3">
          <TextInput label="Client Contact Phone" onChange={onChange('client', 'telephone_number')} />
        </div>
        <div className="col-xs-3">
          <SelectInput label="Phone Owner" options={blank} onChange={onChange('client', 'owner_phone')}/>
        </div>
        <div className="col-xs-3">
          <TextInput label="Client Email Address" onChange={onChange('client', 'email_address')} />
        </div>
      </div>
    </div>
  )
}
