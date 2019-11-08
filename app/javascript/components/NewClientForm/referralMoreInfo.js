import React from 'react'
import {
  SelectInput,
  TextInput,
  DateInput,
  Checkbox
} from '../Commons/inputs'
import styles from './styles'
import CareInfo from './carerInfo'

export default props => {
  const { data: { client, users, birth_provinces, referral_source, referral_source_category }, translations } = props

  const blank = []
  const genderLists = [['Female', 'female'], ['Male', 'male'], ['Other', 'other'], ['Unknown', 'unknown']]
  const provinces = [["Cambodia", [["Burmese", 52]]], ["Thai", [["Hello", 12]]]]

  return (
    <div className="container">
      <legend>
        <div className="row">
          <div className="col-xs-4">
            <p>Client / Referral - More Information</p>
          </div>
        </div>
      </legend>

      <div className="row">
        <div className="col-xs-4">
        <label>Do you want to add: </label>
        </div>
      </div>
      <br/>
      <div className="row">
        <div className="careInfo">
          <div className="col-xs-10 collapsed" data-toggle="collapse" data-target="#careInfo">
            <label className="makeSpaceCare">Carer Information?</label>
            <span className="pointer">
              <i className="fa fa-chevron-up"></i>
              <i className="fa fa-chevron-down"></i>
            </span>
          </div>
        </div>
      </div>
      <CareInfo id="careInfo"/>
      <hr/>
      <div className="row">
        <div className="col-xs-10">
          <label className="makeSpaceSchool">School Information?</label>
          <span className="pointer">
            <i className="fa fa-chevron-down"></i>
          </span>
        </div>
      </div>
      <hr/>
      <div className="row">
        <div className="col-xs-10">
          <label className="makeSpaceDonor">Donor Information?</label>
          <span className="pointer">
            <i className="fa fa-chevron-down"></i>
          </span>
        </div>
      </div>
      <hr/>
      <div className="row">
        <div className="col-xs-10">
          <label className="makeSpaceCustom">Custom ID Information?</label>
          <span className="pointer">
            <i className="fa fa-chevron-down"></i>
          </span>
        </div>
      </div>
      <hr/>
    </div>
  )
}
