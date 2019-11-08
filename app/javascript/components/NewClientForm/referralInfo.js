import React       from 'react'
import {
  SelectInput,
  DateInput,
  TextInput,
  Checkbox
}                   from '../Commons/inputs'

export default props => {
  const { onChangeText, data: { birthProvinces } } = props

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
          <SelectInput label="Gender" collections={genderLists} onChange={onChangeText('gender')}  />
        </div>
        <div className="col-xs-3">
          <DateInput required label="Date of Birth" />
        </div>
        <div className="col-xs-3">
          <SelectInput required label="Birth Province" asGroup collections={birthProvincesLists} />
        </div>
        <div className="col-xs-3">
          <SelectInput required label="Is client rated for ID Poor?" collections={rateLists} />
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
          <SelectInput required label="Province" asGroup collections={birthProvincesLists} />
        </div>
        <div className="col-xs-3">
          <SelectInput label="District / Khan" collections={blank} />
        </div>
        <div className="col-xs-3">
          <SelectInput label="Commune / Sangkat" collections={blank} />
        </div>
        <div className="col-xs-3">
          <SelectInput label="Village" collections={blank} />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-3">
          <TextInput label="Street Number" />
        </div>
        <div className="col-xs-3">
          <TextInput label="House Number" />
        </div>
        <div className="col-xs-3">
          <TextInput label="Address Name" />
        </div>
        <div className="col-xs-3">
          <SelectInput required label="Address Type" collections={addressType} />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-3">
          <TextInput label="What3Words" />
        </div>
        <div className="col-xs-3">
          <TextInput required label="Client Contact Phone" />
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
