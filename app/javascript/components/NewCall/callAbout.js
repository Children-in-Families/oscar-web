import React from 'react'
import {
  SelectInput,
  TextArea
} from '../Commons/inputs'

export default props => {
  const { onChange, data: { clients, T, necessities, protection_concerns } } = props
  const client = clients[0]
  const basicNecessities = necessities.map(necessity => ({ label: necessity.content, value: necessity.id }))
  const childProtectionConcerns = protection_concerns.map(concern => ({ label: concern.content, value: concern.id }))

  const handleOnChangeText = name => event => modifyClientObject({ [name]: event.target.value })
  const handleOnChangeSelect = name => data => {
    const modifyObject = { ...client, [name]: data.data }

    const newObjects = clients.map((object, indexObject) => {
      const newObject = indexObject === 0 ? modifyObject : object
      return newObject
    })

    onChange('client', newObjects)({type: 'object'})
  }

  const modifyClientObject = field => {
    const modifyObject = { ...client, ...field }

    const newObjects = clients.map((object, indexObject) => {
      const newObject = indexObject === 0 ? modifyObject : object
      return newObject
    })

    onChange('client', newObjects)({type: 'object'})
  }

  return (
    <>
      <legend className='legend'>
        <div className="row">
          <div className="col-xs-12">
            <p>{T.translate("newCall.callAbout.what_is_the_call")}</p>
          </div>
        </div>
      </legend>

      <div className='row'>
        <div className='col-md-12 col-lg-9'>
          <SelectInput
            T={T}
            isMulti
            label={T.translate("newCall.callAbout.basic_necessities")}
            options={basicNecessities}
            value={client.necessity_ids}
            onChange={handleOnChangeSelect('necessity_ids')} />
        </div>
      </div>

      <div className='row'>
        <div className='col-md-12 col-lg-9'>
          <SelectInput
            T={T}
            isMulti
            label={T.translate("newCall.callAbout.child_protection")}
            options={childProtectionConcerns}
            value={client.protection_concern_ids}
            onChange={handleOnChangeSelect('protection_concern_ids')} />
        </div>
      </div>
      <div className='row'>
        <div className='col-md-12 col-lg-9'>
          <TextArea label={T.translate("newCall.callAbout.enter_a_brief")} value={client.brief_note_summary} onChange={handleOnChangeText('brief_note_summary')} />
        </div>
      </div>
    </>
  )
}
