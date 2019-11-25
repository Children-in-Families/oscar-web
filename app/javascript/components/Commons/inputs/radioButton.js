import React, { useState } from 'react';
import { RadioGroup, Radio } from 'react-radio-group'

export default props => {
  const [checked, setChecked] = useState({})
  const { onChange } = props

  const handleChecked = boolean => {
    setChecked(boolean)
    onChange(boolean)
  }
  return (
    <>
      <label>{props.label}</label>
      <div className="row">
        <RadioGroup selectedValue={checked} onChange={handleChecked}>
          <div className="col-xs-1">
            <Radio value={true} />
          </div>
          <div className="col-xs-1">
            <label>Yes</label>
          </div>
          <div className="col-xs-1">
            <Radio value={false} />
          </div>
          <div className="col-xs-1">
            <label>No</label>
          </div>
        </RadioGroup>
      </div>
    </>
  )
}
