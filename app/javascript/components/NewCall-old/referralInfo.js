import React, { useEffect, useState }       from 'react'
import {
  SelectInput,
  DateInput,
  TextInput,
  Checkbox
}                   from '../Commons/inputs'
import Address      from './address'

export default props => {
  const { onChange, data: { call, referee, currentDistricts, currentCommunes, currentVillages, birthProvinces, currentProvinces, errorFields, refereeRelationships, addressTypes, phoneOwners } } = props

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
    let object = call

    // if(call.referee_relationship === 'self') {
    //   object = referee
    //   if(object.province_id !== null)
    //     fetchData('provinces', object.province_id, 'districts')
    //   if(object.district_id !== null)
    //     fetchData('districts', object.district_id, 'communes')
    //   if(object.commune_id !== null)
    //     fetchData('communes', object.commune_id, 'villages')
    // }

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

    onChange('call', { ...fields })({type: 'select'})
  }, [call.referee_relationship, referee])

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
          <TextInput label="Given Name (Latin)" onChange={onChange('call', 'given_name')} value={call.given_name} />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput label="Family Name (Latin)" onChange={onChange('call', 'family_name')} value={call.family_name} />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput label="Given Name(Khmer)" onChange={onChange('call', 'local_given_name')} value={call.local_given_name} />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput label="Family Name (Khmer)" onChange={onChange('call', 'local_family_name')} value={call.local_family_name}  />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            required
            isError={errorFields.includes('gender')}
            label="Gender"
            options={genderLists}
            value={call.gender}
            onChange={onChange('call', 'gender')}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <DateInput getCurrentDate label="Date of Birth" onChange={onChange('call', 'date_of_birth')} value={call.date_of_birth} />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            asGroup
            label="Birth Province"
            options={birthProvincesLists}
            value={call.birth_province_id}
            onChange={onChange('call', 'birth_province_id')}
          />
        </div>

        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            label="What is the Referee's relationship to this call?"
            options={refereeRelationships}
            value={call.referee_relationship}
            onChange={onChange('call', 'referee_relationship')}
          />
        </div>
      </div>
      <legend>
        <div className="row">
          <div className="col-xs-12 col-md-6 col-lg-3">
            <p>Contact Information</p>
          </div>
          {
            call.referee_relationship !== 'self' &&
            <div className="col-xs-12 col-md-6 col-lg-6">
              <Checkbox label="Client is outside Cambodia" checked={call.outside || false} onChange={onChange('call', 'outside')}/>
            </div>
          }
        </div>
      </legend>

      <Address disabled={call.referee_relationship === 'self'} outside={call.outside || false} onChange={onChange} data={{addressTypes, currentDistricts: districts, currentCommunes: communes, currentVillages: villages, currentProvinces, objectKey: 'call', objectData: call}} />

      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput label="What3Words" onChange={onChange('call', 'what3words')} value={call.what3words} />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput label="Client Contact Phone" type="number" onChange={onChange('call', 'call_phone')} value={call.call_phone} />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput label="Phone Owner" options={phoneOwners} onChange={onChange('call', 'phone_owner')} value={call.phone_owner}/>
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput label="Client Email Address" onChange={onChange('call', 'call_email')} value={call.call_email} />
        </div>
      </div>
    </div>
  )
}
