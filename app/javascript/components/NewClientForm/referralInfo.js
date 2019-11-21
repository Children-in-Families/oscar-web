import React       from 'react'
import {
  SelectInput,
  DateInput,
  TextInput,
  Checkbox
}                   from '../Commons/inputs'

export default props => {
  const { onChange, data: { birthProvinces, errorFields } } = props
  const blank = []
  const rateLists = [{label: '1', value: 1}, {label: '2', value: 2}, {label: '3', value: 3}, {label: '4', value: 4}]
  const genderLists = [{label: 'Female', value: 'female'}, {label: 'Male', value: 'male'}, {label: 'Other', value: 'other'}, {label: 'Unknown', value: 'unknown'}]
  const addressType = [{label: 'Floor', value: 'floor'}, {label: 'Building', value: 'building'}, {label: 'Office', value: 'office'}]
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
            <Checkbox label="Client is outside Cambodia" onChange={onChange('referee', 'client_outside_cambodia')}/>
          </div>
        </div>
      </legend>
      <div className="row">
        <div className="col-xs-3">
          <SelectInput
            asGroup
            label="Province"
            options={birthProvincesLists}
            onChange={onChange('client', 'province_id')}
            id='client_province_id'
            data-type='provinces'
            data-subaddress='district'
          />
        </div>
        <div className="col-xs-3">
          <SelectInput
            label="District / Khan"
            options={blank}
            onChange={onChange('client', 'district_id')}
            id='client_district_id'
            data-type='districts'
            data-subaddress='commune'
          />
        </div>
        <div className="col-xs-3">
          <SelectInput label="Commune / Sangkat" options={blank} onChange={onChange('client', 'commune_id')} />
        </div>
        <div className="col-xs-3">
          <SelectInput label="Village" options={blank} onChange={onChange('client', 'village_id')} />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-3">
          <TextInput label="Street Number" onChange={onChange('client', 'street_number')} />
        </div>
        <div className="col-xs-3">
          <TextInput label="House Number" onChange={onChange('client', 'house_number')} />
        </div>
        <div className="col-xs-3">
          <TextInput label="Address Name" onChange={onChange('client', 'current_address')} />
        </div>
        <div className="col-xs-3">
          <SelectInput label="Address Type" options={addressType} onChange={onChange('referee', 'address_type')}/>
        </div>
      </div>
      <div className="row">
        <div className="col-xs-3">
          <TextInput label="What3Words" onChange={onChange('client', 'what3words')} />
        </div>
        <div className="col-xs-3">
          <TextInput label="Client Contact Phone" onChange={onChange('client', 'telephone_number')} />
        </div>
        <div className="col-xs-3">
          <SelectInput label="Phone Owner" options={blank} />
        </div>
        <div className="col-xs-3">
          <TextInput label="Client Email Address" />
        </div>
      </div>
    </div>
  )
}
