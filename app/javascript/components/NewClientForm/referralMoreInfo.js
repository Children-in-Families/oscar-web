import React from 'react'
import {
  SelectInput,
  TextInput,
  DateInput,
  Checkbox
} from '../Commons/inputs'
import styles from './styles'
import checkbox from '../Commons/inputs/checkbox'

export default props => {
  const { data: { client, users, birth_provinces, referral_source, referral_source_category }, translations } = props

  const blank = []
  const genderLists = [['Female', 'female'], ['Male', 'male'], ['Other', 'other'], ['Unknown', 'unknown']]
  const provinces = [["Cambodia", [["Burmese", 52]]], ["Thai", [["Hello", 12]]]]

  return (
    <div className="container">
      <legend>Client / Referral - More Information</legend>
      <div className="row">
        <div className="col-xs-4">
        <label>Do you want to add: </label>
        </div>
      </div>
      <div className="row">
        <div className="col-xs-10">
          <label data-toggle="collapse" data-target="#careInfo">
            Carer Information?
          </label>
        </div>
      </div>
      <div id="careInfo" className="collapse">
        <div className="row">
          <div className="col-xs-3">
            <TextInput required label="Name"/>
          </div>
          <div className="col-xs-3">
            <SelectInput required label="Gender" collections={ genderLists } />
          </div>
        </div>
        <div className="row">
          <div className="col-xs-3">
            <TextInput label="Carer Phone Number"/>
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
              <Checkbox label="Same as Client"/>
            </div>
            <div className="col-xs-3">
              <Checkbox label="Outside Cambodia" />
            </div>
          </div>
        </legend>
        <div className="row">
          <div className="col-xs-3">
            <SelectInput label="Province" collections={provinces}/>
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
            <SelectInput label="Street Number" collections={blank}/>
          </div>
        </div>
      </div>
      <div className="row">
        <div className="col-xs-10">
          <label>
            School Information?
        </label>
        </div>
        <div className="col-xs-10">
          <label>
            Donor Information?
        </label>
        </div>
        <div className="col-xs-10">
          <label>
            Custom ID Information?
        </label>
        </div>
      </div>
    </div>
  )
}
