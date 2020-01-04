import React, { useEffect } from 'react'
import CareInfo from './carerInfo'
import SchoolInfo from './schoolInfo'
import DonorInfo from './donorInfo'
import CustomInfo from './customInfo'

export default props => {
  const { onChange, data: { carerDistricts, carerCommunes, carerVillages, carer, client, clientRelationships, currentProvinces, currentDistricts, currentCommunes, currentVillages, donors, agencies, schoolGrade, families, ratePoor, addressTypes, T } } = props

  return (
    <div className="containerClass">
      <legend>
        <div className="row">
          <div className="col-xs-5">
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

      <CareInfo id="careInfo" data={{ carer, client, clientRelationships, carerDistricts, carerCommunes, carerVillages, currentProvinces, currentDistricts, currentCommunes, currentVillages, families, addressTypes, T }} onChange={onChange} />

      <hr/>
      <div className="row">
        <div className="schoolInfo">
          <div className="col-xs-10 collapsed" data-toggle="collapse" data-target="#schoolInfo">
            <label className="makeSpaceSchool">School Information?</label>
            <span className="pointer">
              <i className="fa fa-chevron-up"></i>
              <i className="fa fa-chevron-down"></i>
            </span>
          </div>
        </div>
      </div>

      <SchoolInfo id="schoolInfo" data={{ client, schoolGrade, T }} onChange={onChange} />

      <hr/>
      <div className="row">
        <div className="donorInfo">
          <div className="col-xs-10 collapsed" data-toggle="collapse" data-target="#donorInfo">
            <label className="makeSpaceDonor">Donor Information?</label>
            <span className="pointer">
              <i className="fa fa-chevron-up"></i>
              <i className="fa fa-chevron-down"></i>
            </span>
          </div>
        </div>
      </div>

      <DonorInfo id="donorInfo" data={{ donors, agencies, client, T }} onChange={onChange} />

      <hr/>
      <div className="row">
        <div className="customInfo">
          <div className="col-xs-10 collapsed" data-toggle="collapse" data-target="#customInfo">
            <label className="makeSpaceCustom">Other Information</label>
            <span className="pointer">
              <i className="fa fa-chevron-up"></i>
              <i className="fa fa-chevron-down"></i>
            </span>
          </div>
        </div>
      </div>

      <CustomInfo id="customInfo" onChange={onChange} data={{ratePoor, client, T}} />
      <hr/>
    </div>
  )
}
