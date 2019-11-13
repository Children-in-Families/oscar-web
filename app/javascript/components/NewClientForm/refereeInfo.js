import React       from 'react'
import {
  SelectInput,
  TextInput,
  Checkbox,
  CheckBoxUpload
}                   from '../Commons/inputs'

export default props => {
  const { onChangeText, onChangeSelect, onChangeDate, data: { client, birthProvinces } } = props

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
            <Checkbox label="Anonymous Referee" />
          </div>
        </div>
      </legend>

      <div className="row">
        <div className=" col-xs-3">
          <TextInput required label="Name" />
        </div>
        <div className="col-xs-3">
          <SelectInput label="Gender" collections={genderLists} onChangeSelect={onChangeSelect} name='gender' />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-3">
          <TextInput label="Referee Phone Number" />
        </div>
        <div className="col-xs-3">
          <TextInput label="Referee Email Address" />
        </div>
        <div className="col-xs-3">
          <SelectInput required label="Referral Source Catgeory" collections={blank} onChangeSelect={onChangeSelect} />
        </div>
        <div className="col-xs-3">
          <SelectInput required label="Referral Source" collections={blank} />
        </div>
      </div>
      <legend>
        <div className="row">
          <div className="col-xs-3">
            <p>Address</p>
          </div>
          <div className="col-xs-3">
            <Checkbox label="Outside Cambodia"/>
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
          <SelectInput label="Address Type" collections={addressType} />
        </div>
      </div>
    </div>
  )
}
