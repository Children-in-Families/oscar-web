import React from 'react'
import {
  SelectInput,
  TextArea
} from '../Commons/inputs'

export default props => {
  const { onChange, data: { clients, call, T, necessities, protection_concerns } } = props
  const client = clients[0]
  const basicNecessities = necessities.map(necessity => ({ label: T.translate("newCall.callAbout.basicNecessities." + necessity.id), value: necessity.id }))
  const childProtectionConcerns = protection_concerns.map(concern => ({ label: T.translate("newCall.callAbout.childProtectionConcerns." + concern.id), value: concern.id }))

  const handleOnChangeText = name => event => modifyClientObject({ [name]: event.target.value })

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
            value={call.necessity_ids}
            onChange={onChange('call','necessity_ids')} />
        </div>
      </div>

      <div className='row'>
        <div className='col-md-12 col-lg-9'>
          <SelectInput
            T={T}
            isMulti
            label={T.translate("newCall.callAbout.child_protection")}
            options={childProtectionConcerns}
            value={call.protection_concern_ids}
            onChange={onChange('call','protection_concern_ids')} />
        </div>
      </div>
      <div className='row'>
        <div className='col-md-12 col-lg-9'>
          <TextArea label={T.translate("newCall.callAbout.other_more_information")} value={call.other_more_information} onChange={onChange('call','other_more_information')} />
        </div>
      </div>
      <div className='row'>
        <div className='col-md-12 col-lg-9'>
          <TextArea label={T.translate("newCall.callAbout.enter_a_brief")} value={call.brief_note_summary} onChange={onChange('call','brief_note_summary')} />
        </div>
      </div>
    </>
  )
}
