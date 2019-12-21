import React from 'react'
import {
  TextInput,
  SelectInput
} from '../Commons/inputs'

export default props => {
  const { onChange, id, data: { ratePoor, client } } = props

  const rateLists = ratePoor.map(rate => ({ label: rate[0], value: rate[1] }))

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
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput label="Is client rated for ID Poor?" options={rateLists} value={client.rated_for_id_poor} onChange={onChange('client', 'rated_for_id_poor')} />
        </div>
      </div>
    </div>
  )
}
