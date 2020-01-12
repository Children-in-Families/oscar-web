import React, { useEffect, useState } from "react";
import { SelectInput, TextInput, Checkbox, RadioGroup } from "../Commons/inputs";
import Address from "./address";

export default props => {
  const {
    onChange,
    data: {
      refereeDistricts,
      refereeCommunes,
      refereeVillages,
      referee,
      client,
      currentProvinces,
      referralSourceCategory,
      referralSource,
      errorFields,
      addressTypes, T
    }
  } = props;

  const genderLists = [
    { label: "Female", value: "female" },
    { label: "Male", value: "male" },
    { label: "Other", value: "other" },
    { label: "Unknown", value: "unknown" }
  ];
  const answeredCallOpts = [
    { label: "Answered Call", value: true },
    { label: "Returning Missed Call", value: false }
  ];
  const ageOpts = [
    { label: "18+", value: true },
    { label: "Under 18", value: false }
  ];
  const calledBeforeOpts = [
    { label: "Yes", value: true },
    { label: "No", value: false }
  ];
  const referralSourceCategoryLists = referralSourceCategory.map(category => ({
    label: category[0],
    value: category[1]
  }));
  const referralSourceLists = referralSource
    .filter(
      source =>
        source.ancestry !== null &&
        source.ancestry == client.referral_source_category_id
    )
    .map(source => ({ label: source.name, value: source.id }));

  useEffect(() => {
    if (referee.anonymous) {
      const fields = {
        anonymous: true,
        outside: false,
        name: "Anonymous",
        phone: "",
        email: "",
        gender: "",
        street_number: "",
        house_number: "",
        current_address: "",
        outside_address: "",
        address_type: "",
        province_id: null,
        district_id: null,
        commune_id: null,
        village_id: null
      };
      onChange("referee", { ...fields })({ type: "select" });
    }
  }, [referee.anonymous]);

  const onReferralSourceCategoryChange = data => {
    onChange("client", {
      referral_source_category_id: data.data,
      referral_source_id: null
    })({ type: "select" });
  };

  return (
    <div className="containerClass">
      <legend>
        <div className="row">
          <div className="col-xs-12 col-md-6 col-lg-3">
            <p>Caller Information</p>
          </div>
        </div>
      </legend>

      <div className="row">
        <div className="col-xs-12">
          {/* todo: add required */}
          <RadioGroup
            inline
            required
            isError={errorFields.includes("answered_call")}
            onChange={onChange("referee", "answered_call")}
            options={answeredCallOpts}
            label="Did you answer this call, or are you returning a missed call?"
            value={referee.answered_call}
          />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-12">
          {/* todo: add required */}
          <RadioGroup
            inline
            required
            isError={errorFields.includes("called_before")}
            label="Have you called the Childsafe Hotline Before?"
            options={calledBeforeOpts}
            onChange={onChange("referee", "called_before")}
            value={referee.called_before}
          />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-12 col-sm-6 col-md-3">
          <Checkbox
            label="Anonymous Referee"
            checked={referee.anonymous || false}
            onChange={onChange("referee", "anonymous")}
          />
        </div>
      </div>
      <br />
      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            T={T}
            required
            disabled={referee.anonymous}
            isError={errorFields.includes("name")}
            value={referee.name}
            label="Name"
            onChange={(value) => { onChange('referee', 'name')(value); onChange('client', 'name_of_referee')(value) }}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            T={T}
            label="Gender"
            isDisabled={referee.anonymous}
            options={genderLists}
            onChange={onChange("referee", "gender")}
            value={referee.gender}
          />
        </div>
        <div className="col-xs-12 col-md-6">
          <RadioGroup
            inline
            label="Are you over 18 years old?"
            isDisabled={referee.anonymous}
            options={ageOpts}
            onChange={onChange("referee", "adult")}
            value={referee.adult}
          />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            T={T}
            label="Referee Phone Number"
            type="number"
            disabled={referee.anonymous}
            onChange={onChange("referee", "phone")}
            value={referee.phone}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            T={T}
            label="Referee Email Address"
            disabled={referee.anonymous}
            onChange={onChange("referee", "email")}
            value={referee.email}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            T={T}
            required
            isError={errorFields.includes("referral_source_category_id")}
            label="Referral Source Catgeory"
            options={referralSourceCategoryLists}
            value={client.referral_source_category_id}
            onChange={onReferralSourceCategoryChange}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            T={T}
            options={referralSourceLists}
            label="Referral Source"
            onChange={onChange("client", "referral_source_id")}
            value={client.referral_source_id}
          />
        </div>
      </div>
      <legend>
        <div className="row">
          <div className="col-xs-12 col-md-6 col-lg-3">
            <p>Address</p>
          </div>
          {!referee.anonymous && (
            <div className="col-xs-12 col-md-6 col-lg-3">
              <Checkbox
                label="Outside Cambodia"
                checked={referee.outside || false}
                onChange={onChange("referee", "outside")}
              />
            </div>
          )}
        </div>
      </legend>
      <Address
        disabled={referee.anonymous}
        outside={referee.outside || false}
        onChange={onChange}
        data={{
          currentDistricts: refereeDistricts,
          currentCommunes: refereeCommunes,
          currentVillages: refereeVillages,
          currentProvinces,
          addressTypes,
          objectKey: "referee",
          objectData: referee,
          T
        }}
      />
      <div className="row">
        <div className="col-xs-12">
          <Checkbox
            label="This caller has requested an update on the case after intervention is completed."
            checked={referee.requested_update || false}
            onChange={onChange("referee", "requested_update")}
          />
        </div>
      </div>
    </div>
  );
};
