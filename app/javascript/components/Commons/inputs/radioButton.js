import React from 'react'
import { RadioGroup, Radio } from 'react-radio-group'

export default props => {
  const { onChange, value } = props

  return (
    <>
      <label>{props.label}</label>
      <div className="row">
        <RadioGroup selectedValue={value} onChange={boolean => onChange({data:boolean, type: 'radio'})}>
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
