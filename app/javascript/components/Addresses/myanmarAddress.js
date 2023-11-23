import React, { useState, useEffect } from "react";
import { TextInput, SelectInput, TextArea } from "../Commons/inputs";

export default (props) => {
  const {
    onChange,
    disabled,
    outside,
    data: {
      client,
      currentStates,
      objectKey,
      objectData,
      addressTypes,
      currentTownships,
      refereeTownships,
      carerTownships,
      T
    }
  } = props;

  const [states, setStates] = useState(
    currentStates.map((the_state) => ({
      label: the_state.name,
      value: the_state.id
    }))
  );
  const [townships, setTownships] = useState(
    currentTownships.map((township) => ({
      label: township.name,
      value: township.id
    }))
  );
  const [referee_townships, setRefereeTownships] = useState(
    refereeTownships.map((township) => ({
      label: township.name,
      value: township.id
    }))
  );
  const [carer_townships, setCarerTownships] = useState(
    carerTownships.map((township) => ({
      label: township.name,
      value: township.id
    }))
  );
  const typeOfAddress = addressTypes.map((type) => ({
    label: T.translate("addressType." + type.label),
    value: type.value
  }));
  useEffect(() => {
    setTownships(
      currentTownships.map((township) => ({
        label: township.name,
        value: township.id
      }))
    );
    setRefereeTownships(
      refereeTownships.map((township) => ({
        label: township.name,
        value: township.id
      }))
    );
    setCarerTownships(
      carerTownships.map((township) => ({
        label: township.name,
        value: township.id
      }))
    );
  }, [currentTownships, refereeTownships, carerTownships]);

  const updateValues = (object) => {
    const { parent, child, field, obj, data } = object;

    const parentConditions = {
      states: {
        fieldsToBeUpdate: { township_id: null, [field]: data },
        optionsToBeResets: [setTownships]
      },
      townships: {
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
      if (parent !== "townships" && data !== null) {
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
            switch (obj) {
              case "referee":
                dataState = { districts: setRefereeTownships };
                break;
              case "carer":
                dataState = { townships: setCarerTownships };
                break;
              default:
                dataState = { townships: setTownships };
            }
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
          <TextInput
            label={T.translate("address.myanmar.street_line1")}
            disabled={disabled}
            onChange={onChange(objectKey, "street_line1")}
            value={objectData.street_line1}
          />
        </div>

        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            label={T.translate("address.myanmar.street_line2")}
            disabled={disabled}
            onChange={onChange(objectKey, "street_line2")}
            value={objectData.street_line2}
          />
        </div>

        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            label={T.translate("address.myanmar.state")}
            options={states}
            isDisabled={disabled}
            value={objectData.state_id}
            onChange={onChangeParent({
              parent: "states",
              child: "townships",
              obj: objectKey,
              field: "state_id"
            })}
          />
        </div>

        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            label={T.translate("address.myanmar.township")}
            isDisabled={disabled}
            options={townships}
            value={objectData.township_id}
            onChange={onChangeParent({
              parent: "townships",
              child: "townships",
              obj: objectKey,
              field: "township_id"
            })}
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
