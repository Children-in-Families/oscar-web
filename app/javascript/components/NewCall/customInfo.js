import React from 'react'
import {
  TextInput,
  SelectInput
} from '../Commons/inputs'

export default props => {
  const { onChange, id, data: { errorFields, ratePoor, clients, T } } = props
  const client = clients[0]
  const rateLists = ratePoor.map(rate => ({ label: rate[0], value: rate[1] }))

  const handleOnChangeText = name => event => modifyClientObject({ [name]: event.target.value })
  const handleOnChangeSelect = name => data => modifyClientObject({ [name]: data.data })

  const modifyClientObject = field => {
    const modifyObject = { ...client, ...field }

    const newObjects = clients.map((object, indexObject) => {
      const newObject = indexObject === 0 ? modifyObject : object
      return newObject
    })

    onChange('client', newObjects)({type: 'object'})
  }

  return (
    <div id={id} className="collapse">
      <br/>
      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput T={T} label={T.translate("newCall.customInfo.custom_id_1")} onChange={handleOnChangeText('code')} value={client.code} />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput T={T} label={T.translate("newCall.customInfo.custom_id_2")} onChange={handleOnChangeText('kid_id')} value={client.kid_id} isError={errorFields.includes('kid_id')} errorText={errorFields.includes('kid_id') && T.translate("customInfo.has_already_taken")}/>
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput T={T} label={T.translate("newCall.customInfo.is_client_rated")} options={rateLists} value={client.rated_for_id_poor} onChange={handleOnChangeSelect('rated_for_id_poor')} />
        </div>
      </div>
    </div>
  )
}
