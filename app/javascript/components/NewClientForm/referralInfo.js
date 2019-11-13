import React       from 'react'
import {
  SelectInput,
  DateInput,
  TextInput,
  Checkbox
}                   from '../Commons/inputs'

export default props => {
  const { onChangeText, onChangeSelect, onChangeDate, data: { birthProvinces } } = props

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
          <TextInput required label="Given Name (Latin)" onChange={onChangeText('given_name')} />
        </div>
        <div className="col-xs-3">
          <TextInput required label="Family Name (Latin)" onChange={onChangeText('family_name')} />
        </div>
        <div className="col-xs-3">
          <TextInput label="Given Name(Khmer)" onChange={onChangeText('local_given_name')} />
        </div>
        <div className="col-xs-3">
          <TextInput label="Family Name (Khmer)" onChange={onChangeText('local_family_name')}  />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-3">
          <SelectInput label="Gender" collections={genderLists} onChangeSelect={onChangeSelect} name='gender' />
        </div>
        <div className="col-xs-3">
          <DateInput required label="Date of Birth" onChangeDate={onChangeDate} name='date_of_birth' />
        </div>
        <div className="col-xs-3">
          <SelectInput required label="Birth Province" asGroup collections={birthProvincesLists} onChangeSelect={onChangeSelect} name='birth_province_id' />
        </div>
        <div className="col-xs-3">
          <SelectInput required label="Is client rated for ID Poor?" collections={rateLists} onChangeSelect={onChangeSelect} name='rated_for_id_poor' />
        </div>
      </div>
      <legend>
        <div className="row">
          <div className="col-xs-3">
            <p>Contact Information</p>
          </div>
          <div className="col-xs-6">
            <Checkbox label="Client is outside Cambodia"/>
          </div>
        </div>
      </legend>
      <div className="row">
        <div className="col-xs-3">
          <SelectInput required label="Province" asGroup collections={birthProvincesLists} onChangeSelect={onChangeSelect} name='province_id' />
        </div>
        <div className="col-xs-3">
          <SelectInput label="District / Khan" collections={blank} onChangeSelect={onChangeSelect} name='district_id' />
        </div>
        <div className="col-xs-3">
          <SelectInput label="Commune / Sangkat" collections={blank} onChangeSelect={onChangeSelect} name='commune_id'/>
        </div>
        <div className="col-xs-3">
          <SelectInput label="Village" collections={blank} onChangeSelect={onChangeSelect} name='village_id' />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-3">
          <TextInput label="Street Number" onChange={onChangeText('street_number')} />
        </div>
        <div className="col-xs-3">
          <TextInput label="House Number" onChange={onChangeText('house_number')} />
        </div>
        <div className="col-xs-3">
          <TextInput label="Address Name" onChange={onChangeText('current_address')} />
        </div>
        <div className="col-xs-3">
          <SelectInput required label="Address Type" collections={addressType} />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-3">
          <TextInput label="What3Words" onChange={onChangeText('what3words')} />
        </div>
        <div className="col-xs-3">
          <TextInput required label="Client Contact Phone" onChange={onChangeText('telephone_number')} />
        </div>
        <div className="col-xs-3">
          <SelectInput required label="Phone Owner" collections={blank} />
        </div>
        <div className="col-xs-3">
          <TextInput required label="Client Email Address" />
        </div>
      </div>
    </div>
  )
}
