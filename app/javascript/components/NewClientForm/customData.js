import React from "react";
import {
  SelectInput,
  TextArea,
  TextInput,
  Checkbox,
  RadioGroup,
  DateInput,
  FileUploadInput
} from "../Commons/inputs";
import CheckboxGroup from "../Commons/inputs/checkboxGroup";

export default (props) => {
  const {
    onChange,
    customData,
    clientCustomData,
    setClientCustomData,
    errorFields,
    T
  } = props;

  const onAttachmentsChange = (field, id) => (fileItems) => {
    fileItems = fileItems.map((file) => file.file);
    setClientCustomData((prev) => {
      const files = prev._attachments || {};
      files[field.split("-")[1]] = { name: field, file: fileItems };
      if (prev[field]?.id) files[field.split("-")[1]].id = prev[field]?.id;

      return { ...prev, _attachments: files };
    });
  };

  const onCheckBoxChange = (event) => {
    const currentTarget = event.currentTarget;
    const dataValue = JSON.parse(
      currentTarget.getAttribute("data-value") || "[]"
    );

    const objIndex = dataValue.findIndex(
      (obj) => obj.value === currentTarget.value
    );

    // Make sure to avoid incorrect replacement
    // When specific item is not found
    if (objIndex === -1) {
      dataValue.push(currentTarget.value);
      setClientCustomData((prev) => {
        return {
          ...prev,
          [currentTarget.name]: dataValue
        };
      });
    } else {
      // make new object of updated object.
      const updatedObj = [...dataValue[objIndex], currentTarget.value];

      // make final new array of objects by combining updated object.
      const newObj = [
        ...dataValue.slice(0, objIndex),
        updatedObj,
        ...dataValue.slice(objIndex + 1)
      ];
      setClientCustomData((prev) => {
        return { ...prev, [currentTarget.name]: newObj };
      });
    }
  };

  const renderCustomDataFields = () => {
    return customData.map((element, index) => {
      return (
        <div className="row" key={`${element.name}-${index}`}>
          <div className="col-xs-12 col-md-12 col-lg-12">
            {(element.type === "text" || element.type === "number") && (
              <TextInput
                {...element}
                T={T}
                onChange={onChange("custom_data", element.name)}
                value={clientCustomData[element.name]}
                isError={errorFields.includes(element.name)}
              />
            )}

            {element.type === "select" && (
              <SelectInput
                T={T}
                required={element.required}
                onChange={onChange("custom_data", element.name)}
                options={element.values}
                label={element.label}
                isMulti={element.multiple}
                value={clientCustomData[element.name]}
                isError={errorFields.includes(element.name)}
              />
            )}

            {element.type === "date" && (
              <DateInput
                {...element}
                T={T}
                isError={errorFields.includes(element.name)}
                onChange={onChange("custom_data", element.name)}
                value={clientCustomData[element.name]}
              />
            )}

            {element.type === "checkbox-group" && (
              <CheckboxGroup
                dataValue={
                  Array.isArray(clientCustomData[element.name])
                    ? clientCustomData[element.name]
                    : []
                }
                required={element.required}
                data={element.values}
                label={element.label}
                onChange={onCheckBoxChange}
                name={element.name}
                isError={errorFields.includes(element.name)}
              />
            )}

            {element.type === "radio-group" && (
              <RadioGroup
                label={element.label}
                T={T}
                onChange={onChange("custom_data", element.name)}
                options={element.values}
                value={clientCustomData[element.name]}
                isError={errorFields.includes(element.name)}
              />
            )}

            {element.type === "textarea" && (
              <TextArea
                {...element}
                T={T}
                onChange={onChange("custom_data", element.name)}
                value={clientCustomData[element.name]}
                isError={errorFields.includes(element.name)}
              />
            )}

            {element.type === "paragraph" && (
              <p>
                <strong>{element.label}</strong>
              </p>
            )}

            {element.type === "file" && (
              <div className="form-group">
                <FileUploadInput
                  onChange={onAttachmentsChange(
                    element.name,
                    clientCustomData[element.name]?.id
                  )}
                  object={clientCustomData[element.name]?.files || []}
                  // removeAttachmentcheckBoxValue={
                  //   client.remove_national_id_files
                  // }
                  T={T}
                  label={element.label}
                  required={element.required}
                  showFilePond={true}
                  isError={errorFields.includes(element.name)}
                />
              </div>
            )}

            {element.type === "separateLine" && <hr />}
          </div>
        </div>
      );
    });
  };

  return <div>{renderCustomDataFields()}</div>;
};
