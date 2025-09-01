import React, { useEffect, useState } from "react";
import T from "i18n-react";

export default (props) => {
  const {
    isError,
    isLatin,
    label,
    required,
    onChange,
    value,
    hintText,
    errorText,
    inlineClassName,
    inline,
    ...others
  } = props;
  const [newValue, setNewValue] = useState(value);
  const [latin, setLatin] = useState(isLatin);

  useEffect(() => {
    setNewValue(value);
  }, [value]);

  const handleOnChange = (e) => {
    setNewValue(e.target.value);
    if (isLatin !== undefined && isLatin) {
      const latinRegex = /^[A-Za-z0-9 _.,!"'/$]*$/;
      if (e.target.value === "" || latinRegex.test(e.target.value)) {
        setLatin(true);
        if (onChange) onChange(e);
      } else {
        setLatin(false);
        setNewValue("");
      }
    } else {
      if (onChange) onChange(e);
    }
  };

  return (
    <div className="form-group" style={inline && styles.inlineWrapper}>
      <label style={(isError && styles.errorText) || styles.inlineDisplay}>
        {required && <abbr title="required">* </abbr>}
        {label}
      </label>
      {inlineClassName && (
        <a
          tabIndex="0"
          data-toggle="popover"
          role="button"
          data-html="true"
          data-placement="bottom"
          data-trigger="focus"
          data-content={hintText || "N/A"}
        >
          <i
            className={`fa fa-info-circle text-info m-xs ${inlineClassName}`}
          ></i>
        </a>
      )}
      <input
        className="form-control m-t-xs"
        onChange={(e) => handleOnChange(e)}
        {...others}
        value={newValue || ""}
        style={Object.assign({}, isError && styles.errorInput, styles.box)}
      />
      {isError && (
        <span style={styles.errorText}>
          {errorText || T.translate("validation.cannot_blank")}
        </span>
      )}
      {isLatin !== undefined && !latin && (
        <span style={styles.errorText}>
          {T.translate("validation.latin_only")}
        </span>
      )}
    </div>
  );
};

const styles = {
  inlineWrapper: {
    display: "flex",
    flexDirection: "row",
    alignItems: "center"
  },
  errorText: {
    color: "red"
  },
  errorInput: {
    borderColor: "red"
  },
  box: {
    boxShadow: "none",
    lineHeight: "inherit"
  },
  inlineDisplay: {
    display: "inline"
  }
};
