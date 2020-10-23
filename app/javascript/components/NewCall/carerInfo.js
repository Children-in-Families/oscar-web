import React, { useState, useEffect } from 'react'
import {
  SelectInput,
  TextInput,
  Checkbox
}             from '../Commons/inputs'
import Address from './address'

export default props => {
  const { onChange, id, data: { carerDistricts, carerCommunes, carerVillages, clients, carer, clientRelationships, currentProvinces, families, addressTypes, T } } = props
  const clientRelationship = clientRelationships.map(relationship => ({ label: T.translate("clientRelationShip." + relationship.label), value: relationship.value }))
  const client = clients[0]

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

  const onCheckSameAsClient = data => {
    const same = data.data

    if(same) {
      if(client.province_id !== null)
        fetchData('provinces', client.province_id, 'districts')
      if(client.district_id !== null)
        fetchData('districts', client.district_id, 'communes')
      if(client.commune_id !== null)
        fetchData('communes', client.commune_id, 'villages')
    } else {
      setDistricts([])
      setCommunes([])
      setVillages([])
    }

    const fields = {
      outside: same ? client.outside : false,
      province_id: same ? client.province_id : null,
      district_id: same ? client.district_id : null,
      commune_id: same ? client.commune_id : null,
      village_id: same ? client.village_id : null,
      street_number: same ? client.street_number : '',
      house_number: same ? client.house_number : '',
      current_address: same ? client.current_address : '',
      address_type: same ? client.address_type : '',
      outside_address: same ? client.outside_address : ''
    }

    onChange('carer', { ...fields, 'same_as_client': data.data })({type: 'select'})
  }

  useEffect(() => {
    let object = carer

    if(carer.same_as_client) {
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
  }, [carer.same_as_client, client])

  const genderLists = [
    { label: T.translate("genderLists.female"), value: 'female' },
    { label: T.translate("genderLists.male"), value: 'male' },
    { label: T.translate("genderLists.lgbt"), value: 'lgbt' },
    { label: T.translate("genderLists.unknown"), value: 'unknown' },
    { label: T.translate("genderLists.prefer_not_to_say"), value: 'prefer_not_to_say' },
    { label: T.translate("genderLists.other"), value: 'other' }
  ]
  const familyLists = families.map(family => ({ label: family.name, value: family.id }))

  const onChangeFamily = ({ data, action, type }) => {
    let values = []
    if (action === 'select-option'){
      values = client.family_ids
      values.push(data)
      values = values.filter((v, i, a) => a.indexOf(v) === i);
    }
    const modifyObject = { ...client, current_family_id: data, family_ids: values }

    const newObjects = clients.map((object, indexObject) => {
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
          {/* will change to carer object */}
          <TextInput T={T} label={T.translate("newCall.carerInfo.name")} onChange={onChange('carer', 'name')} value={carer.name} />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput T={T} label={T.translate("newCall.carerInfo.gender")} options={genderLists} onChange={onChange('carer', 'gender')} value={carer.gender}  />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          {/* will change to carer object */}
          <TextInput T={T} label={T.translate("newCall.carerInfo.carer_phone")} type="text" onChange={onChange('carer', 'phone')} value={carer.phone}/>
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput T={T} label={T.translate("newCall.carerInfo.carer_email")} onChange={onChange('carer', 'email')} value={carer.email} />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput T={T} label={T.translate("newCall.carerInfo.relationship")} options={clientRelationship} onChange={onChange('carer', 'client_relationship')} value={carer.client_relationship} />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput T={T} label={T.translate("newCall.carerInfo.family_record")} options={familyLists} value={client.current_family_id} onChange={onChangeFamily} />
          <TextInput type="hidden" name="client[current_family_id]" value={ client.current_family_id } />
        </div>
      </div>
      <legend>
        <div className="row">
          <div className="col-xs-12 col-md-6 col-lg-3">
            <p>{T.translate("newCall.carerInfo.address")}</p>
          </div>
          <div className="col-xs-12 col-md-6 col-lg-3">
            <Checkbox label={T.translate("newCall.carerInfo.same_as_client")} checked={carer.same_as_client} onChange={onCheckSameAsClient} />
          </div>
          {
            !carer.same_as_client &&
            <div className="col-xs-12 col-md-6 col-lg-3">
              <Checkbox label={T.translate("newCall.carerInfo.outside_cambodia")} checked={carer.outside || false} onChange={onChange('carer', 'outside')} />
            </div>
          }

        </div>
      </legend>
      <Address disabled={carer.same_as_client} outside={carer.outside} onChange={onChange} data={{currentDistricts: districts, currentCommunes: communes, currentVillages: villages, currentProvinces, addressTypes, objectKey: 'carer', objectData: carer, T}} />
    </div>
  )
}
