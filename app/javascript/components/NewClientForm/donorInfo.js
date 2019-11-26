import React from 'react'
import {
  SelectInput,
  RadioButton
} from '../Commons/inputs'

export default props => {
  const { onChange, id, data: { donors, agencies } } = props
  const donorLists = donors.map(donor => ({label: donor.name, value: donor.id}))
  const agencyLists = agencies.map(agency => ({label: agency.name, value: agency.id}))

  return (
    <div id={id} className="collapse">
      <br/>
      <div className="row">
        <div className="col-xs-3">
          <SelectInput label="Other Agencies Involved" options={agencyLists} onChange={onChange('client', 'agency_ids')} />
        </div>
        <div className="col-xs-3">
          <SelectInput isMulti label="Donor" options={donorLists} onChange={onChange('client', 'donor_id')} />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-4">
          <RadioButton label="Has the client lived in an orphanage?" onChange={onChange('client', 'has_been_in_orphanage')} />
        </div>
        <div className="col-xs-4">
          <RadioButton label="Has the client lived in government care?" onChange={onChange('client', 'has_been_in_government_care')} />
        </div>
      </div>
    </div>
  )
}
