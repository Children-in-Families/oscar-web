import React, { useState, useEffect } from "react";
import { TextInput, SelectInput, TextArea } from "../Commons/inputs";

export default (props) => {
  const {
    onChange,
    disabled,
    outside,
    data: {
      client,
      objectKey,
      objectData,
      addressTypes,
      currentProvinces,
      currentCities,
      currentDistricts,
      subDistricts,
      T
    }
  } = props;

  const [provinces, setProvinces] = useState(
    currentProvinces.map((province) => ({
      label: province.name,
      value: province.id
    }))
  );

  const [cities, setCities] = useState(
    currentCities.map((city) => ({ label: city.name, value: city.id }))
  );

  const [districts, setDistricts] = useState(
    currentDistricts.map((district) => ({
      label: district.name,
      value: district.id
    }))
  );
  const [subdistricts, setSubDistricts] = useState(
    subDistricts.map((subDistrict) => ({
      label: subDistrict.name,
      value: subDistrict.id
    }))
  );
  // const [referee_districts, setRefereeDistricts] = useState(
  //   refereeDistricts.map((district) => ({
  //     label: district.name,
  //     value: district.id
  //   }))
  // );
  // const [referee_subdistricts, setRefereeSubDistricts] = useState(
  //   refereeSubdistricts.map((subdistrict) => ({
  //     label: subdistrict.name,
  //     value: subdistrict.id
  //   }))
  // );

  // const [carer_districts, setCarerDistricts] = useState(
  //   carerDistricts.map((district) => ({
  //     label: district.name,
  //     value: district.id
  //   }))
  // );
  // const [carer_subdistricts, setCarerSubdistricts] = useState(
  //   carerSubdistricts.map((subdistrict) => ({
  //     label: subdistrict.name,
  //     value: subdistrict.id
  //   }))
  // );

  const typeOfAddress = addressTypes.map((type) => ({
    label: T.translate("addressType." + type.label),
    value: type.value
  }));

  useEffect(() => {
    setCities(
      currentCities.map((city) => ({
        label: city.name,
        value: city.id
      }))
    );

    setDistricts(
      currentDistricts.map((district) => ({
        label: district.name,
        value: district.id
      }))
    );

    setSubDistricts(
      subDistricts.map((subDistrict) => ({
        label: subDistrict.name && subDistrict.name,
        value: subDistrict.id
      }))
    );
  }, [currentCities, currentDistricts, currentProvinces]);

  const updateValues = (object) => {
    const { parent, child, field, obj, data } = object;

    const parentConditions = {
      provinces: {
        fieldsToBeUpdate: {
          city_id: null,
          district_id: null,
          subdistrict_id: null,
          [field]: data
        },
        optionsToBeResets: [setCities, setDistricts, setSubDistricts]
      },
      cities: {
        fieldsToBeUpdate: {
          district_id: null,
          subdistrict_id: null,
          [field]: data
        },
        optionsToBeResets: [setDistricts, setSubDistricts]
      },
      districts: {
        fieldsToBeUpdate: { subdistrict_id: null, [field]: data },
        optionsToBeResets: [setSubDistricts]
      },
      subdistricts: {
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
      const { parent, child, obj } = object;

      updateValues({ ...object, data });

      if (parent !== "subdistricts" && data !== null) {
        $.ajax({
          type: "GET",
          url: `/api/${parent}/${data}/${child}`
        })
          .success((res) => {
            let dataState = {};
            const formatedData = res.data.map((data) => ({
              label: data.name,
              value: data.id
            }));

            dataState = {
              cities: setCities,
              districts: setDistricts,
              subdistricts: setSubDistricts
            };

            dataState[child](formatedData);
          })
          .error((res) => {
            onerror(res.responseText);
          });
      }
    };

  const handleDistrictOptions = (obj, district) => {
    const is_district = district == "district";
    // switch (obj) {
    //   case "referee":
    //     return is_district ? referee_districts : referee_subdistricts;
    //     break;
    //   case "carer":
    //     return is_district ? carer_districts : carer_subdistricts;
    //     break;
    //   default:
    //     return is_district ? districts : subdistricts;
    // }
    return is_district ? districts : subdistricts;
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
        <div className="col-xs-12 col-md-3 col-lg-3">
          <SelectInput
            label={T.translate("address.indonesia.province")}
            options={provinces}
            isDisabled={disabled}
            value={objectData.province_id}
            onChange={onChangeParent({
              parent: "provinces",
              child: "cities",
              obj: objectKey,
              field: "province_id"
            })}
          />
        </div>

        <div className="col-xs-12 col-md-3 col-lg-3">
          <SelectInput
            label={T.translate("address.indonesia.city")}
            isDisabled={disabled}
            options={cities}
            value={objectData.district_id}
            onChange={onChangeParent({
              parent: "cities",
              child: "districts",
              obj: objectKey,
              field: "city_id"
            })}
          />
        </div>

        <div className="col-xs-12 col-md-3 col-lg-3">
          <SelectInput
            label={T.translate("address.indonesia.district")}
            isDisabled={disabled}
            options={handleDistrictOptions(objectKey, "district")}
            value={objectData.district_id}
            onChange={onChangeParent({
              parent: "districts",
              child: "subdistricts",
              obj: objectKey,
              field: "district_id"
            })}
          />
        </div>

        <div className="col-xs-12 col-md-3 col-lg-3">
          <SelectInput
            label={T.translate("address.indonesia.subdistrict")}
            isDisabled={disabled}
            options={handleDistrictOptions(objectKey, "subdistrict")}
            value={objectData.subdistrict_id}
            onChange={onChangeParent({
              parent: "subdistricts",
              child: "subdistricts",
              obj: objectKey,
              field: "subdistrict_id"
            })}
          />
        </div>
      </div>

      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            label={T.translate("address.indonesia.postal_code")}
            disabled={disabled}
            onChange={onChange(objectKey, "postal_code")}
            value={objectData.postal_code}
          />
        </div>

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
      </div>

      <div className="row">
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
