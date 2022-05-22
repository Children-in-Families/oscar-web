import { React, useState } from 'react'
import CareInfo from './carerInfo'
import SchoolInfo from './schoolInfo'
import DonorInfo from './donorInfo'
import CustomInfo from './customInfo'
import StackHolderInfo from './stackHolderInfo'

import {
  TextInput,
  DateTimePicker,
  SelectInput
} from "../Commons/inputs";
import { t } from '../../utils/i18n'

export default props => {
  const { onChange, renderAddressSwitch, translation, fieldsVisibility, current_organization, hintText,
          data: { errorFields, users, carerDistricts, carerCommunes, brc_presented_ids,
                  carerVillages, carer, client, familyMember, clientRelationships, currentProvinces,
                  currentDistricts, currentCommunes, currentVillages, donors, agencies, currentStates, currentTownships, carerSubdistricts,
                  schoolGrade, families, ratePoor, addressTypes, T, customId1, customId2, moSAVYOfficials
                }
        } = props

  const userLists = users.map((user) => ({
    label: user[0],
    value: user[1],
    isFixed: user[2] === "locked" ? true : false,
  }));

  const [RecordData, setRecordData] = useState([{ name: "Record 1", position: "position 1" }]);

  const renderMoSAVY = () => {
    return (
      RecordData.map((official, index) => {
        return (
          <div className="row">
            <div className="col-12 col-sm-3">
              <TextInput
                label="Name"
                onChange={()=>{}}
                required={ true }
                value={official.name}
              />
            </div>
  
            <div className="col-10 col-sm-3">
              <TextInput
                label="Position"
                onChange={()=>{}}
                required={ true }
                value={official.position}
              />
            </div>
  
            <div className="col-2 col-sm-2">
              <button className='btn btn-danger' onClick={onRemoveOfficial}>Remove</button>
            </div>
          </div>
        )
      })
    )
  }

  const onRemoveOfficial = () => {

  }

  const onAddOfficial = () => {

  }

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
              <label>{ t(translation, 'activerecord.attributes.carer.carer_information') }</label>
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

      <CareInfo id="careInfo"  translation={translation} fieldsVisibility={fieldsVisibility} current_organization={current_organization} data={{ carer, client, familyMember, clientRelationships, carerDistricts, carerCommunes, carerVillages, currentProvinces, currentDistricts, carerSubdistricts, currentCommunes, currentVillages, currentStates, currentTownships, families, addressTypes, T }} onChange={onChange} renderAddressSwitch={renderAddressSwitch} hintText={hintText} />

      {
        fieldsVisibility.client_school_information == true &&
        <>
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

          <SchoolInfo id="schoolInfo" data={{ client, schoolGrade, T }} onChange={onChange} translation={translation} fieldsVisibility={fieldsVisibility} hintText={hintText} />
        </>
      }

      {
        fieldsVisibility.stackholder_contacts == true &&
        <>
          <div className="row">
            <div className="schoolInfo collapsed" data-toggle="collapse" data-target="#stackHolderInfo">
              <div style={styles.sectionHead}>
                <div className="col-xs-4" >
                  <label>{t(translation, 'clients.form.stakeholder_contacts')}</label>
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

          <StackHolderInfo id="stackHolderInfo" data={{ client, T }} onChange={onChange} translation={translation} fieldsVisibility={fieldsVisibility} hintText={hintText} />
        </>
      }


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

      <DonorInfo id="donorInfo" data={{ donors, agencies, client, T }} onChange={onChange} hintText={hintText} />

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

      <CustomInfo id="customInfo" current_organization={current_organization} translation={translation} fieldsVisibility={fieldsVisibility} onChange={onChange} data={{errorFields, ratePoor, client, T, customId1, customId2 }} hintText={hintText} />

      <legend>
        <div className="row">
          <div className="col-xs-12 col-md-6 col-lg-3">
            <p>Pick up information</p>
          </div>
        </div>
      </legend>

      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          <DateTimePicker
            onChange={(value)=>{ onChange("client", "arrival_at")({ data: value, type: "date" }) }}
            value={client.arrival_at}
            label="Arrivate Date/Time"
          />
        </div>

        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            label="Flight Number"
            onChange={onChange("client", "flight_nb")}
            value={client.flight_nb}
          />
        </div>
      </div>

      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            T={T}
            label="Ratanak Achievement Program Staff"
            options={userLists}
            isMulti
            value={client.ratanak_achievement_program_staff_client_ids}
            onChange={onChange('client', 'ratanak_achievement_program_staff_client_ids')}
          />
        </div>
      </div>
      
      <div id="mosavy-officials" className="row">
        {  renderMoSAVY() }
        
        <div className="row">
          <div className="col-sm-12">
            <button className='btn btn-primary' onClick={onAddOfficial}>Add</button>
          </div>
        </div>
      </div>
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
