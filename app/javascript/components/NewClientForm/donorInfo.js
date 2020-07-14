import React from 'react'
import {
  SelectInput,
  RadioButton
} from '../Commons/inputs'

export default props => {
  const { onChange, id, hintText, data: { client, donors, agencies, T } } = props
  const donorLists = donors.map(donor => ({label: donor.name, value: donor.id}))
  const agencyLists = agencies.map(agency => ({ label: T.translate("agency."+agency.name), value: agency.id}))

  return (
    <div id={id} className="collapse">
      <br/>
      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            isMulti label={T.translate("donorInfo.other_agencies")}
            options={agencyLists} value={client.agency_ids}
            onChange={onChange('client', 'agency_ids')}
            inlineClassName="donor-involved"
            hintText={hintText.donor.donor_involved}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            isMulti label={T.translate("donorInfo.donor")}
            options={donorLists} value={client.donor_ids}
            onChange={onChange('client', 'donor_ids')}
            inlineClassName="donor-donor"
            hintText={hintText.donor.donor_donor}
          />
        </div>
      </div>
    </div>
  )
}
