import React from 'react'
import {
  SelectInput,
  RadioButton
} from '../Commons/inputs'

export default props => {
  const { onChange, id, data: { client, donors, agencies, T } } = props
  const donorLists = donors.map(donor => ({label: donor.name, value: donor.id}))
  const agencyLists = agencies.map(agency => ({label: agency.name, value: agency.id}))

  const handleOnChangeSelect = name => data => {
    const field = { [name]: data.data }
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
          <SelectInput T={T} isMulti label="Other Agencies Involved" options={agencyLists} value={client[0].agency_ids} onChange={handleOnChangeSelect('agency_ids')} />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput T={T} isMulti label="Donor" options={donorLists} value={client[0].donor_ids} onChange={handleOnChangeSelect('donor_ids')} />
        </div>
      </div>
    </div>
  )
}
