import React from 'react'
import {
  SelectInput,
  TextInput,
  Checkbox
}             from '../Commons/inputs'
import Address from './address'

export default props => {
  const { onChange, id, data: { client, carer, currentDistricts, currentCommunes, currentVillages, currentProvinces } } = props
  const blank = []
  const genderLists = [{label: 'Female', value: 'female'}, {label: 'Male', value: 'male'}, {label: 'Other', value: 'other'}, {label: 'Unknown', value: 'unknown'}]

  return (
    <div id={id} className="collapse">
      <br/>
      <div className="row">
        <div className="col-xs-3">
          {/* will change to carer object */}
          <TextInput label="Name" onChange={onChange('client', 'live_with')} value={client.live_with} />
        </div>
        <div className="col-xs-3">
          <SelectInput label="Gender" options={genderLists} onChange={onChange('carer', 'gender')} value={carer.gender}  />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-3">
          {/* will change to carer object */}
          <TextInput label="Carer Phone Number" onChange={onChange('client', 'telephone_number')} value={client.telephone_number}/>
        </div>
        <div className="col-xs-3">
          <TextInput label="Carer Email Address" onChange={onChange('carer', 'email')} value={carer.email} />
        </div>
        <div className="col-xs-3">
          <SelectInput label="Relationship to Client" options={blank} onChange={onChange('carer', 'relationship')} value={carer.relationship} />
        </div>
        <div className="col-xs-3">
          <SelectInput label="Family Record" options={blank} onChange={onChange('carer', 'family')} value={carer.family} />
        </div>
      </div>
      <legend>
        <div className="row">
          <div className="col-xs-3">
            <p>Address</p>
          </div>
          <div className="col-xs-3">
            <Checkbox label="Same as Client" checked={carer.same_as_client} onChange={onChange('carer', 'same_as_client')} />
          </div>
          <div className="col-xs-3">
            <Checkbox label="Outside Cambodia" checked={carer.outside || false} onChange={onChange('carer', 'outside')} />
          </div>
        </div>
      </legend>
      <Address checked={carer.outside || false} onChange={onChange} data={{currentDistricts, currentCommunes, currentVillages, currentProvinces, objectKey: 'carer', objectData: carer}} />
    </div>
  )
}
