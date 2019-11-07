import React       from 'react'
import {
  SelectInput,
  TextInput,
  Checkbox,
  CheckBoxUpload
}                   from '../Commons/inputs'

export default props => {
  const { onChangeText, data: { client, birthProvinces } } = props

  const blank = []
  const genderLists = [['Female', 'female'], ['Male', 'male'], ['Other', 'other'], ['Unknown', 'unknown']]
  const addressType = [['Floor', 'floor'], ['Building', 'building'], ['Office', 'office']]

  return (
    <div className="container">
      <legend>Referee Information</legend>
      <div className="row">
        <div className="col-xs-3">
          <Checkbox label="Anonymous Referee" />
        </div>
      </div>
      <div className="row">
        <div className=" col-xs-3">
          <TextInput required label="Name" onChange={onChangeText(client, 'given_name')} />
        </div>
        <div className="col-xs-3">
          <SelectInput label="Gender" collections={ genderLists } />
        </div>
        <div className="col-xs-3">
          <label>Referee ID</label>
          <p>ref-xyrf-0987</p>
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
          <SelectInput required label="Referral Source Catgeory" collections={blank} />
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
          <SelectInput required label="Province" asGroup collections={birthProvinces} />
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
