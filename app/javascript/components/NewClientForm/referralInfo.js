import React, { useEffect, useState } from "react";
import {
  SelectInput,
  DateInput,
  TextInput,
  Checkbox,
  RadioGroup,
  UploadInput,
  TextArea
} from "../Commons/inputs";
import BrcAddress from "./brcAddress";
import ConcernAddress from "./concernAddress";
import { t } from "../../utils/i18n";
import countryList from "react-select-country-list";

export default (props) => {
  const {
    onChange,
    renderAddressSwitch,
    fieldsVisibility,
    translation,
    hintText,
    data: {
      client,
      referee,
      currentDistricts,
      subDistricts,
      currentCommunes,
      currentVillages,
      birthProvinces,
      currentProvinces,
      currentStates,
      currentTownships,
      errorFields,
      callerRelationships,
      addressTypes,
      phoneOwners,
      T,
      current_organization,
      brc_presented_ids,
      brc_islands,
      brc_resident_types,
      brc_prefered_langs,
      maritalStatuses,
      nationalities,
      ethnicities,
      traffickingTypes,
      labels
    }
  } = props;

  const callerRelationship = callerRelationships.map((relationship) => ({
    label: T.translate("callerRelationship." + relationship.label),
    value: relationship.value
  }));
  const brcPresentedIdList = brc_presented_ids.map((presented_id) => ({
    label: presented_id,
    value: presented_id
  }));
  const preferLanguages = brc_prefered_langs.map((lang) => ({
    label: lang,
    value: lang
  }));
  const phoneOwner = phoneOwners.map((phone) => ({
    label: T.translate("phoneOwner." + phone.label),
    value: phone.value
  }));

  const maritalStatuseOptions = maritalStatuses.map((a) => ({
    label: a,
    value: a
  }));
  const nationalityOptions = nationalities.map((a) => ({ label: a, value: a }));
  const ethnicityOptions = ethnicities.map((a) => ({ label: a, value: a }));
  const traffickingTypeOptions = traffickingTypes.map((a) => ({
    label: a,
    value: a
  }));
  const locationOfConcernOptions = countryList()
    .getData()
    .map((a) => ({ label: a.label, value: a.label }));

  const genderLists = [
    { label: T.translate("genderLists.female"), value: "female" },
    { label: T.translate("genderLists.male"), value: "male" },
    { label: T.translate("genderLists.lgbt"), value: "lgbt" },
    { label: T.translate("genderLists.unknown"), value: "unknown" },
    {
      label: T.translate("genderLists.prefer_not_to_say"),
      value: "prefer_not_to_say"
    },
    { label: T.translate("genderLists.other"), value: "other" }
  ];
  const phoneEmailOwnerOpts = phoneOwners.map((phone) => ({
    label: T.translate("phoneOwner." + phone.label),
    value: phone.value
  }));
  const birthProvincesLists = birthProvinces.map((province) => ({
    label: province[0],
    options: province[1].map((value) => ({ label: value[0], value: value[1] }))
  }));

  const [districts, setDistricts] = useState(currentDistricts);
  const [communes, setCommunes] = useState(currentCommunes);
  const [villages, setVillages] = useState(currentVillages);
  const [states, setStates] = useState(currentStates);
  const [townships, setTownships] = useState(currentTownships);
  const [subdistricts, setSubdistricts] = useState(subDistricts);
  const yesNoOpts = [
    { label: T.translate("newCall.refereeInfo.yes"), value: true },
    { label: T.translate("newCall.refereeInfo.no"), value: false }
  ];

  let urlParams = window.location.search;
  let pattern = new RegExp(/type=call/gi);
  let isRedirectFromCall = pattern.test(urlParams);

  useEffect(() => {
    if (client.referee_relationship === "self") {
      const fields = {
        outside: referee.outside,
        province_id: referee.province_id,
        district_id: referee.district_id,
        commune_id: referee.commune_id,
        village_id: referee.village_id,
        state_id: referee.state_id,
        township_id: referee.township_id,
        subdistrict_id: referee.subdistrict_id,
        street_number: referee.street_number,
        house_number: referee.house_number,
        current_address: referee.current_address,
        address_type: referee.address_type,
        outside_address: referee.outside_address,
        state_id: referee.state_id,
        township_id: referee.township_id,
        subdistrict_id: referee.subdistrict_id,
        street_line1: referee.street_line1,
        street_line2: referee.street_line2,
        plot: referee.plot,
        road: referee.road,
        postal_code: referee.postal_code,
        suburb: referee.suburb,
        description_house_landmark: referee.description_house_landmark,
        directions: referee.directions
      };

      if (referee.province_id !== null)
        fetchData("provinces", referee.province_id, "districts");
      if (referee.district_id !== null)
        if (current_organization.country == "thailand") {
          fetchData("subdistricts", referee.district_id, "subdistricts");
        } else {
          fetchData("districts", referee.district_id, "communes");
        }
      if (referee.commune_id !== null)
        fetchData("communes", referee.commune_id, "villages");
      if (referee.state_id !== null)
        fetchData("townships", referee.state_id, "townships");

      const newObject = { ...client, ...fields };
      onChange("client", newObject)({ type: "select" });
    }
  }, [referee]);

  const onProfileChange = (fileItems) => {
    onChange(
      "clientProfile",
      fileItems[0] && fileItems[0].file
    )({ type: "file" });
  };

  const onChangeRemoveProfile = (data) => {
    onChange("client", { remove_profile: data.data })({ type: "checkbox" });
  };

  const fetchData = (parent, data, child) => {
    $.ajax({
      type: "GET",
      url: `/api/${parent}/${data}/${child}`
    })
      .success((res) => {
        const dataState = {
          districts: setDistricts,
          communes: setCommunes,
          villages: setVillages
        };
        dataState[child](res.data);
      })
      .error((res) => {
        onerror(res.responseText);
      });
  };

  const onRelationshipChange = (event) => {
    const previousSelect = client.referee_relationship;
    const isSelf = event.data === "self";

    if (isSelf) {
      if (referee.province_id !== null)
        fetchData("provinces", referee.province_id, "districts");
      if (referee.district_id !== null)
        if (current_organization.country == "thailand") {
          fetchData("districts", referee.district_id, "subdistricts");
        } else {
          fetchData("districts", referee.district_id, "communes");
        }
      if (referee.commune_id !== null)
        fetchData("communes", referee.commune_id, "villages");
      if (referee.state_id !== null)
        fetchData("states", referee.state_id, "townships");
    } else if (previousSelect === "self") {
      setDistricts([]);
      setSubdistricts([]);
      setTownships([]);
      setCommunes([]);
      setVillages([]);
    }

    const fields = {
      outside: isSelf
        ? referee.outside
        : previousSelect === "self"
        ? false
        : client.outside,
      province_id: isSelf
        ? referee.province_id
        : previousSelect === "self"
        ? null
        : client.province_id,
      district_id: isSelf
        ? referee.district_id
        : previousSelect === "self"
        ? null
        : client.district_id,
      commune_id: isSelf
        ? referee.commune_id
        : previousSelect === "self"
        ? null
        : client.commune_id,
      village_id: isSelf
        ? referee.village_id
        : previousSelect === "self"
        ? null
        : client.village_id,
      street_number: isSelf
        ? referee.street_number
        : previousSelect === "self"
        ? ""
        : client.street_number,
      house_number: isSelf
        ? referee.house_number
        : previousSelect === "self"
        ? ""
        : client.house_number,
      current_address: isSelf
        ? referee.current_address
        : previousSelect === "self"
        ? ""
        : client.current_address,
      address_type: isSelf
        ? referee.address_type
        : previousSelect === "self"
        ? ""
        : client.address_type,
      outside_address: isSelf
        ? referee.outside_address
        : previousSelect === "self"
        ? ""
        : client.outside_address
    };

    onChange("client", { ...fields, referee_relationship: event.data })({
      type: "select"
    });
  };

  const onCheckSameAsClient = (data) => {
    const same = data.data;

    if (same) {
      if (client.province_id !== null)
        fetchData("provinces", client.province_id, "districts");
      if (client.district_id !== null)
        fetchData("districts", client.district_id, "communes");
      if (client.commune_id !== null)
        fetchData("communes", client.commune_id, "villages");
    } else {
      setDistricts([]);
      setCommunes([]);
      setVillages([]);
    }

    const fields = {
      concern_is_outside: same ? client.outside : false,
      concern_province_id: same ? client.province_id : null,
      concern_district_id: same ? client.district_id : null,
      concern_commune_id: same ? client.commune_id : null,
      concern_village_id: same ? client.village_id : null,
      concern_street: same ? client.street_number : "",
      concern_house: same ? client.house_number : "",
      concern_address: same ? client.current_address : "",
      concern_address_type: same ? client.address_type : "",
      concern_outside_address: same ? client.outside_address : ""
    };

    onChange("client", { ...fields, concern_same_as_client: data.data })({
      type: "select"
    });
  };

  const onCheckSharedServiceEnable = (data) => {
    const sharedServices = data.data;
    const sharedServiceField = { shared_service_enabled: sharedServices };
    onChange("client", { ...sharedServiceField })({ type: "radio" });
  };

  const onChangeTestingClientRadioOption = (data) => {
    const yesNoOpt = data.data;
    const fieldValues = { for_testing: yesNoOpt };
    onChange("client", { ...fieldValues })({ type: "radio" });
  };

  return (
    <div className="containerClass">
      <div className="row hidden">
        <div className="col-xs-6">
          <TextInput
            onChange={onChange("client", "external_id")}
            value={client.external_id}
          />
        </div>
        <div className="col-xs-6">
          <TextInput
            onChange={onChange("client", "external_id_display")}
            value={client.external_id_display}
          />
        </div>
      </div>
      <legend>
        <div className="row">
          <div className="col-xs-12 col-md-6 col-lg-5">
            <p>{t(translation, "clients.form.referral_info")}</p>
          </div>
        </div>
      </legend>
      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            label={t(translation, "clients.form.given_name")}
            onChange={onChange("client", "given_name")}
            value={client.given_name}
            inlineClassName="given-name"
            hintText={hintText.referral.given_name}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            label={t(translation, "clients.form.family_name")}
            onChange={onChange("client", "family_name")}
            value={client.family_name}
            inlineClassName="family-name"
            hintText={hintText.referral.family_name}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            label={t(translation, "clients.form.local_given_name")}
            onChange={onChange("client", "local_given_name")}
            value={client.local_given_name}
            inlineClassName="local-given-name"
            hintText={hintText.referral.local_given_name}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            label={t(translation, "clients.form.local_family_name")}
            onChange={onChange("client", "local_family_name")}
            value={client.local_family_name}
            inlineClassName="local-family-name"
            hintText={hintText.referral.local_family_name}
          />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            T={T}
            required
            isError={errorFields.includes("gender")}
            label={t(translation, "clients.form.gender")}
            options={genderLists}
            value={client.gender}
            onChange={onChange("client", "gender")}
            inlineClassName="client-gender"
            hintText={hintText.referral.client_gender}
          />
        </div>

        <div className="col-xs-12 col-md-6 col-lg-3">
          <DateInput
            getCurrentDate
            label={T.translate("referralInfo.date_of_birth")}
            onChange={onChange("client", "date_of_birth")}
            value={client.date_of_birth}
            hintText={hintText.referral.client_dat_of_birth}
          />
        </div>

        {fieldsVisibility.birth_province == true && (
          <div className="col-xs-12 col-md-6 col-lg-3">
            <SelectInput
              asGroup
              label={t(translation, "clients.form.birth_province")}
              options={birthProvincesLists}
              value={client.birth_province_id}
              onChange={onChange("client", "birth_province_id")}
              hintText={hintText.referral.client_birth_province}
            />
          </div>
        )}

        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            label={T.translate("referralInfo.caller_relationship")}
            options={callerRelationship}
            value={client.referee_relationship}
            onChange={onRelationshipChange}
            hintText={hintText.referral.client_relationship}
          />
        </div>

        {fieldsVisibility.preferred_language == true && (
          <div className="col-xs-12 col-md-6 col-lg-3">
            <SelectInput
              label={t(translation, "clients.form.preferred_language")}
              options={preferLanguages}
              onChange={onChange("client", "preferred_language")}
              value={client.preferred_language}
            />
          </div>
        )}
      </div>

      <div className="row">
        {fieldsVisibility.marital_status == true && (
          <div className="col-xs-12 col-md-6 col-lg-3">
            <SelectInput
              label={t(translation, "clients.form.marital_status")}
              options={maritalStatuseOptions}
              onChange={onChange("client", "marital_status")}
              value={client.marital_status}
            />
          </div>
        )}

        {fieldsVisibility.national_id_number == true && (
          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label={t(translation, "clients.form.national_id_number")}
              onChange={onChange("client", "national_id_number")}
              value={client.national_id_number}
            />
          </div>
        )}

        {fieldsVisibility.passport_number == true && (
          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label={t(translation, "clients.form.passport_number")}
              onChange={onChange("client", "passport_number")}
              value={client.passport_number}
            />
          </div>
        )}

        {fieldsVisibility.nationality == true && (
          <div className="col-xs-12 col-md-6 col-lg-3">
            <SelectInput
              label={t(translation, "clients.form.nationality")}
              options={nationalityOptions}
              onChange={onChange("client", "nationality")}
              value={client.nationality}
            />
          </div>
        )}
      </div>

      <div className="row">
        {fieldsVisibility.ethnicity == true && (
          <div className="col-xs-12 col-md-6 col-lg-3">
            <SelectInput
              label={t(translation, "clients.form.ethnicity")}
              options={ethnicityOptions}
              onChange={onChange("client", "ethnicity")}
              value={client.ethnicity}
            />
          </div>
        )}

        {fieldsVisibility.type_of_trafficking == true && (
          <div className="col-xs-12 col-md-6 col-lg-3">
            <SelectInput
              label={t(translation, "clients.form.type_of_trafficking")}
              options={traffickingTypeOptions}
              onChange={onChange("client", "type_of_trafficking")}
              value={client.type_of_trafficking}
            />
          </div>
        )}

        {fieldsVisibility.location_of_concern == true && (
          <div className="col-xs-12 col-md-6 col-lg-3">
            <SelectInput
              label={t(translation, "clients.form.location_of_concern")}
              options={locationOfConcernOptions}
              onChange={onChange("client", "location_of_concern")}
              value={client.location_of_concern}
            />
          </div>
        )}
      </div>

      <div className="row">
        {fieldsVisibility.presented_id == true && (
          <div className="col-xs-12 col-md-6 col-lg-3">
            <SelectInput
              label={t(translation, "clients.form.presented_id")}
              options={brcPresentedIdList}
              onChange={onChange("client", "presented_id")}
              value={client.presented_id}
            />
          </div>
        )}

        {fieldsVisibility.id_number == true && (
          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label={t(translation, "clients.form.id_number")}
              onChange={onChange("client", "id_number")}
              value={client.id_number}
            />
          </div>
        )}

        {fieldsVisibility.legacy_brcs_id == true && (
          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label={t(translation, "clients.form.legacy_brcs_id")}
              onChange={onChange("client", "legacy_brcs_id")}
              value={client.legacy_brcs_id}
            />
          </div>
        )}

        {fieldsVisibility.brsc_branch == true && (
          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label={t(translation, "clients.form.brsc_branch")}
              onChange={onChange("client", "brsc_branch")}
              value={client.brsc_branch}
            />
          </div>
        )}
      </div>

      <div className="row">
        <div className="col-xs-12 col-md-6">
          <RadioGroup
            inline
            label={labels.has_disability}
            options={yesNoOpts}
            onChange={onChange("client", "has_disability")}
            value={client.has_disability}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-6">
          <TextInput
            inline
            label={labels.if_yes}
            onChange={onChange("client", "disability_specification")}
            value={client.disability_specification}
          />
        </div>
      </div>

      <div className="row">
        <div className="col-xs-12">
          <UploadInput
            label={T.translate("referralInfo.profile")}
            onChange={onProfileChange}
            object={client.profile}
            onChangeCheckbox={onChangeRemoveProfile}
            checkBoxValue={client.remove_profile || false}
            T={T}
          />
        </div>
      </div>

      {fieldsVisibility.brc_client_address != true && (
        <div>
          <legend>
            <div className="row">
              <div className="col-xs-12 col-md-6 col-lg-3">
                <p>{T.translate("referralInfo.contact_info")}</p>
              </div>
              {client.referee_relationship !== "self" && (
                <div className="col-xs-12 col-md-6 col-lg-6">
                  <Checkbox
                    label={T.translate("referralInfo.client_is_outside")}
                    checked={client.outside || false}
                    onChange={onChange("client", "outside")}
                  />
                </div>
              )}
            </div>
          </legend>
          {renderAddressSwitch(
            client,
            "client",
            client.referee_relationship === "self",
            {
              districts,
              communes,
              villages
            }
          )}
        </div>
      )}

      {fieldsVisibility.brc_client_address == true && (
        <legend className="brc-address">
          <div className="row">
            <div className="col-xs-12 col-md-6 col-lg-3">
              <p>{T.translate("referralInfo.contact_info")}</p>
            </div>
          </div>
        </legend>
      )}

      <div className="row">
        {fieldsVisibility.what3words == true && (
          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label={t(translation, "clients.form.what_3_word")}
              onChange={onChange("client", "what3words")}
              value={client.what3words}
              inlineClassName="what-3-word"
              hintText={hintText.referral.what_3_word}
            />
          </div>
        )}

        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            label={t(translation, "clients.form.client_phone")}
            type="text"
            onChange={onChange("client", "client_phone")}
            value={client.client_phone}
            hintText={hintText.referral.client_phone}
          />
        </div>

        {fieldsVisibility.whatsapp == true && (
          <div className="col-xs-12 col-md-6 col-lg-3">
            <Checkbox
              label={t(translation, "clients.form.whatsapp")}
              checked={client.whatsapp}
              onChange={onChange("client", "whatsapp")}
            />
          </div>
        )}

        {fieldsVisibility.other_phone_number == true && (
          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label={t(translation, "clients.form.other_phone_number")}
              onChange={onChange("client", "other_phone_number")}
              value={client.other_phone_number}
            />
          </div>
        )}

        {fieldsVisibility.other_phone_whatsapp == true && (
          <div className="col-xs-12 col-md-6 col-lg-3">
            <Checkbox
              label={t(translation, "clients.form.other_phone_whatsapp")}
              checked={client.other_phone_whatsapp}
              onChange={onChange("client", "other_phone_whatsapp")}
            />
          </div>
        )}

        {fieldsVisibility.phone_owner == true && (
          <div className="col-xs-12 col-md-6 col-lg-3">
            <SelectInput
              label={t(translation, "clients.form.phone_owner")}
              options={phoneOwner}
              onChange={onChange("client", "phone_owner")}
              value={client.phone_owner}
              hintText={hintText.referral.phone_owner}
            />
          </div>
        )}
      </div>

      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            label={T.translate("referralInfo.client_email")}
            onChange={onChange("client", "client_email")}
            value={client.client_email}
            hintText={hintText.referral.client_email}
          />
        </div>

        {isRedirectFromCall && (
          <div className="col-xs-12">
            <TextArea
              label={T.translate("newCall.referralInfo.location_description")}
              value={client.location_description}
              onChange={onChange("client", "location_description")}
            />
          </div>
        )}
      </div>

      <br />

      {fieldsVisibility.brc_client_address == true && (
        <BrcAddress
          translation={translation}
          fieldsVisibility={fieldsVisibility}
          disabled={client.referee_relationship === "self"}
          current_organization={current_organization}
          callFrom="referralInfo"
          outside={client.outside || false}
          onChange={onChange}
          data={{
            addressTypes,
            currentDistricts: districts,
            currentCommunes: communes,
            currentVillages: villages,
            objectKey: "client",
            objectData: client,
            T,
            brc_islands,
            brc_resident_types
          }}
        />
      )}

      {isRedirectFromCall && (
        <>
          <legend>
            <div className="row">
              <div className="col-xs-12 col-md-6 col-lg-3">
                <p>{T.translate("newCall.referralInfo.location_of_concern")}</p>
              </div>
              <div className="col-xs-12 col-md-6 col-lg-3">
                <Checkbox
                  label={T.translate("newCall.referralInfo.same_as_client")}
                  checked={client.concern_same_as_client}
                  onChange={onCheckSameAsClient}
                />
              </div>
              {!client.concern_same_as_client && (
                <div className="col-xs-12 col-md-6 col-lg-6">
                  <Checkbox
                    label={T.translate(
                      "newCall.referralInfo.concern_is_outside_cambodia"
                    )}
                    checked={client.concern_is_outside || false}
                    onChange={onChange("client", "concern_is_outside")}
                  />
                </div>
              )}
            </div>
          </legend>

          <ConcernAddress
            T={T}
            disabled={client.concern_same_as_client}
            outside={client.concern_is_outside || false}
            onChange={onChange}
            data={{
              addressTypes,
              currentDistricts: districts,
              currentCommunes: communes,
              currentVillages: villages,
              currentProvinces,
              objectKey: "client",
              objectData: client
            }}
          />

          <div className="row">
            <div className="col-xs-12 col-md-6">
              <div className="row">
                <div className="col-xs-12 col-md-6">
                  <TextInput
                    T={T}
                    label={T.translate(
                      "newCall.referralInfo.relevant_contact_phone"
                    )}
                    onChange={onChange("client", "concern_phone")}
                    value={client.concern_phone}
                  />
                </div>
                <div className="col-xs-12 col-md-6">
                  <SelectInput
                    T={T}
                    label={T.translate("newCall.referralInfo.phone_owner")}
                    options={phoneEmailOwnerOpts}
                    value={client.concern_phone_owner}
                    onChange={onChange("client", "concern_phone_owner")}
                  />
                </div>
              </div>
              <div className="row">
                <div className="col-xs-12 col-md-6">
                  <TextInput
                    T={T}
                    label={T.translate("newCall.referralInfo.relevant_email")}
                    onChange={onChange("client", "concern_email")}
                    value={client.concern_email}
                  />
                </div>
                <div className="col-xs-12 col-md-6">
                  <SelectInput
                    T={T}
                    label={T.translate("newCall.referralInfo.email_owner")}
                    options={phoneEmailOwnerOpts}
                    value={client.concern_email_owner}
                    onChange={onChange("client", "concern_email_owner")}
                  />
                </div>
              </div>
            </div>
            <div
              className={
                "col-xs-12 col-md-6" +
                (client.concern_is_outside ? " hidden" : "")
              }
            >
              <TextArea
                label={T.translate("newCall.referralInfo.locatin_description")}
                value={client.concern_location}
                onChange={onChange("client", "concern_location")}
              />
            </div>
          </div>
        </>
      )}
    </div>
  );
};
