import React, { useState } from 'react'
import { SelectInput } from "../Commons/inputs";

export default props => {
  const {
    onChange,
    onSave,
    closeAction,
    data: { providingUpdateClients, callData, T }
  } = props;

  const [showSave, setShowSave] = useState(false)

  const onChangeClient = ({ data, action, type }) => {
    let value = [];
    if (action === "select-option") {
      value.push(data);
      setShowSave(true)
    } else if (action === "clear") {
      value = [];
      setShowSave(false)
    }
    onChange("call", "client_ids")({ data: value, type });
  };

  const handleSave = () => {
    onSave()
  }

  return (
    <>
      <div className="row" style={{minHeight: 300}}>
        <div className="col-xs-12">
          <SelectInput
            required
            T={T}
            label={T.translate("newCall.providingUpdate.please_select_client")}
            options={providingUpdateClients}
            value={
              (callData.client_ids.length > 0 && callData.client_ids[0]) ||
              null
            }
            onChange={onChangeClient}
          />
        </div>
        <div className="col-xs-12 text-right">
          <button className="btn btn-default" onClick={closeAction}>{T.translate("newCall.providingUpdate.go_back")}</button>
          <button style={showSave && styles.allowButton || styles.preventButton} onClick={handleSave}>{T.translate("newCall.providingUpdate.go")}</button>
        </div>
      </div>
    </>
  );
};

const styles = {
  allowButton: {
    padding: '0.5em 1em',
    textDecoration: 'none',
    borderRadius: '5px',
    margin: '0 0.5em',
    background: '#1AB394',
    color: '#fff',
    cursor: 'pointer'
  },
  preventButton: {
    color: '#aaa',
    padding: '0.5em 1em',
    textDecoration: 'none',
    borderRadius: '5px',
    margin: '0 0.5em',
    background: '#eee',
    cursor: 'not-allowed',
    pointerEvents: 'none'
  }
}
