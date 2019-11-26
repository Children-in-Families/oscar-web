import React from 'react'
import {
  TextInput,
  TextArea
} from '../Commons/inputs'

export default props => {
  const { onChange, id } = props

  return (
    <div id={id} className="collapse">
      <br/>
      <div className="row">
        <div className="col-xs-3">
          <TextInput label="Custom ID Number 1" onChange={onChange('client', 'code')} />
        </div>
        <div className="col-xs-3">
          <TextInput label="Custom ID Number 2" onChange={onChange('client', 'kid_id')} />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-12">
          <TextArea label="Relevant Referral Information / Notes" onChange={onChange('client', 'relevant_referral_information')} />
        </div>
      </div>
    </div>
  )
}
