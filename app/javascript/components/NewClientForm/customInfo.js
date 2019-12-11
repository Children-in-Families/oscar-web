import React from 'react'
import {
  TextInput
} from '../Commons/inputs'

export default props => {
  const { onChange, id, data: { client } } = props

  return (
    <div id={id} className="collapse">
      <br/>
      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput label="Custom ID Number 1" onChange={onChange('client', 'code')} value={client.code} />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput label="Custom ID Number 2" onChange={onChange('client', 'kid_id')} value={client.kid_id} />
        </div>
      </div>
    </div>
  )
}
