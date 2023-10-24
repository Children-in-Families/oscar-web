import React from "react";

export default (props) => {
  const {
    onChange,
    disabled = false,
    objectKey,
    data,
    dataValue,
    name,
    inlineClassName,
    required,
    isError,
    ...others
  } = props;

  const findCheckedValue = (value) => {
    const objIndex = dataValue.findIndex((obj) => obj.value === value);

    return eval(dataValue[objIndex]?.checked) || false;
  };

  return (
    <div
      className="form-group boolean optional"
      style={{ display: "flex", flexDirection: "column" }}
    >
      <label style={(isError && customError.errorText) || styles.fontBold}>
        {required && <abbr title="required">* </abbr>}
        {props.label}
      </label>
      <ul className="checkbox-list i-checks">
        {data.map(({ label, checked }, index) => {
          return (
            <li key={index} style={{ listStyle: "none" }}>
              <div className="list-item">
                <div className="left-section" style={styles.alignItem}>
                  <input
                    style={styles.checkbox}
                    type="checkbox"
                    id={`custom-checkbox-${index}`}
                    name={name}
                    value={label}
                    data-value={JSON.stringify(dataValue)}
                    checked={findCheckedValue(label)}
                    onChange={onChange}
                  />
                  <label
                    style={styles.font}
                    htmlFor={`custom-checkbox-${index}`}
                  >
                    {label}
                  </label>
                </div>
              </div>
            </li>
          );
        })}
      </ul>
    </div>
  );
};

const styles = {
  font: {
    fontWeight: "normal",
    fontSize: "14px",
    marginBottom: "0px"
  },

  fontBold: {
    fontWeight: "bold",
    fontSize: "14px",
    marginBottom: "0px"
  },

  disabled: {
    color: "#a6a6a6",
    fontWeight: "normal",
    fontSize: "14px"
  },
  checkbox: {
    display: "inline-block",
    cursor: "pointer",
    position: "relative",
    margin: "0px 5px 0px 0px",
    width: "19px",
    height: "19px",
    outline: "none",
    filter: "hue-rotate(285deg)"
  },
  alignItem: {
    margin: "5px",
    padding: "5px",
    alignItems: "center",
    display: "flex"
  }
};

const customError = {
  control: (provided) => ({
    ...provided,
    borderColor: "red"
  }),
  errorText: {
    color: "red"
  }
};
