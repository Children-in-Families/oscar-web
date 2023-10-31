import React, { useEffect, useState } from "react";
import {
  SelectInput,
  TextInput,
  Checkbox,
  RadioGroup
} from "../Commons/inputs";
import { t } from "../../utils/i18n";

export default (props) => {
  const {
    onChange,
    renderAddressSwitch,
    fieldsVisibility,
    translation,
    current_organization,
    hintText,
    data: {
      referees,
      refereeDistricts,
      refereeCommunes,
      refereeVillages,
      referee,
      client,
      currentProvinces,
      currentStates,
      refereeTownships,
      refereeSubdistricts,
      referralSourceCategory,
      referralSource,
      errorFields,
      addressTypes,
      locality,
      T
    }
  } = props;

  const [districts, setDistricts] = useState(refereeDistricts);
  const [communes, setCommunes] = useState(refereeCommunes);
  const [villages, setVillages] = useState(refereeVillages);
  const [townships, setTownships] = useState(refereeTownships);
  const [subdistricts, setSubdistricts] = useState(refereeSubdistricts);

  const genderLists = [
    { label: T.translate("refereeInfo.female"), value: "female" },
    { label: T.translate("refereeInfo.male"), value: "male" },
    { label: T.translate("refereeInfo.lgbt"), value: "lgbt" },
    { label: T.translate("refereeInfo.unknown"), value: "unknown" },
    {
      label: t(
        translation,
        "default_client_fields.gender_list.prefer_not_to_say"
      ),
      value: "prefer_not_to_say"
    },
    { label: T.translate("refereeInfo.other"), value: "other" }
  ];

  const yesNoOpts = [
    { label: T.translate("newCall.refereeInfo.yes"), value: true },
    { label: T.translate("newCall.refereeInfo.no"), value: false }
  ];

  const referralSourceCategoryLists = referralSourceCategory.map(
    (category) => ({ label: category[0], value: category[1] })
  );
  const referralSourceLists = referralSource
    .filter(
      (source) =>
        source.ancestry !== null &&
        source.ancestry == client.referral_source_category_id
    )
    .map((source) => ({ label: source.name, value: source.id }));

  useEffect(() => {
    if (referee.anonymous) {
      const fields = {
        anonymous: true,
        outside: false,
        name: "Anonymous",
        phone: referee.phone,
        email: "",
        gender: "",
        street_number: "",
        house_number: "",
        current_address: "",
        locality: "",
        outside_address: "",
        address_type: "",
        province_id: null,
        district_id: null,
        commune_id: null,
        village_id: null,
        state_id: null,
        township_id: null,
        subdistrict_id: null,
        street_line1: "",
        street_line2: "",
        plot: "",
        road: "",
        postal_code: "",
        suburb: "",
        description_house_landmark: "",
        directions: ""
      };
      onChange("referee", { ...fields })({ type: "select" });
    }
  }, [referee.anonymous]);

  const onReferralSourceCategoryChange = (data) => {
    onChange("client", {
      referral_source_category_id: data.data,
      referral_source_id: null
    })({ type: "select" });
  };

  const selector1 = {
    inline_classname: "selector1"
  };

  const selector2 = {
    inline_classname: "selector2"
  };

  const onChangeExistingReferree = (data) => {
    const value = data.data;
    const newData = { existing_referree: value };

    onChange("referee", { ...newData })({ type: "radio" });

    if (value == true) {
      setDistricts([]);
      setCommunes([]);
      setVillages([]);
      setTownships([]);
      setSubdistricts([]);

      const refereeFields = {
        id: null,
        outside: false,
        province_id: null,
        district_id: null,
        commune_id: null,
        village_id: null,
        existing_referree: value,
        name: "",
        gender: "",
        adult: null,
        phone: "",
        email: "",
        street_number: "",
        house_number: "",
        current_address: "",
        address_type: "",
        locality: "",
        outside_address: ""
      };

      onChange("referee", { ...refereeFields })({ type: "select" });
    }
  };

  const refereeLists = () => {
    let newList = [];
    referees.forEach((r) =>
      newList.push({ label: `${r.name} ${r.phone} ${r.email}`, value: r.id })
    );
    return newList;
  };

  const fetchData = (parent, data, child) => {
    if (data)
      $.ajax({
        type: "GET",
        url: `/api/${parent}/${data}/${child}`
      })
        .success((res) => {
          const dataState = {
            districts: setDistricts,
            communes: setCommunes,
            villages: setVillages,
            townships: setTownships,
            subdistricts: setSubdistricts
          };
          dataState[child](res.data);
        })
        .error((res) => {
          onerror(res.responseText);
        });
  };

  const onRefereeNameChange = (evt) => {
    let {
      email,
      id,
      name,
      gender,
      phone,
      province_id,
      district_id,
      commune_id,
      village_id,
      street_number,
      state_id,
      township_id,
      house_number,
      address_type,
      current_address,
      outside,
      outside_address,
      adult
    } = referees.filter((r) => r.id == evt.data)[0] || {};
    if (province_id !== null) fetchData("provinces", province_id, "districts");
    if (district_id !== null)
      if (current_organization.country == "thailand") {
        fetchData("districts", district_id, "subdistricts");
      } else {
        fetchData("districts", district_id, "communes");
      }
    if (commune_id !== null) fetchData("communes", commune_id, "villages");
    if (state_id !== null) fetchData("states", state_id, "townships");

    onChange("referee", {
      id,
      name,
      email,
      gender,
      phone,
      province_id,
      district_id,
      commune_id,
      village_id,
      state_id,
      township_id,
      street_number,
      house_number,
      address_type,
      current_address,
      outside,
      outside_address,
      adult
    })({ type: "select" });

    onChange("client", {
      referral_source_category_id: null,
      referral_source_id: null
    })({ type: "select" });
  };
  console.log(!referee.anonymous && referee.existing_referree);
  const renderNameField = () => {
    if (!referee.anonymous && referee.existing_referree) {
      return (
        <SelectInput
          T={T}
          label={T.translate("refereeInfo.name")}
          required
          onChange={onRefereeNameChange}
          options={refereeLists()}
          disabled={referee.anonymous}
          isError={errorFields.includes("name")}
          value={referee.id}
          inlineClassName="referee-name"
          hintText={hintText.referee.name}
        />
      );
    } else {
      return (
        <TextInput
          T={T}
          required
          disabled={referee.anonymous}
          isError={errorFields.includes("name")}
          value={referee.name}
          label={T.translate("refereeInfo.name")}
          onChange={(value) => {
            onChange("referee", "name")(value);
            onChange("client", "name_of_referee")(value);
          }}
          inlineClassName="referee-name"
          hintText={hintText.referee.name}
        />
      );
    }
  };

  const isReferralSourceExist = (client) => {
    return (
      (client.id == null && !_.isEmpty(client.mosvy_number)) ||
      (client.external_id && client.external_id > 0) ||
      (client.id == null &&
        client.referred_external &&
        client.referral_source_category_id &&
        client.referral_source_category_id > 0) ||
      client.referred_external ||
      false
    );
  };

  return (
    <div className="containerClass">
      <legend>
        <div className="row">
          <div className="col-xs-12 col-md-6 col-lg-4">
            <p>{T.translate("refereeInfo.referee_info")}</p>
          </div>
        </div>
      </legend>

      <div className="row">
        <div className="col-xs-12 col-sm-6 col-md-3">
          <Checkbox
            label={T.translate("refereeInfo.anonymous_referee")}
            checked={referee.anonymous || false}
            objectKey="referee"
            onChange={onChange("referee", "anonymous")}
          />
        </div>
      </div>

      <div className="row">
        <div className="col-xs-12">
          <RadioGroup
            inline
            required
            label={t(translation, "clients.form.referee_called_before")}
            options={yesNoOpts}
            onChange={onChangeExistingReferree}
            value={referee.existing_referree}
          />
        </div>
      </div>

      <br />
      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">{renderNameField()}</div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            label={T.translate("refereeInfo.gender")}
            isDisabled={referee.anonymous}
            options={genderLists}
            onChange={onChange("referee", "gender")}
            value={referee.gender}
            inlineClassName="referee-gender"
            hintText={hintText.referee.gender}
          />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            label={T.translate("refereeInfo.referee_phone")}
            type="text"
            disabled={referee.anonymous}
            onChange={onChange("referee", "phone")}
            value={referee.phone}
            hintText={hintText.referee.phone}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            label={T.translate("refereeInfo.referee_email")}
            disabled={referee.anonymous}
            onChange={onChange("referee", "email")}
            value={referee.email}
            hintText={hintText.referee.email}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            T={T}
            required
            isError={errorFields.includes("referral_source_category_id")}
            label={T.translate("refereeInfo.referral_source_cat")}
            options={referralSourceCategoryLists}
            value={client.referral_source_category_id}
            onChange={onReferralSourceCategoryChange}
            isDisabled={isReferralSourceExist(client)}
            inlineClassName="referral-source-category"
            hintText={hintText.referee.referral_source_category}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            options={referralSourceLists}
            label={T.translate("refereeInfo.referral_source")}
            onChange={onChange("client", "referral_source_id")}
            value={client.referral_source_id}
            inlineClassName="referral-source"
            hintText={hintText.referee.referral_source}
          />
        </div>
      </div>

      <legend>
        <div className="row">
          <div className="col-xs-12 col-md-6 col-lg-3">
            <p>
              {t(
                translation,
                "activerecord.attributes.referee.referee_address"
              )}
            </p>
          </div>
          {!referee.anonymous && (
            <div className="col-xs-12 col-md-6 col-lg-3">
              <Checkbox
                label={T.translate("refereeInfo.outside_cam")}
                checked={referee.outside || false}
                onChange={onChange("referee", "outside")}
              />
            </div>
          )}
        </div>
      </legend>
      {renderAddressSwitch(referee, "referee", referee.anonymous, {
        districts,
        communes,
        villages
      })}
    </div>
  );
};
