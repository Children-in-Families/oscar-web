import React, { useState } from "react";
import { DateInput } from "semantic-ui-calendar-react";
import "./datepicker.scss";

export default (props) => {
  const formatStringToDate = (value) => {
    return value;
  };

  const {
    isError,
    onChange,
    value,
    getCurrentDate,
    T,
    hintText,
    inlineClassName,
    disabled,
    ...others
  } = props;
  const [currentDate, setDate] = useState(value);

  const formatDateToString = (value) => {
    if (value) {
      const formatedDate = value.getDate();
      const formatedMonth = value.getMonth() + 1;
      const formatedYear = value.getFullYear();

      return formatedYear + "-" + formatedMonth + "-" + formatedDate;
    } else return null;
  };

  const onChangeDate = (event, { name, value }) => {
    if (value) {
      onChange({ data: value, type: name });
      setDate(value);
    } else {
      if (value === null) {
        onChange({ data: null, type: "date" });
        setDate(null);
      } else if (value && new Date(value).getFullYear() > 1970) {
        onChange({ data: formatDateToString(new Date(value)), type: "date" });
        setDate(value);
      }
    }
  };

  return (
    <div className="form-group" style={(disabled && styles.notAllow) || {}}>
      <label style={(isError && styles.errorText) || {}}>
        {props.required && <abbr title="required">* </abbr>}
        {props.label}
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
      <DateInput
        className={`${(isError && "error") || ""} calendar-input`}
        placeholder="..../../.."
        name="date"
        dateFormat="YYYY-MM-DD"
        closable
        disabled={disabled}
        clearable={false}
        animation="scale"
        duration={200}
        hideMobileKeyboard
        value={formatStringToDate(currentDate || value)}
        iconPosition="left"
        onChange={onChangeDate}
        minDate={new Date(1899, 12, 1)}
        maxDate={(getCurrentDate && new Date()) || null}
      />
      {isError && (
        <span style={styles.errorText}>
          {T.translate("validation.cannot_blank")}
        </span>
      )}
    </div>
  );
};

const styles = {
  errorText: {
    color: "red",
  },
  errorInput: {
    borderColor: "red",
  },
  box: {
    boxShadow: "none",
  },
  notAllow: {
    cursor: "not-allowed",
  }
};
