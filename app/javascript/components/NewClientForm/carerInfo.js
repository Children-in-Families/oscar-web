import React from 'react'
import {
  SelectInput,
  TextInput,
  Checkbox
}             from '../Commons/inputs'

export default props => {
  const { id, data: { birthProvinces } } = props
  const blank = []
  const genderLists = [{label: 'Female', value: 'female'}, {label: 'Male', value: 'male'}, {label: 'Other', value: 'other'}, {label: 'Unknown', value: 'unknown'}]
  const birthProvincesLists = birthProvinces.map(province => ({label: province[0], options: province[1].map(value => ({label: value[0], value: value[1]}))}))

  return (
    <div id={id} className="collapse">
      <div className="row">
        <div className="col-xs-3">
          <TextInput required label="Name" />
        </div>
        <div className="col-xs-3">
          <SelectInput required label="Gender" collections={genderLists} />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-3">
          <TextInput label="Carer Phone Number" />
        </div>
        <div className="col-xs-3">
          <TextInput label="Carer Email Address" />
        </div>
        <div className="col-xs-3">
          <SelectInput label="Relationship to Client" collections={blank} />
        </div>
        <div className="col-xs-3">
          <SelectInput label="Carer Phone Number" collections={blank} />
        </div>
      </div>
      <legend>
        <div className="row">
          <div className="col-xs-3">
            <p>Address</p>
          </div>
          <div className="col-xs-3">
            <Checkbox label="Same as Client" />
          </div>
          <div className="col-xs-3">
            <Checkbox label="Outside Cambodia" />
          </div>
        </div>
      </legend>
      <div className="row">
        <div className="col-xs-3">
          <SelectInput label="Province" collections={birthProvincesLists} />
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
          <TextInput label="Street Number" />
        </div>
        <div className="col-xs-3">
          <TextInput label="Street Number" />
        </div>
        <div className="col-xs-3">
          <SelectInput label="Street Number" collections={blank} />
        </div>
      </div>
    </div>
  )
}
