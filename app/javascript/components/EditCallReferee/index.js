import React, { useState, useEffect } from "react";
import {
  SelectInput,
  TextInput,
  Checkbox,
  RadioGroup
} from "../Commons/inputs";
import { setDefaultLanguage } from "./helper";
import toastr from "toastr/toastr";
import { confirmCancel } from "../Commons/confirmCancel";

import Address from "../NewCall/address";
import "./styles.scss";
// import TaskModal from "../NewCall/addTaskModal"

export default (props) => {
  const {
    data: {
      call,
      refereeDistricts,
      refereeCommunes,
      refereeVillages,
      referee,
      referees,
      currentProvinces,
      addressTypes
    }
  } = props;

  var url = window.location.href.split("&").slice(-1)[0].split("=")[1];

  let T = setDefaultLanguage(url);

  const [errorFields, setErrorFields] = useState([]);
  const [refereeData, setRefereeData] = useState(referee);
  const [loading, setLoading] = useState(false);

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

  const ageOpts = [
    {
      label: T.translate("editCallReferee.index.ageOpts.18_plus"),
      value: true
    },
    {
      label: T.translate("editCallReferee.index.ageOpts.under_18"),
      value: false
    }
  ];

  const refereeLists = () => {
    let newList = [];
    referees.forEach((r) =>
      newList.push({ label: `${r.name} ${r.phone} ${r.email}`, value: r.id })
    );
    return newList;
  };

  useEffect(() => {
    if (refereeData.anonymous) {
      const fields = {
        anonymous: true,
        outside: false,
        name: T.translate("editCallReferee.index.anonymous"),
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
  }, [refereeData.anonymous]);

  // const renderNameField = () => {
  //   if(refereeData.called_before && !refereeData.anonymous) {
  //     return (
  //       <SelectInput
  //         T={T}
  //         label="Name"
  //         required
  //         isDisabled={refereeData.anonymous}
  //         options={refereeLists()}
  //         onChange={onRefereeNameChange}
  //         isError={errorFields.includes("name")}
  //         value={refereeData.id}
  //       />
  //     )
  //   } else {
  //     return (
  //       <TextInput
  //         T={T}
  //         required
  //         disabled={refereeData.anonymous}
  //         isError={errorFields.includes("name")}
  //         value={refereeData.name}
  //         label="Name"
  //         onChange={(value) => { onChange('referee', 'name')(value); onChange('client', 'name_of_referee')(value) }}
  //       />
  //     )
  //   }
  // }

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
      house_number,
      address_type,
      current_address
    } = referees.filter((r) => r.id == evt.data)[0] || {};
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
      street_number,
      house_number,
      address_type,
      current_address
    })({ type: "select" });
  };

  const handleCancel = () => {
    confirmCancel(toastr, `/calls/${call.id}${window.location.search}`);
  };

  const handleSave = () => {
    if (handleValidation()) {
      $.ajax({
        url: `/api/v1/calls/${call.id}/edit/referee`,
        type: "PUT",
        data: {
          referee: { ...refereeData }
        },
        beforeSend: (req) => {
          setLoading(true);
        }
      })
        .success((response) => {
          const message = T.translate(
            "editCallReferee.index.referee_has_been_updated"
          );
          document.location.href = `/calls/${response.call.id}?notice=${message}&locale=${url}`;
        })
        .error((res) => {
          onerror(res.responseText);
        });
    }
  };

  const handleValidation = () => {
    const validationFields = ["name"];
    const errors = [];

    validationFields.forEach((field) => {
      if (refereeData[field].length <= 0 || refereeData[field] === null) {
        errors.push(field);
      }
    });

    if (errors.length > 0) {
      setErrorFields(errors);
      return false;
    } else {
      setErrorFields([]);
      return true;
    }
  };

  const onChange = (obj, field) => (event) => {
    const inputType = ["date", "select", "checkbox", "radio", "datetime"];
    const value = inputType.includes(event.type)
      ? event.data
      : event.target.value;

    if (typeof field !== "object") field = { [field]: value };

    switch (obj) {
      case "referee":
        setRefereeData({ ...refereeData, ...field });
        break;
    }
  };

  return (
    <div className="containerClass">
      {/* <TaskModal data={{referee, clientTask}} onChange={onChange} /> */}
      <legend>
        <div className="row">
          <div className="col-xs-12 col-md-6">
            <p>{T.translate("editCallReferee.index.caller_info")}</p>
          </div>
        </div>
      </legend>

      <div className="row">
        <div className="col-xs-12 col-sm-6 col-md-3">
          <Checkbox
            label={T.translate("editCallReferee.index.anonymous_referee")}
            checked={refereeData.anonymous || false}
            onChange={onChange("referee", "anonymous")}
          />
        </div>
      </div>

      <br />

      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          {/* {renderNameField()} */}
          <TextInput
            T={T}
            required
            disabled={refereeData.anonymous}
            isError={errorFields.includes("name")}
            value={refereeData.name}
            label={T.translate("editCallReferee.index.name")}
            onChange={(value) => {
              onChange("referee", "name")(value);
            }}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            T={T}
            label={T.translate("editCallReferee.index.gender")}
            isDisabled={refereeData.anonymous}
            options={genderLists}
            onChange={onChange("referee", "gender")}
            value={refereeData.gender}
          />
        </div>
        <div className="col-xs-12 col-md-6">
          <RadioGroup
            inline
            label={T.translate("editCallReferee.index.are_you_over_18")}
            isDisabled={refereeData.anonymous}
            options={ageOpts}
            onChange={onChange("referee", "adult")}
            value={refereeData.adult}
          />
        </div>
      </div>

      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            T={T}
            label={T.translate("newCall.refereeInfo.referee_phone")}
            type="text"
            disabled={refereeData.anonymous}
            onChange={onChange("referee", "phone")}
            value={refereeData.phone}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            T={T}
            label={T.translate("editCallReferee.index.referee_email")}
            disabled={refereeData.anonymous}
            onChange={onChange("referee", "email")}
            value={refereeData.email}
          />
        </div>
      </div>

      <legend>
        <div className="row">
          <div className="col-xs-12 col-md-6 col-lg-3">
            <p>{T.translate("editCallReferee.index.address")}</p>
          </div>
          {!refereeData.anonymous && (
            <div className="col-xs-12 col-md-6 col-lg-3">
              <Checkbox
                label={T.translate("editCallReferee.index.outside_cambodia")}
                checked={refereeData.outside || false}
                onChange={onChange("referee", "outside")}
              />
            </div>
          )}
        </div>
      </legend>

      <Address
        disabled={refereeData.anonymous}
        outside={refereeData.outside || false}
        onChange={onChange}
        data={{
          currentDistricts: refereeDistricts,
          currentCommunes: refereeCommunes,
          currentVillages: refereeVillages,
          currentProvinces,
          addressTypes,
          objectKey: "referee",
          objectData: refereeData,
          T
        }}
      />

      <div className="row">
        <div className="col-sm-12 text-right">
          <span className="btn btn-success form-btn" onClick={handleSave}>
            {T.translate("editCallReferee.index.save")}
          </span>
          <span className="btn btn-default form-btn" onClick={handleCancel}>
            {T.translate("editCallReferee.index.cancel")}
          </span>
        </div>
      </div>
    </div>
  );
};
