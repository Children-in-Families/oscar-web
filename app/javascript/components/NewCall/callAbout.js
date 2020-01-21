import React from 'react'
import {
  SelectInput,
  TextArea
} from '../Commons/inputs'

export default props => {
  const { onChange, data: { clients, T } } = props
  const client = clients[0]
  const basicNecessities = [
    {
      label: T.translate("newCall.callAbout.basicNecessities.looking_for_help"),
      value: "Looking for health/medical help (including emergencies, pregnancy, other health concerns)."
    },
    {
      label: T.translate("newCall.callAbout.basicNecessities.looking_for_education"),
      value: "Looking for education and material requests for school registration; return to school; need help to stay in school."
    },
    {
      label: T.translate("newCall.callAbout.basicNecessities.looking_for_food"),
      value: "Looking for food, water, milk, shelter support."
    },
    {
      label: T.translate("newCall.callAbout.basicNecessities.looking_for_vocational"),
      value: "Looking for vocational training/employment."
    },
    {
      label: T.translate("newCall.callAbout.basicNecessities.caregivers_looking"),
      value: "Caregivers looking to send their children to an RCI."
    }
  ];

  const childProtectionConcerns = [
    {
      label: T.translate("newCall.callAbout.childProtectionConcerns.physical_violence"),
      value: "Physical violence"
    },
    {
      label: T.translate("newCall.callAbout.childProtectionConcerns.emotional_violence"),
      value: "Emotional violence"
    },
    {
      label: T.translate("newCall.callAbout.childProtectionConcerns.sexual_violence"),
      value: "Sexual violence"
    },
    {
      label: T.translate("newCall.callAbout.childProtectionConcerns.neglect_supervision"),
      value: "Neglect / lack of adult supervision"
    },
    {
      label: T.translate("newCall.callAbout.childProtectionConcerns.resecue_of_trafficking"),
      value: "Rescue of trafficking victim (migration / collaboration with authorities to rescue)"
    },
    {
      label: T.translate("newCall.callAbout.childProtectionConcerns.forced_labour"),
      value: "Forced labour (commercial sex, exploitation, street vending, brick factory, or labour that jeopardizes the wellbeing of a child."
    },
    {
      label: T.translate("newCall.callAbout.childProtectionConcerns.drug_use"),
      value: "Drug use (seeking rehabilitation support)"
    },
    {
      label: T.translate("newCall.callAbout.childProtectionConcerns.alcohol_use"),
      value: "Alcohol use (seeking rehabilitation support)"
    },
    {
      label: T.translate("newCall.callAbout.childProtectionConcerns.separated_child"),
      value: "Separated child - abandoned; lost; street living."
    },
    {
      label: T.translate("newCall.callAbout.childProtectionConcerns.children_and_parent"),
      value: "Children and parent living on the street."
    },
    {
      label: T.translate("newCall.callAbout.childProtectionConcerns.disability"),
      value: "Disability"
    },
    {
      label: T.translate("newCall.callAbout.childProtectionConcerns.other"),
      value: "Other"
    },
  ];

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
    <>
      <legend className='legend'>
        <div className="row">
          <div className="col-md-12 col-lg-9">
            <p>{T.translate("newCall.callAbout.what_is_the_call")}</p>
          </div>
        </div>
      </legend>

      <div className='row'>
        <div className='col-md-12 col-lg-9'>
          <SelectInput
            T={T}
            label={T.translate("newCall.callAbout.basic_necessities")}
            options={basicNecessities}
            value={client.basic_necessity}
            onChange={handleOnChangeSelect('basic_necessity')} />
        </div>
      </div>

      <div className='row'>
        <div className='col-md-12 col-lg-9'>
          <SelectInput
            T={T}
            label={T.translate("newCall.callAbout.child_protection")}
            options={childProtectionConcerns}
            value={client.child_protection_concern}
            onChange={handleOnChangeSelect('child_protection_concern')} />
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
