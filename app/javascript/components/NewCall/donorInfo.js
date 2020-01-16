import React from 'react'
import {
  SelectInput,
  RadioButton
} from '../Commons/inputs'

export default props => {
  const { onChange, id, data: { client, donors, agencies, T } } = props
  const donorLists = donors.map(donor => ({label: donor.name, value: donor.id}))
  const agencyLists = agencies.map(agency => ({ label: T.translate("agency." + agency.name), value: agency.id}))

  return (
    <div id={id} className="collapse">
      <br/>
      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput T={T} isMulti label={T.translate("newCall.donorInfo.other_agencies")} options={agencyLists} value={client.agency_ids} onChange={onChange('client', 'agency_ids')} />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput T={T} isMulti label={T.translate("newCall.donorInfo.donor")} options={donorLists} value={client.donor_ids} onChange={onChange('client', 'donor_ids')} />
        </div>
      </div>
    </div>
  )
}
