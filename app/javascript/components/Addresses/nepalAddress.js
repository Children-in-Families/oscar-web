import React, { useState, useEffect } from "react";
import _ from "lodash";
import { TextInput, SelectInput, TextArea } from "../Commons/inputs";

export default (props) => {
  const {
    onChange,
    disabled,
    current_organization,
    hintText,
    outside,
    data: {
      client,
      currentProvinces,
      objectKey,
      objectData,
      addressTypes,
      currentCommunes = [],
      currentDistricts = [],
      T,
      inlineClassName,
      ...others
    }
  } = props;

  const [provinces, setProvinces] = useState(
    currentProvinces.map((province) => ({
      label: province.name,
      value: province.id
    }))
  );
  const [districts, setDistricts] = useState(
    currentDistricts.map((district) => ({
      label: district.name,
      value: district.id
    }))
  );

  const groupCommune = (data) => {
    const communeGroup = _.groupBy(data, (n) => n.district_type);
    return Object.keys(communeGroup).map((key) => ({
      label: key,
      options: communeGroup[key].map((value) => ({
        label: value.name || value.name_en,
        value: value.id
      }))
    }));
  };

  const [communes, setCommunes] = useState(groupCommune(currentCommunes));
  const typeOfAddress = addressTypes.map((type) => ({
    label: T.translate("addressType." + type.label),
    value: type.value
  }));
  useEffect(() => {
    setDistricts(
      currentDistricts.map((district) => ({
        label: district.name,
        value: district.id
      }))
    );
    setCommunes(groupCommune(currentCommunes));

    // if(outside) {
    //   onChange(objectKey, { province_id: null, district_id: null, commune_id: null, village_id: null, house_number: '', street_number: '', current_address: '', address_type: '' })({type: 'select'})
    // } else {
    //   onChange(objectKey, { outside_address: '' })({type: 'select'})
    // }
  }, [currentDistricts, currentCommunes]);

  const updateValues = (object) => {
    const { parent, child, field, obj, data } = object;

    const parentConditions = {
      provinces: {
        fieldsToBeUpdate: {
          district_id: null,
          commune_id: null,
          village_id: null,
          [field]: data
        },
        optionsToBeResets: [setDistricts, setCommunes]
      },
      districts: {
        fieldsToBeUpdate: { commune_id: null, village_id: null, [field]: data },
        optionsToBeResets: [setCommunes]
      },
      communes: {
        fieldsToBeUpdate: { [field]: data },
        optionsToBeResets: []
      }
    };

    onChange(
      obj,
      parentConditions[parent].fieldsToBeUpdate
    )({ type: "select" });

    if (data === null)
      parentConditions[parent].optionsToBeResets.forEach((func) => func([]));
  };

  const onChangeParent =
    (object) =>
    ({ data }) => {
      const { parent, child } = object;

      updateValues({ ...object, data });

      if (parent !== "villages" && data !== null) {
        $.ajax({
          type: "GET",
          url: `/api/${parent}/${data}/${child}`
        })
          .success((res) => {
            let formatedData = undefined;
            if (parent === "districts") formatedData = groupCommune(res.data);
            else
              formatedData = res.data.map((data) => ({
                label: data.name || data.name_en,
                value: data.id
              }));

            const dataState = {
              districts: setDistricts,
              communes: setCommunes
            };
            dataState[child] && dataState[child](formatedData);
          })
          .error((res) => {
            onerror(res.responseText);
          });
      }
    };
  return outside == true ? (
    <TextArea
      label={T.translate("address.outside_address")}
      disabled={disabled}
      value={objectData.outside_address}
      onChange={onChange(objectKey, "outside_address")}
    />
  ) : (
    <>
      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            label={T.translate("address.nepal.province")}
            options={provinces}
            isDisabled={disabled}
            value={objectData.province_id}
            onChange={onChangeParent({
              parent: "provinces",
              child: "districts",
              obj: objectKey,
              field: "province_id"
            })}
            inlineClassName="referree-province"
            hintText={hintText.referee.referral_province}
          />
        </div>

        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            label={T.translate("address.nepal.district")}
            isDisabled={disabled}
            options={districts}
            value={objectData.district_id}
            onChange={onChangeParent({
              parent: "districts",
              child: "communes",
              obj: objectKey,
              field: "district_id"
            })}
            inlineClassName="referree-districs"
            hintText={hintText.referee.referral_province}
          />
        </div>

        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            asGroup
            label={T.translate("address.nepal.municipality")}
            isDisabled={disabled}
            options={communes}
            value={objectData.commune_id}
            onChange={onChangeParent({
              parent: "communes",
              child: "villages",
              obj: objectKey,
              field: "commune_id"
            })}
            inlineClassName="referree-commune"
            hintText={hintText.referee.referral_districs}
          />
        </div>

        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            label={T.translate("address.locality")}
            disabled={disabled}
            onChange={onChange(objectKey, "locality")}
            value={objectData.locality}
          />
        </div>
      </div>

      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            label={T.translate("address.street_number")}
            disabled={disabled}
            onChange={onChange(objectKey, "street_number")}
            value={objectData.street_number}
          />
        </div>

        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            label={T.translate("address.house_number")}
            disabled={disabled}
            onChange={onChange(objectKey, "house_number")}
            value={objectData.house_number}
          />
        </div>

        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            label={T.translate("address.address_name")}
            disabled={disabled}
            onChange={onChange(objectKey, "current_address")}
            value={objectData.current_address}
          />
        </div>

        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            label={T.translate("address.address_type")}
            isDisabled={disabled}
            options={typeOfAddress}
            onChange={onChange(objectKey, "address_type")}
            value={objectData.address_type}
          />
        </div>
      </div>
    </>
  );
};
