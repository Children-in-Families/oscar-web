import React, { useState, useEffect } from 'react'
import {
  SelectInput,
  TextInput,
  Checkbox
}             from '../Commons/inputs'
import Address from './address'

export default props => {
  const { onChange, id, data: { client, carer, currentDistricts, currentCommunes, currentVillages, currentProvinces } } = props

  const [sameAsClient, setSameAsClient]   = useState(false)
  const [districts, setDistricts]         = useState(currentDistricts)
  const [communes, setCommunes]           = useState(currentCommunes)
  const [villages, setVillages]           = useState(currentVillages)

  const fetchData = (parent, data, child) => {
    $.ajax({
      type: 'GET',
      url: `/api/${parent}/${data}/${child}`,
    }).success(res => {
      const dataState = { districts: setDistricts, communes: setCommunes, villages: setVillages }
      dataState[child](res.data)
    })
  }

  useEffect(() => {
    if(sameAsClient) {
      fetchData('provinces', client.province_id, 'districts')
      fetchData('districts', client.district_id, 'communes')
      fetchData('communes', client.commune_id, 'villages')
    } else {
      setDistricts([])
      setCommunes([])
      setVillages([])
    }

    const fields = {
      outside: sameAsClient ? client.outside : false,
      province_id: sameAsClient ? client.province_id : null,
      district_id: sameAsClient ? client.district_id : null,
      commune_id: sameAsClient ? client.commune_id : null,
      village_id: sameAsClient ? client.village_id : null,
      street_number: sameAsClient ? client.street_number : '',
      house_number: sameAsClient ? client.house_number : '',
      address: sameAsClient ? client.address : '',
      address_type: sameAsClient ? client.address_type : '',
      outside_address: sameAsClient ? client.outside_address : ''
    }

    onChange('carer', { ...fields })({type: 'select'})
  }, [sameAsClient, client, carer])

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
          {
            !carer.outside &&
            <div className="col-xs-3">
              <Checkbox label="Same as Client" checked={sameAsClient} onChange={({data}) => setSameAsClient(data)} />
            </div>
          }
          {
            !sameAsClient &&
            <div className="col-xs-3">
              <Checkbox label="Outside Cambodia" checked={carer.outside || false} onChange={onChange('carer', 'outside')} />
            </div>
          }
        </div>
      </legend>
      <Address sameAsClient={sameAsClient} outside={carer.outside || false} onChange={onChange} data={{client, currentDistricts: districts, currentCommunes: communes, currentVillages: villages, currentProvinces, objectKey: 'carer', objectData: carer}} />
    </div>
  )
}
