import React, { useEffect, useState }       from 'react'
import {
  SelectInput,
  DateInput,
  TextInput,
  Checkbox,
  UploadInput
}                   from '../Commons/inputs'
import Address      from './address'

export default props => {
  const { onChange, data: { client, referee, currentDistricts, currentCommunes, currentVillages, birthProvinces, currentProvinces, errorFields, callerRelationships, addressTypes, phoneOwners, T } } = props

  const callerRelationship = callerRelationships.map(relationship => ({ label: T.translate("callerRelationship."+relationship.label), value: relationship.value }))
  const phoneOwner = phoneOwners.map(phone => ({ label: T.translate("phoneOwner."+phone.label), value: phone.value }))
  const genderLists = [
    { label: T.translate("refereeInfo.female"), value: 'female' },
    { label: T.translate("refereeInfo.male"), value: 'male' },
    { label: T.translate("refereeInfo.other"), value: 'other' },
    { label: T.translate("refereeInfo.unknown"), value: 'unknown' }
  ]
  const birthProvincesLists = birthProvinces.map(province => ({label: province[0], options: province[1].map(value => ({label: value[0], value: value[1]}))}))
  const [districts, setDistricts]         = useState(currentDistricts)
  const [communes, setCommunes]           = useState(currentCommunes)
  const [villages, setVillages]           = useState(currentVillages)

  const onProfileChange = fileItems => {
    onChange('clientProfile', fileItems[0].file)({type: 'file'})
  }

  const onChangeRemoveProfile = data => {
    onChange('client', { remove_profile: data.data })({type: 'checkbox'})
    // onChange('client', 'remove_profile')({type: 'checkbox', data: data.data})
  }

  const fetchData = (parent, data, child) => {
    $.ajax({
      type: 'GET',
      url: `/api/${parent}/${data}/${child}`,
    }).success(res => {
      const dataState = { districts: setDistricts, communes: setCommunes, villages: setVillages }
      dataState[child](res.data)
    })
  }

  const onRelationshipChange = event => {
    const previousSelect = client.referee_relationship
    const isSelf = event.data === 'self'

    if(isSelf) {
      if(referee.province_id !== null)
        fetchData('provinces', referee.province_id, 'districts')
      if(referee.district_id !== null)
        fetchData('districts', referee.district_id, 'communes')
      if(referee.commune_id !== null)
        fetchData('communes', referee.commune_id, 'villages')

    } else if(previousSelect === 'self') {
      setDistricts([])
      setCommunes([])
      setVillages([])
    }

    const fields = {
      outside: isSelf ? referee.outside : previousSelect === 'self' ? false : client.outside,
      province_id: isSelf ? referee.province_id : previousSelect === 'self' ? null : client.province_id,
      district_id: isSelf ? referee.district_id : previousSelect === 'self' ?  null : client.district_id,
      commune_id: isSelf ? referee.commune_id : previousSelect === 'self' ? null : client.commune_id,
      village_id: isSelf ? referee.village_id : previousSelect === 'self' ? null : client.village_id,
      street_number: isSelf ? referee.street_number : previousSelect === 'self' ? '' : client.street_number,
      house_number: isSelf ? referee.house_number : previousSelect === 'self' ? '' : client.house_number,
      current_address: isSelf ? referee.current_address : previousSelect === 'self' ? '' : client.current_address,
      address_type: isSelf ? referee.address_type : previousSelect === 'self' ? '' : client.address_type,
      outside_address: isSelf ? referee.outside_address : previousSelect === 'self' ? '' : client.outside_address
    }

    onChange('client', { ...fields, referee_relationship: event.data })({type: 'select'})
  }

  // useEffect(() => {
  //   const isSelf = client.referee_relationship === 'self'

  //   if(isSelf) {
  //     if(referee.province_id !== null)
  //       fetchData('provinces', referee.province_id, 'districts')
  //     if(referee.district_id !== null)
  //       fetchData('districts', referee.district_id, 'communes')
  //     if(referee.commune_id !== null)
  //       fetchData('communes', referee.commune_id, 'villages')
  //   }

  //   const fields = {
  //     outside: isSelf ? referee.outside : false,
  //     province_id: isSelf ? referee.province_id : null,
  //     district_id: isSelf ? referee.district_id : null,
  //     commune_id: isSelf ? referee.commune_id : null,
  //     village_id: isSelf ? referee.village_id : null,
  //     street_number: isSelf ? referee.street_number : '',
  //     house_number: isSelf ? referee.house_number : '',
  //     current_address: isSelf ? referee.current_address : '',
  //     address_type: isSelf ? referee.address_type : '',
  //     outside_address: isSelf ? referee.outside_address : ''
  //   }

  //   onChange('client', { ...fields })({type: 'select'})
  // }, [client.referee_relationship, referee])

  return (
    <div className="containerClass">
      <legend>
        <div className="row">
          <div className="col-xs-12 col-md-6 col-lg-5">
            <p>{T.translate("referralInfo.referral_info")}</p>
          </div>
        </div>
      </legend>

      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput label={T.translate("referralInfo.given_name")} onChange={onChange('client', 'given_name')} value={client.given_name} />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput label={T.translate("referralInfo.family_name")} onChange={onChange('client', 'family_name')} value={client.family_name} />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput label={T.translate("referralInfo.local_given_name")} onChange={onChange('client', 'local_given_name')} value={client.local_given_name} />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput label={T.translate("referralInfo.local_family_name")} onChange={onChange('client', 'local_family_name')} value={client.local_family_name}  />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            T={T}
            required
            isError={errorFields.includes('gender')}
            label={T.translate("referralInfo.gender")}
            options={genderLists}
            value={client.gender}
            onChange={onChange('client', 'gender')}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <DateInput getCurrentDate label={T.translate("referralInfo.date_of_birth")} onChange={onChange('client', 'date_of_birth')} value={client.date_of_birth} />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            asGroup
            label={T.translate("referralInfo.birth_province")}
            options={birthProvincesLists}
            value={client.birth_province_id}
            onChange={onChange('client', 'birth_province_id')}
          />
        </div>

        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            label={T.translate("referralInfo.caller_relationship")}
            options={callerRelationship}
            value={client.referee_relationship}
            onChange={onRelationshipChange}
          />
        </div>

        <div className="col-xs-12">
          <UploadInput label={T.translate("referralInfo.profile")} onChange={onProfileChange} object={client.profile} onChangeCheckbox={onChangeRemoveProfile} checkBoxValue={client.remove_profile || false} T={T} />
        </div>
      </div>
      <legend>
        <div className="row">
          <div className="col-xs-12 col-md-6 col-lg-3">
            <p>{T.translate("referralInfo.contact_info")}</p>
          </div>
          {
            client.referee_relationship !== 'self' &&
            <div className="col-xs-12 col-md-6 col-lg-6">
              <Checkbox label={T.translate("referralInfo.client_is_outside")} checked={client.outside || false} onChange={onChange('client', 'outside')}/>
            </div>
          }
        </div>
      </legend>

      <Address disabled={client.referee_relationship === 'self'} outside={client.outside || false} onChange={onChange} data={{addressTypes, currentDistricts: districts, currentCommunes: communes, currentVillages: villages, currentProvinces, objectKey: 'client', objectData: client, T}} />

      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput label={T.translate("referralInfo.what_3_word")} onChange={onChange('client', 'what3words')} value={client.what3words} />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput label={T.translate("referralInfo.client_phone")} type="number" onChange={onChange('client', 'client_phone')} value={client.client_phone} />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput label={T.translate("referralInfo.phone_owner")} options={phoneOwner} onChange={onChange('client', 'phone_owner')} value={client.phone_owner}/>
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput label={T.translate("referralInfo.client_email")} onChange={onChange('client', 'client_email')} value={client.client_email} />
        </div>
      </div>
    </div>
  )
}
