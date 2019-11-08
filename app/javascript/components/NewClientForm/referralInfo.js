import React       from 'react'
import {
  SelectInput,
  DateInput,
  TextInput,
  Checkbox
}                   from '../Commons/inputs'

export default props => {
  const { data: { client, users, birth_provinces, referral_source, referral_source_category}, translations } = props

  const blank = []
  const userLists = users.map(user => [user.first_name + ' ' + user.last_name, user.id])
  const genderLists = [ ['Female', 'female'], ['Male', 'male'], ['Other', 'other'], ['Unknown', 'unknown'] ]
  const provinces = [ ["Cambodia", [["Burmese", 52]]], ["Thai", [["Hello", 12]]] ]
  const rate = [ [1], [2], [3], [4] ]
  const addressType = [ ['Floor'], ['Building'], ['Office'] ]

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
          <TextInput required label="Given Name (Latin)" />
        </div>
        <div className="col-xs-3">
          <TextInput required label="Family Name (Latin)" />
        </div>
        <div className="col-xs-3">
          <TextInput label="Given Name(Khmer)" />
        </div>
        <div className="col-xs-3">
          <TextInput label="Family Name (Khmer)" />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-3">
          <SelectInput label="Gender" collections={genderLists} />
        </div>
        <div className="col-xs-3">
          <DateInput required label="Date of Birth" />
        </div>
        <div className="col-xs-3">
          <SelectInput required label="Birth Province" collections={provinces} />
        </div>
        <div className="col-xs-3">
          <SelectInput required label="Is client rated for ID Poor?" collections={rate} />
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
          <SelectInput required label="Province" asGroup collections={provinces} />
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
