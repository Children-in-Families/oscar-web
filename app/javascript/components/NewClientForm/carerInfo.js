import React from 'react'
import {
  SelectInput,
  TextInput,
  Checkbox
}             from '../Commons/inputs'
import styles from './styles'

export default props => {

  const blank = []
  const genderLists = [['Female', 'female'], ['Male', 'male'], ['Other', 'other'], ['Unknown', 'unknown']]
  const provinces = [["Cambodia", [["Burmese", 52]]], ["Thai", [["Hello", 12]]]]

  return (
    <div id={props.id} className="collapse">
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
          <SelectInput label="Province" collections={provinces} />
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
