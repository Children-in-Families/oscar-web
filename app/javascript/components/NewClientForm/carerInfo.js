import React, { useState, useEffect } from 'react'
import {
  SelectInput,
  TextInput,
  Checkbox
}             from '../Commons/inputs'
import Address from './address'

export default props => {
  const { onChange, id, data: { carerDistricts, carerCommunes, carerVillages, client, carer, clientRelationships, currentProvinces, families, addressTypes } } = props

  const [sameAsClient, setSameAsClient]   = useState(false)
  const [districts, setDistricts]         = useState(carerDistricts)
  const [communes, setCommunes]           = useState(carerCommunes)
  const [villages, setVillages]           = useState(carerVillages)

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
    let object = carer

    if(sameAsClient) {
      object = client
      if(client.province_id !== null)
        fetchData('provinces', client.province_id, 'districts')
      if(client.district_id !== null)
        fetchData('districts', client.district_id, 'communes')
      if(client.commune_id !== null)
        fetchData('communes', client.commune_id, 'villages')
    }

    const fields = {
      outside: object.outside,
      province_id: object.province_id,
      district_id: object.district_id,
      commune_id: object.commune_id,
      village_id: object.village_id,
      street_number: object.street_number,
      house_number: object.house_number,
      current_address: object.current_address,
      address_type: object.address_type,
      outside_address: object.outside_address
    }

    onChange('carer', { ...fields })({type: 'select'})
  }, [sameAsClient, client])

  const blank = []
  const genderLists = [{label: 'Female', value: 'female'}, {label: 'Male', value: 'male'}, {label: 'Other', value: 'other'}, {label: 'Unknown', value: 'unknown'}]
  const familyLists = families.map(family => ({ label: family.name, value: family.id }))

  const onChangeFamily = ({ data, action, type }) => {
    let value = []
    if (action === 'select-option'){
      value.push(data)
    } else if (action === 'clear'){
      value = []
    }
    onChange('client', 'family_ids')({data: value, type})
  }

  return (
    <div id={id} className="collapse">
      <br/>
      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          {/* will change to carer object */}
          <TextInput label="Name" onChange={onChange('client', 'live_with')} value={client.live_with} />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput label="Gender" options={genderLists} onChange={onChange('carer', 'gender')} value={carer.gender}  />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          {/* will change to carer object */}
          <TextInput label="Carer Phone Number" onChange={onChange('client', 'telephone_number')} value={client.telephone_number}/>
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput label="Carer Email Address" onChange={onChange('carer', 'email')} value={carer.email} />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput label="Relationship to Client" options={clientRelationships} onChange={onChange('carer', 'client_relationship')} value={carer.client_relationship} />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput label="Family Record" options={familyLists} value={client.family_ids} onChange={onChangeFamily} />
        </div>
      </div>
      <legend>
        <div className="row">
          <div className="col-xs-12 col-md-6 col-lg-3">
            <p>Address</p>
          </div>
          {
            !carer.outside &&
            <div className="col-xs-12 col-md-6 col-lg-3">
              <Checkbox label="Same as Client" checked={sameAsClient} onChange={({data}) => setSameAsClient(data)} />
            </div>
          }
          {
            !sameAsClient &&
            <div className="col-xs-12 col-md-6 col-lg-3">
              <Checkbox label="Outside Cambodia" checked={carer.outside || false} onChange={onChange('carer', 'outside')} />
            </div>
          }
        </div>
      </legend>
      <Address disabled={sameAsClient} outside={carer.outside || false} onChange={onChange} data={{client, currentDistricts: carerDistricts, currentCommunes: carerCommunes, currentVillages: carerVillages, currentProvinces, addressTypes, objectKey: 'carer', objectData: carer}} />
    </div>
  )
}
