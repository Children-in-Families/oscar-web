import React        from 'react'
import {
  SelectInput,
  DateInput,
  TextInput
}                   from '../../Commons/inputs'
import styles       from './styles'

export default props => {
  const { step, data: { client, users, birth_provinces, referral_source, referral_source_category}, translations } = props

  const name = []
  const phoneNumber = []
  const userLists = users.map(user => [user.first_name + ' ' + user.last_name, user.id])
  const genderLists = [ ['Female', 'female'], ['Male', 'male'], ['Other', 'other'], ['Unknown', 'unknown'] ]
  const provinces = [ ["Cambodia", [["Burmese", 52]]], ["Thai", [["Hello", 12]]] ]


  return (
    step === 1 &&
    <div className="container">
      <legend>Referee Information</legend>
      <div className="row">
        <div className=" col-xs-12 col-sm-6 col-md-3">
          <TextInput required label="Name" collections={name}/>
        </div>
        <div className=" col-xs-12 col-sm-6 col-md-3">
          <SelectInput required label="Gender" collections={genderLists} />
        </div>
        <div className=" col-xs-12 col-sm-6 col-md-3">
          <TextInput label="Referee ID" collections={genderLists} />
        </div>
        <div className=" col-xs-12 col-sm-6 col-md-3">
          <TextInput label="Referee Phone Number" collections={phoneNumber} />
        </div>
        <div className=" col-xs-12 col-sm-6 col-md-3">
          <TextInput label="Referee Email Address" collections={name} />
        </div>
        <div className=" col-xs-12 col-sm-6 col-md-3">
          <SelectInput required label= "Referral Source Catgeory" collections={name} />
        </div>
        <div className=" col-xs-12 col-sm-6 col-md-3">
          <SelectInput required label="Referral Source" collections={name} />
        </div>
      </div>
      <legend>Address</legend>
      <div className="row">
        <div className=" col-xs-12 col-sm-6 col-md-3">
          <SelectInput required label="Province" collections={provinces} />
        </div>
        <div className=" col-xs-12 col-sm-6 col-md-3">
          <SelectInput label="District / Khan" collections={genderLists} />
        </div>
        <div className=" col-xs-12 col-sm-6 col-md-3">
          <SelectInput label="Commune / Sangkat" collections={phoneNumber} />
        </div>
        <div className=" col-xs-12 col-sm-6 col-md-3">
          <SelectInput label="Village" collections={name} />
        </div>
        <div className=" col-xs-12 col-sm-6 col-md-3">
          <TextInput label="Street Number" collections={name} />
        </div>
        <div className=" col-xs-12 col-sm-6 col-md-3">
          <TextInput label="House Number" collections={name} />
        </div>
        <div className=" col-xs-12 col-sm-6 col-md-3">
          <TextInput label="Address Name" collections={name} />
        </div>
        <div className=" col-xs-12 col-sm-6 col-md-3">
          <SelectInput label="Address Type" collections={name} />
        </div>
      </div>
    </div>
  )
}
