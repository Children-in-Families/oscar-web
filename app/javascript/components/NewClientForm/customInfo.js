import React from 'react'
import {
  TextInput,
  SelectInput
} from '../Commons/inputs'

export default props => {
  const { onChange, id, data: { ratePoor, client, T } } = props

  const rateLists = ratePoor.map(rate => ({ label: rate[0], value: rate[1] }))

  return (
    <div id={id} className="collapse">
      <br/>
      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput label={T.translate("customInfo.custom_id_1")} onChange={onChange('client', 'code')} value={client.code} />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput label={T.translate("customInfo.custom_id_2")} onChange={onChange('client', 'kid_id')} value={client.kid_id} />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-5">
          <SelectInput label={T.translate("customInfo.rate_client_id")} options={rateLists} value={client.rated_for_id_poor} onChange={onChange('client', 'rated_for_id_poor')} />
        </div>
      </div>
    </div>
  )
}
