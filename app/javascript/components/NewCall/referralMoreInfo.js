import React, { useEffect } from 'react'
import CareInfo from './carerInfo'
import SchoolInfo from './schoolInfo'
import DonorInfo from './donorInfo'
import CustomInfo from './customInfo'
import { TextArea } from "../Commons/inputs";

export default props => {
  const { onChange, data: { call, carerDistricts, carerCommunes, carerVillages, carer, clients, clientRelationships, currentProvinces, currentDistricts, currentCommunes, currentVillages, donors, agencies, schoolGrade, families, ratePoor, addressTypes, phoneOwners, T } } = props

  return (
    <div className="containerClass">
      <legend>
        <div className="row">
          <div className="col-xs-5">
            <p>{T.translate("newCall.referralMoreInfo.client_referral_more_info")}</p>
          </div>
        </div>
      </legend>

      <div className="row">
        <div className="col-xs-4">
          <label>{T.translate("newCall.referralMoreInfo.do_you_want_to_add")}</label>
        </div>
      </div>
      <br/>

      <div className="row">
        <div className="careInfo">
          <div className="col-xs-10 collapsed" data-toggle="collapse" data-target="#careInfo">
            <label className="makeSpaceCare">{T.translate("newCall.referralMoreInfo.carer_info")}</label>
            <span className="pointer">
              <i className="fa fa-chevron-up"></i>
              <i className="fa fa-chevron-down"></i>
            </span>
          </div>
        </div>
      </div>

      <CareInfo id="careInfo" data={{ carer, clients, clientRelationships, carerDistricts, carerCommunes, carerVillages, currentProvinces, currentDistricts, currentCommunes, currentVillages, families, addressTypes, T }} onChange={onChange} />

      <hr/>
      <div className="row">
        <div className="schoolInfo">
          <div className="col-xs-10 collapsed" data-toggle="collapse" data-target="#schoolInfo">
            <label className="makeSpaceSchool">{T.translate("newCall.referralMoreInfo.school_info")}</label>
            <span className="pointer">
              <i className="fa fa-chevron-up"></i>
              <i className="fa fa-chevron-down"></i>
            </span>
          </div>
        </div>
      </div>

      <SchoolInfo id="schoolInfo" data={{ clients, schoolGrade, T }} onChange={onChange} />

      <hr/>
      <div className="row">
        <div className="donorInfo">
          <div className="col-xs-10 collapsed" data-toggle="collapse" data-target="#donorInfo">
            <label className="makeSpaceDonor">{T.translate("newCall.referralMoreInfo.donor_info")}</label>
            <span className="pointer">
              <i className="fa fa-chevron-up"></i>
              <i className="fa fa-chevron-down"></i>
            </span>
          </div>
        </div>
      </div>

      <DonorInfo id="donorInfo" data={{ donors, agencies, clients, T }} onChange={onChange} />

      <hr/>
      <div className="row">
        <div className="customInfo">
          <div className="col-xs-10 collapsed" data-toggle="collapse" data-target="#customInfo">
            <label className="makeSpaceCustom">{T.translate("newCall.referralMoreInfo.other_info")}</label>
            <span className="pointer">
              <i className="fa fa-chevron-up"></i>
              <i className="fa fa-chevron-down"></i>
            </span>
          </div>
        </div>
      </div>

      <CustomInfo id="customInfo" onChange={onChange} data={{ratePoor, clients, T}} />
      <hr/>

      <div className="row">
        <div className="phoneCounsellingSummary">
          <div className="col-xs-10 collapsed" data-toggle="collapse" data-target="#phoneCounsellingSummary">
            <label className="makeSpaceCustom">{T.translate("newCall.referralMoreInfo.phone_counselling")}</label>
            <span className="pointer">
              <i className="fa fa-chevron-up"></i>
              <i className="fa fa-chevron-down"></i>
            </span>
          </div>
        </div>
      </div>

      <div id="phoneCounsellingSummary" className="collapse">
        <br/>
        <div className="row">
          <div className="col-xs-12 col-md-9">
            <TextArea
              hidden="true"
              placeholder={T.translate("newCall.referralMoreInfo.add_note_about_the_content")}
              label="Phone Counselling Summary"
              value={call.phone_counselling_summary}
              onChange={onChange('call', 'phone_counselling_summary')} />
          </div>
        </div>
      </div>
      <hr/>

      <div className="row">
        <div className="informationProvided">
          <div className="col-xs-10 collapsed" data-toggle="collapse" data-target="#informationProvided">
            <label className="makeSpaceCustom">{T.translate("newCall.referralMoreInfo.information_provide")}</label>
            <span className="pointer">
              <i className="fa fa-chevron-up"></i>
              <i className="fa fa-chevron-down"></i>
            </span>
          </div>
        </div>
      </div>

      <div id="informationProvided" className="collapse">
        <br/>
        <div className="row">
          <div className="col-xs-12 col-md-9">
            <TextArea
              hidden="true"
              placeholder={T.translate("newCall.referralMoreInfo.add_note_about_the_content")}
              label="Information Provided"
              value={call.information_provided}
              onChange={onChange('call', 'information_provided')} />
          </div>
        </div>
      </div>
      <hr/>
    </div>
  )
}
