import React from 'react'
import CareInfo from './carerInfo'
import SchoolInfo from './schoolInfo'
import DonorInfo from './donorInfo'
import CustomInfo from './customInfo'

export default props => {
  const { onChange, translation, fieldsVisibility, current_organization, data: { errorFields, carerDistricts, carerCommunes, carerVillages, carer, client, clientRelationships, currentProvinces, currentDistricts, currentCommunes, currentVillages, donors, agencies, schoolGrade, families, ratePoor, addressTypes, T, brc_presented_ids, brc_prefered_langs } } = props

  return (
    <div className="containerClass">
      <legend>
        <div className="row">
          <div className="col-xs-6">
            <p>{T.translate("referralMoreInfo.referral_more_info")}</p>
          </div>
        </div>
      </legend>

      <div className="row">
        <div className="col-xs-4">
          <label>{T.translate("referralMoreInfo.do_you_want")}</label>
        </div>
      </div>
      <br/>
      <div className="row">
        <div className="careInfo collapsed" data-toggle="collapse" data-target="#careInfo">
          <div style={styles.sectionHead}>
            <div className="col-xs-4">
              <label>{T.translate("referralMoreInfo.carer_info")}</label>
            </div>
            <div className="col-xs-8">
              <span className="pointer">
                <i className="fa fa-chevron-up"></i>
                <i className="fa fa-chevron-down"></i>
              </span>
            </div>
          </div>
        </div>
      </div>

      <CareInfo id="careInfo" data={{ carer, client, clientRelationships, carerDistricts, carerCommunes, carerVillages, currentProvinces, currentDistricts, currentCommunes, currentVillages, families, addressTypes, T }} onChange={onChange} />

      <div className="row">
        <div className="schoolInfo collapsed" data-toggle="collapse" data-target="#schoolInfo">
          <div style={styles.sectionHead}>
            <div className="col-xs-4" >
              <label>{T.translate("referralMoreInfo.school_info")}</label>
            </div>
            <div className="col-xs-8">
              <span className="pointer">
                <i className="fa fa-chevron-up"></i>
                <i className="fa fa-chevron-down"></i>
              </span>
            </div>
          </div>
        </div>
      </div>

      <SchoolInfo id="schoolInfo" data={{ client, schoolGrade, T }} onChange={onChange} />

      <div className="row">
        <div className="donorInfo collapsed" data-toggle="collapse" data-target="#donorInfo">
          <div style={styles.sectionHead}>
            <div className="col-xs-4">
              <label>{T.translate("referralMoreInfo.donor_info")}</label>
            </div>
            <div className="col-xs-8">
              <span className="pointer">
                <i className="fa fa-chevron-up"></i>
                <i className="fa fa-chevron-down"></i>
              </span>
            </div>
          </div>
        </div>
      </div>

      <DonorInfo id="donorInfo" data={{ donors, agencies, client, T }} onChange={onChange} />

      <div className="row">
        <div className="customInfo collapsed" data-toggle="collapse" data-target="#customInfo">
          <div style={styles.sectionHead}>
            <div className="col-xs-4">
              <label>{T.translate("referralMoreInfo.other_info")}</label>
            </div>
            <div className="col-xs-8">
              <span className="pointer">
                <i className="fa fa-chevron-up"></i>
                <i className="fa fa-chevron-down"></i>
              </span>
            </div>
          </div>
        </div>
      </div>

      <CustomInfo id="customInfo" translation={translation} fieldsVisibility={fieldsVisibility} current_organization={current_organization} onChange={onChange} data={{errorFields, ratePoor, client, T, brc_presented_ids, brc_prefered_langs }} />
    </div>
  )
}

const styles = {
  sectionHead: {
    paddingTop: 15,
    paddingBottom: 15,
    height: 75
  }
}
