import React from 'react'
import {
  TextInput,
  SelectInput
} from '../Commons/inputs'

export default props => {
  const { onChange, id, data: { ratePoor, client, T } } = props

  const rateLists = ratePoor.map(rate => ({ label: rate[0], value: rate[1] }))

  const handleOnChangeText = name => event => modifyClientObject({ [name]: event.target.value })
  const handleOnChangeSelect = name => data => modifyClientObject({ [name]: data.data })

  const modifyClientObject = field => {
    const getObject    = client[0]
    const modifyObject = { ...getObject, ...field }

    const newObjects = client.map((object, indexObject) => {
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
          <TextInput T={T} label="Custom ID Number 1" onChange={handleOnChangeText('code')} value={client[0].code} />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput T={T} label="Custom ID Number 2" onChange={handleOnChangeText('kid_id')} value={client[0].kid_id} />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput T={T} label="Is client rated for ID Poor?" options={rateLists} value={client[0].rated_for_id_poor} onChange={handleOnChangeSelect('rated_for_id_poor')} />
        </div>
      </div>
    </div>
  )
}
