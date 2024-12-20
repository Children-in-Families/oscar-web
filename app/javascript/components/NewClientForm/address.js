import React, { useState, useEffect } from "react";
import { TextInput, SelectInput, TextArea } from "../Commons/inputs";
import { t } from "../../utils/i18n";

export default (props) => {
  const {
    onChange,
    disabled,
    current_organization,
    hintText,
    outside,
    translation,
    data: {
      client,
      currentProvinces,
      objectKey,
      objectData,
      addressTypes,
      currentCommunes = [],
      currentDistricts = [],
      currentVillages = [],
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
  const [communes, setCommunes] = useState(
    currentCommunes.map((commune) => ({
      label: commune.name_kh + " / " + commune.name_en,
      value: commune.id
    }))
  );
  const [villages, setVillages] = useState(
    currentVillages.map((village) => ({
      label: village.name_kh + " / " + village.name_en,
      value: village.id
    }))
  );
  const typeOfAddress = addressTypes.map((type) => ({
    label: T.translate("addressType." + type.label),
    value: type.value
  }));

  useEffect(() => {
    setProvinces(
      currentProvinces.map((province) => ({
        label: province.name,
        value: province.id
      }))
    );
    setDistricts(
      currentDistricts.map((district) => ({
        label: district.name,
        value: district.id
      }))
    );
    setCommunes(
      currentCommunes.map((commune) => ({
        label:
          (commune.name && commune.name) ||
          `${commune.name_kh} / ${commune.name_en}`,
        value: commune.id
      }))
    );
    setVillages(
      currentVillages.map((village) => ({
        label:
          (village.name && village.name) ||
          `${village.name_kh} / ${village.name_en}`,
        value: village.id
      }))
    );

    // if(outside) {
    //   onChange(objectKey, { province_id: null, district_id: null, commune_id: null, village_id: null, house_number: '', street_number: '', current_address: '', address_type: '' })({type: 'select'})
    // } else {
    //   onChange(objectKey, { outside_address: '' })({type: 'select'})
    // }
  }, [currentDistricts, currentCommunes, currentVillages]);

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
        optionsToBeResets: [setDistricts, setCommunes, setVillages]
      },
      districts: {
        fieldsToBeUpdate: { commune_id: null, village_id: null, [field]: data },
        optionsToBeResets: [setCommunes, setVillages]
      },
      communes: {
        fieldsToBeUpdate: { village_id: null, [field]: data },
        optionsToBeResets: [setVillages]
      },
      villages: {
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
          dataType: "json",
          type: "GET",
          url: `/api/${parent}/${data}/${child}`,
          contentType: "application/json"
        })
          .success((res) => {
            const formatedData = res.data.map((data) => ({
              label: data.name,
              value: data.id
            }));
            const dataState = {
              districts: setDistricts,
              communes: setCommunes,
              villages: setVillages
            };
            dataState[child](formatedData);
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
            label={t(translation, "clients.confirm_client.province")}
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
            label={t(translation, "clients.show.district")}
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
            hintText={hintText.referee.referral_district}
          />
        </div>

        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            label={t(translation, "clients.show.commune")}
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
            hintText={hintText.referee.referral_commune}
          />
        </div>

        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            label={T.translate("address.village")}
            isDisabled={disabled}
            options={villages}
            value={objectData.village_id}
            onChange={onChangeParent({
              parent: "villages",
              child: "villages",
              obj: objectKey,
              field: "village_id"
            })}
            inlineClassName="village"
            hintText={hintText.referee.referral_village}
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
