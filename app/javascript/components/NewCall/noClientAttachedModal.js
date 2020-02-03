import React, { useState } from "react";
import { TextArea } from "../Commons/inputs";

export default props => {
  const {
    onChange,
    onSave,
    closeAction,
    data: { callData, T }
  } = props;

  const handleSave = () => {
    onSave();
  };

  return (
    <>
      <div className="row">
        <div className="col-xs-12">
          <TextArea
            required={ callData.call_type === "Seeking Information" }
            placeholder={T.translate("newCall.noClientAttachedModal.add_note_about_the_content")}
            label={T.translate("newCall.noClientAttachedModal.information_provided")}
            value={callData.information_provided}
            onChange={onChange("call", "information_provided")}
          />
        </div>
        <div className="col-xs-12 text-right">
          <button className="btn btn-default" onClick={closeAction}>
            {T.translate("newCall.noClientAttachedModal.go_back")}
          </button>
          <button
            style={(callData.call_type === "Seeking Information" && callData.information_provided === "" && styles.preventButton) || styles.allowButton}
            onClick={handleSave}
          >
            {T.translate("newCall.noClientAttachedModal.save")}
          </button>
        </div>
      </div>
    </>
  );
};

const styles = {
  allowButton: {
    padding: "0.5em 1em",
    textDecoration: "none",
    borderRadius: "5px",
    margin: "0 0.5em",
    background: "#1AB394",
    color: "#fff",
    cursor: "pointer"
  },
  preventButton: {
    color: "#aaa",
    padding: "0.5em 1em",
    textDecoration: "none",
    borderRadius: "5px",
    margin: "0 0.5em",
    background: "#eee",
    cursor: "not-allowed",
    pointerEvents: "none"
  }
};
