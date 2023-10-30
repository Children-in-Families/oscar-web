import React, { useState } from "react";
import CareInfo from "./carerInfo";
import SchoolInfo from "./schoolInfo";
import DonorInfo from "./donorInfo";
import CustomInfo from "./customInfo";
import StackHolderInfo from "./stackHolderInfo";

import { TextInput, DateTimePicker, SelectInput } from "../Commons/inputs";
import { t } from "../../utils/i18n";

export default (props) => {
  const {
    onChange,
    onAddOfficial,
    onRemoveOfficial,
    onChangeOfficial,
    renderAddressSwitch,
    translation,
    fieldsVisibility,
    current_organization,
    hintText,
    data: {
      errorFields,
      users,
      carerDistricts,
      carerCommunes,
      brc_presented_ids,
      carerVillages,
      carer,
      client,
      familyMember,
      clientRelationships,
      currentProvinces,
      currentDistricts,
      currentCommunes,
      currentVillages,
      donors,
      agencies,
      currentStates,
      currentTownships,
      carerSubdistricts,
      schoolGrade,
      families,
      ratePoor,
      addressTypes,
      T,
      customId1,
      customId2,
      moSAVYOfficialsData
    }
  } = props;

  const userLists = users.map((user) => ({
    label: user[0],
    value: user[1],
    isFixed: user[2] === "locked" ? true : false
  }));

  const renderMoSAVY = () => {
    return moSAVYOfficialsData.map((official, index) => {
      if (official._destroy !== true) {
        return (
          <div
            key={index}
            className="row"
            style={{ display: "flex", alignItems: "center" }}
          >
            <div style={{ display: "none" }}>
              <TextInput
                value={official.id}
                onChange={(event) => {
                  onChangeOfficial(event.target.value, "id", index);
                }}
              />
            </div>

            <div className="col-12 col-sm-3">
              <TextInput
                label={t(translation, "clients.form.mosavy_official_name")}
                onChange={(event) => {
                  onChangeOfficial(event.target.value, "name", index);
                }}
                required={true}
                isError={
                  errorFields.includes("name") &&
                  (official.name == undefined || official.name.length == 0)
                }
                value={official.name}
                T={T}
              />
            </div>

            <div className="col-10 col-sm-3">
              <TextInput
                label={t(translation, "clients.form.mosavy_official_position")}
                onChange={(event) => {
                  onChangeOfficial(event.target.value, "position", index);
                }}
                isError={
                  errorFields.includes("position") &&
                  (official.position == undefined ||
                    official.position.length == 0)
                }
                required={true}
                value={official.position}
                T={T}
              />
            </div>

            <div className="col-2 col-sm-2">
              <button
                className="btn btn-danger"
                onClick={() => {
                  onRemoveOfficial(index);
                }}
              >
                {t(translation, "clients.form.remove_mosavy_official")}
              </button>
            </div>
          </div>
        );
      }
    });
  };

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
      <br />
      <div className="row">
        <div
          className="careInfo collapsed"
          data-toggle="collapse"
          data-target="#careInfo"
        >
          <div style={styles.sectionHead}>
            <div className="col-xs-4">
              <label>
                {t(
                  translation,
                  "activerecord.attributes.carer.carer_information"
                )}
              </label>
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

      <CareInfo
        id="careInfo"
        translation={translation}
        fieldsVisibility={fieldsVisibility}
        current_organization={current_organization}
        data={{
          carer,
          client,
          familyMember,
          clientRelationships,
          carerDistricts,
          carerCommunes,
          carerVillages,
          currentProvinces,
          currentDistricts,
          carerSubdistricts,
          currentCommunes,
          currentVillages,
          currentStates,
          currentTownships,
          families,
          addressTypes,
          T
        }}
        onChange={onChange}
        renderAddressSwitch={renderAddressSwitch}
        hintText={hintText}
      />

      {fieldsVisibility.client_school_information == true && (
        <>
          <div className="row">
            <div
              className="schoolInfo collapsed"
              data-toggle="collapse"
              data-target="#schoolInfo"
            >
              <div style={styles.sectionHead}>
                <div className="col-xs-4">
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

          <SchoolInfo
            id="schoolInfo"
            data={{ client, schoolGrade, T }}
            onChange={onChange}
            translation={translation}
            fieldsVisibility={fieldsVisibility}
            hintText={hintText}
          />
        </>
      )}

      {fieldsVisibility.stackholder_contacts == true && (
        <>
          <div className="row">
            <div
              className="schoolInfo collapsed"
              data-toggle="collapse"
              data-target="#stackHolderInfo"
            >
              <div style={styles.sectionHead}>
                <div className="col-xs-4">
                  <label>
                    {t(translation, "clients.form.stakeholder_contacts")}
                  </label>
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

          <StackHolderInfo
            id="stackHolderInfo"
            data={{ client, T }}
            onChange={onChange}
            translation={translation}
            fieldsVisibility={fieldsVisibility}
            hintText={hintText}
          />
        </>
      )}

      <div className="row">
        <div
          className="donorInfo collapsed"
          data-toggle="collapse"
          data-target="#donorInfo"
        >
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

      <DonorInfo
        id="donorInfo"
        data={{ donors, agencies, client, T }}
        onChange={onChange}
        hintText={hintText}
      />

      <div className="row">
        <div
          className="customInfo collapsed"
          data-toggle="collapse"
          data-target="#customInfo"
        >
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

      <CustomInfo
        id="customInfo"
        current_organization={current_organization}
        translation={translation}
        fieldsVisibility={fieldsVisibility}
        onChange={onChange}
        data={{ errorFields, ratePoor, client, T, customId1, customId2 }}
        hintText={hintText}
      />

      {fieldsVisibility.client_pickup_information == true && (
        <div id="pickup-info">
          <legend>
            <div className="row">
              <div className="col-xs-12">
                <p>{t(translation, "clients.form.pickup_information")}</p>
              </div>
            </div>
          </legend>

          {fieldsVisibility.client_arrival_at == true && (
            <div className="row">
              <div className="col-xs-12 col-md-6">
                <DateTimePicker
                  onChange={(value) => {
                    onChange(
                      "client",
                      "arrival_at"
                    )({ data: value, type: "date" });
                  }}
                  value={client.arrival_at}
                  label={t(translation, "clients.form.arrival_at")}
                />
              </div>
            </div>
          )}

          {fieldsVisibility.client_flight_nb == true && (
            <div className="row">
              <div className="col-xs-12 col-md-6">
                <TextInput
                  label={t(translation, "clients.form.flight_nb")}
                  onChange={onChange("client", "flight_nb")}
                  value={client.flight_nb}
                />
              </div>
            </div>
          )}

          {fieldsVisibility.client_ratanak_achievement_program_staff_client_ids ==
            true && (
            <div className="row">
              <div className="col-xs-12 col-md-6">
                <SelectInput
                  T={T}
                  label={t(
                    translation,
                    "clients.form.ratanak_achievement_program_staff_client_ids"
                  )}
                  options={userLists}
                  isMulti
                  value={client.ratanak_achievement_program_staff_client_ids}
                  onChange={onChange(
                    "client",
                    "ratanak_achievement_program_staff_client_ids"
                  )}
                />
              </div>
            </div>
          )}

          {fieldsVisibility.client_mosavy_official == true && (
            <div id="mosavy-officials" className="row">
              <fieldset className="legal-form-border">
                <legend className="legal-form-border">
                  <h3 className="text-success">
                    {t(translation, "clients.form.mosavy_official")}
                  </h3>
                </legend>

                {renderMoSAVY()}

                <div className="row">
                  <div className="col-sm-12">
                    <button className="btn btn-primary" onClick={onAddOfficial}>
                      {t(translation, "clients.form.add_mosavy_official")}
                    </button>
                  </div>
                </div>
              </fieldset>
            </div>
          )}
        </div>
      )}
    </div>
  );
};

const styles = {
  sectionHead: {
    paddingTop: 15,
    paddingBottom: 15,
    height: 75
  }
};
