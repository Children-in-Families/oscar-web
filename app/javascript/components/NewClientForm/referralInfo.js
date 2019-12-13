import React, { useEffect, useState }       from 'react'
import {
  SelectInput,
  DateInput,
  TextInput,
  Checkbox
}                   from '../Commons/inputs'
import Address      from './address'

export default props => {
  const { onChange, data: { client, referee, currentDistricts, currentCommunes, currentVillages, birthProvinces, currentProvinces, errorFields, refereeRelationships, addressTypes, phoneOwners } } = props

  const genderLists = [{label: 'Female', value: 'female'}, {label: 'Male', value: 'male'}, {label: 'Other', value: 'other'}, {label: 'Unknown', value: 'unknown'}]
  const birthProvincesLists = birthProvinces.map(province => ({label: province[0], options: province[1].map(value => ({label: value[0], value: value[1]}))}))

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
    let object = client

    if(client.referee_relationship === 'self') {
      object = referee
      if(object.province_id !== null)
        fetchData('provinces', object.province_id, 'districts')
      if(object.district_id !== null)
        fetchData('districts', object.district_id, 'communes')
      if(object.commune_id !== null)
        fetchData('communes', object.commune_id, 'villages')
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

    onChange('client', { ...fields })({type: 'select'})
  }, [client.referee_relationship, referee])

  return (
    <div className="containerClass">
      <legend>
        <div className="row">
          <div className="col-xs-12 col-md-6 col-lg-4">
            <p>Client / Referral Information</p>
          </div>
        </div>
      </legend>

      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput label="Given Name (Latin)" onChange={onChange('client', 'given_name')} value={client.given_name} />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput label="Family Name (Latin)" onChange={onChange('client', 'family_name')} value={client.family_name} />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput label="Given Name(Khmer)" onChange={onChange('client', 'local_given_name')} value={client.local_given_name} />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput label="Family Name (Khmer)" onChange={onChange('client', 'local_family_name')} value={client.local_family_name}  />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            required
            isError={errorFields.includes('gender')}
            label="Gender"
            options={genderLists}
            value={client.gender}
            onChange={onChange('client', 'gender')}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <DateInput getCurrentDate label="Date of Birth" onChange={onChange('client', 'date_of_birth')} value={client.date_of_birth} />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            asGroup
            label="Birth Province"
            options={birthProvincesLists}
            value={client.birth_province_id}
            onChange={onChange('client', 'birth_province_id')}
          />
        </div>

        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            label="What is the Referee's relationship to this client?"
            options={refereeRelationships}
            value={client.referee_relationship}
            onChange={onChange('client', 'referee_relationship')}
          />
        </div>
      </div>
      <legend>
        <div className="row">
          <div className="col-xs-12 col-md-6 col-lg-3">
            <p>Contact Information</p>
          </div>
          {
            client.referee_relationship !== 'self' &&
            <div className="col-xs-12 col-md-6 col-lg-6">
              <Checkbox label="Client is outside Cambodia" checked={client.outside || false} onChange={onChange('client', 'outside')}/>
            </div>
          }
        </div>
      </legend>

      <Address disabled={client.referee_relationship === 'self'} outside={client.outside || false} onChange={onChange} data={{addressTypes, currentDistricts: districts, currentCommunes: communes, currentVillages: villages, currentProvinces, objectKey: 'client', objectData: client}} />

      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput label="What3Words" onChange={onChange('client', 'what3words')} value={client.what3words} />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput label="Client Contact Phone" type="number" onChange={onChange('client', 'client_phone')} value={client.client_phone} />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput label="Phone Owner" options={phoneOwners} onChange={onChange('client', 'phone_owner')} value={client.phone_owner}/>
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput label="Client Email Address" onChange={onChange('client', 'client_email')} value={client.client_email} />
        </div>
      </div>
    </div>
  )
}
