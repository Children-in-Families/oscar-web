import React from 'react'
import {
  SelectInput,
  TextArea
} from '../Commons/inputs'

export default props => {
  const { onChange, data: { client, T } } = props
  const basicNecessities = [
    {
      label: "Looking for health/medical help (including emergencies, pregnancy, other health concerns).",
      value: "Looking for health/medical help (including emergencies, pregnancy, other health concerns)."
    },
    {
      label: "Looking for education and material requests for school registration; return to school; need help to stay in school.",
      value: "Looking for education and material requests for school registration; return to school; need help to stay in school."
    },
    {
      label: "Looking for food, water, milk, shelter support.",
      value: "Looking for food, water, milk, shelter support."
    },
    {
      label: "Looking for vocational training/employment.",
      value: "Looking for vocational training/employment."
    },
    {
      label: "Caregivers looking to send their children to an RCI.",
      value: "Caregivers looking to send their children to an RCI."
    }
  ];

  const childProtectionConcerns = [
    {
      label: "Physical violence",
      value: "Physical violence"
    },
    {
      label: "Emotional violence",
      value: "Emotional violence"
    },
    {
      label: "Sexual violence",
      value: "Sexual violence"
    },
    {
      label: "Neglect / lack of adult supervision",
      value: "Neglect / lack of adult supervision"
    },
    {
      label: "Rescue of trafficking victim (migration / collaboration with authorities to rescue)",
      value: "Rescue of trafficking victim (migration / collaboration with authorities to rescue)"
    },
    {
      label: "Forced labour (commercial sex, exploitation, street vending, brick factory, or labour that jeopardizes the wellbeing of a child.",
      value: "Forced labour (commercial sex, exploitation, street vending, brick factory, or labour that jeopardizes the wellbeing of a child."
    },
    {
      label: "Drug use (seeking rehabilitation support)",
      value: "Drug use (seeking rehabilitation support)"
    },
    {
      label: "Alcohol use (seeking rehabilitation support)",
      value: "Alcohol use (seeking rehabilitation support)"
    },
    {
      label: "Separated child - abandoned; lost; street living.",
      value: "Separated child - abandoned; lost; street living."
    },
    {
      label: "Children and parent living on the street.",
      value: "Children and parent living on the street."
    },
    {
      label: "Disability",
      value: "Disability"
    },
    {
      label: "Other",
      value: "Other"
    },
  ];

  return (
    <>
      <legend className='legend'>
        <div className="row">
          <div className="col-md-12 col-lg-9">
            <p>What is the call about / seeking support for?</p>
          </div>
        </div>
      </legend>

      <div className='row'>
        <div className='col-md-12 col-lg-9'>
          <SelectInput
            T={T}
            label='Basic Necessities'
            options={basicNecessities}
            value={client.basic_necessity}
            onChange={onChange('client', 'basic_necessity')} />
        </div>
      </div>

      <div className='row'>
        <div className='col-md-12 col-lg-9'>
          <SelectInput
            T={T}
            label='Child Protection Concerns'
            options={childProtectionConcerns}
            value={client.child_protection_concern}
            onChange={onChange('client','child_protection_concern')} />
        </div>
      </div>
      <div className='row'>
        <div className='col-md-12 col-lg-9'>
          <TextArea label="Enter a brief note summarising the call" value={client.brief_note_summary} onChange={onChange('client', 'brief_note_summary')} />
        </div>
      </div>
    </>
  )
}
