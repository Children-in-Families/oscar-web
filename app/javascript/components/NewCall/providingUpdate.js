import React, { useState } from 'react'
import { SelectInput } from "../Commons/inputs";

export default props => {
  const {
    onChange,
    onSave,
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
      <div className="row">
        <div className="col-xs-12">
          <p>Please select client</p>
          <SelectInput
            T={T}
            label=""
            options={providingUpdateClients}
            value={
              (callData.client_ids.length > 0 && callData.client_ids[0]) ||
              null
            }
            onChange={onChangeClient}
          />
        </div>
        <div className="col-xs-12 text-right">
          <button style={showSave && styles.allowButton || styles.preventButton} onClick={handleSave}>Go</button>
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