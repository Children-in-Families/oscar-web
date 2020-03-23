import React, { useEffect, useState }       from 'react'
import {
  SelectInput,
  DateInput,
  TextInput,
  Checkbox,
  UploadInput,
  TextArea
}                   from '../Commons/inputs'
import Address      from './address'
import ConcernAddress from "./concernAddress";
import { t } from '../../utils/i18n'

export default props => {
  const { onChange, fieldsVisibility, translation , data: { client, referee, currentDistricts, currentCommunes, currentVillages, birthProvinces, currentProvinces, errorFields, callerRelationships, addressTypes, phoneOwners, T, current_organization, brc_islands, brc_household_types, brc_resident_types } } = props
  const callerRelationship = callerRelationships.map(relationship => ({ label: T.translate("callerRelationship."+relationship.label), value: relationship.value }))
  const phoneOwner = phoneOwners.map(phone => ({ label: T.translate("phoneOwner."+phone.label), value: phone.value }))
  const genderLists = [
    { label: T.translate("refereeInfo.female"), value: 'female' },
    { label: T.translate("refereeInfo.male"), value: 'male' },
    { label: T.translate("refereeInfo.other"), value: 'other' },
    { label: T.translate("refereeInfo.unknown"), value: 'unknown' }
  ]
  const phoneEmailOwnerOpts = phoneOwners.map(phone => ({ label: T.translate("phoneOwner." + phone.label), value: phone.value }))
  const birthProvincesLists = birthProvinces.map(province => ({label: province[0], options: province[1].map(value => ({label: value[0], value: value[1]}))}))
  const [districts, setDistricts]         = useState(currentDistricts)
  const [communes, setCommunes]           = useState(currentCommunes)
  const [villages, setVillages]           = useState(currentVillages)
  let urlParams                           = window.location.search
  let pattern                             = new RegExp(/type=call/gi)
  let isRedirectFromCall                  = pattern.test(urlParams)

  useEffect(() => {
    if(client.referee_relationship === 'self') {
      const fields = {
        outside: referee.outside,
        province_id: referee.province_id,
        district_id: referee.district_id,
        commune_id: referee.commune_id,
        village_id: referee.village_id,
        street_number: referee.street_number,
        house_number: referee.house_number,
        current_address: referee.current_address,
        address_type: referee.address_type,
        outside_address: referee.outside_address
      }

      if(referee.province_id !== null)
        fetchData('provinces', referee.province_id, 'districts')
      if(referee.district_id !== null)
        fetchData('districts', referee.district_id, 'communes')
      if(referee.commune_id !== null)
        fetchData('communes', referee.commune_id, 'villages')

      const newObject = { ...client, ...fields }
      onChange('client', newObject)({type: 'select'})
    }
  }, [referee])

  const onProfileChange = fileItems => {
    onChange('clientProfile', fileItems[0].file)({type: 'file'})
  }

  const onChangeRemoveProfile = data => {
    onChange('client', { remove_profile: data.data })({type: 'checkbox'})
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
      concern_is_outside: same ? client.outside : false,
      concern_province_id: same ? client.province_id : null,
      concern_district_id: same ? client.district_id : null,
      concern_commune_id: same ? client.commune_id : null,
      concern_village_id: same ? client.village_id : null,
      concern_street: same ? client.street_number : '',
      concern_house: same ? client.house_number : '',
      concern_address: same ? client.current_address : '',
      concern_address_type: same ? client.address_type : '',
      concern_outside_address: same ? client.outside_address : ''
    }

    onChange('client', { ...fields, 'concern_same_as_client': data.data })({type: 'select'})
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
          <TextInput label={translation.clients.form.given_name} onChange={onChange('client', 'given_name')} value={client.given_name} />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput label={translation.clients.form.family_name} onChange={onChange('client', 'family_name')} value={client.family_name} />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput label={translation.clients.form.local_given_name} onChange={onChange('client', 'local_given_name')} value={client.local_given_name} />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput label={translation.clients.form.local_family_name} onChange={onChange('client', 'local_family_name')} value={client.local_family_name}  />
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

      <Address translation={ translation } fieldsVisibility={ fieldsVisibility } disabled={client.referee_relationship === 'self'} current_organization={current_organization} callFrom='referralInfo' outside={client.outside || false} translation={translation} onChange={onChange} data={{ addressTypes, currentDistricts: districts, currentCommunes: communes, currentVillages: villages, currentProvinces, objectKey: 'client', objectData: client, T, brc_islands, brc_household_types, brc_resident_types }} />

      <div className="row">
        {
          fieldsVisibility && fieldsVisibility.what3words != false &&
          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput label={T.translate("referralInfo.what_3_word")} onChange={onChange('client', 'what3words')} value={client.what3words} />
          </div>
        }

        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput label={T.translate("referralInfo.client_phone")} type="text" onChange={onChange('client', 'client_phone')} value={client.client_phone} />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput label={T.translate("referralInfo.phone_owner")} options={phoneOwner} onChange={onChange('client', 'phone_owner')} value={client.phone_owner}/>
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput label={T.translate("referralInfo.client_email")} onChange={onChange('client', 'client_email')} value={client.client_email} />
        </div>

        {
          isRedirectFromCall &&
          <div className="col-xs-12">
            <TextArea
              label={T.translate("newCall.referralInfo.location_description")}
              value={client.location_description}
              onChange={onChange('client', 'location_description')} />
          </div>
        }
      </div>

      <br/>
      {isRedirectFromCall &&
        <>
        <legend>
          <div className="row">
            <div className="col-xs-12 col-md-6 col-lg-3">
              <p>{T.translate("newCall.referralInfo.location_of_concern")}</p>
            </div>
            <div className="col-xs-12 col-md-6 col-lg-3">
              <Checkbox label={T.translate("newCall.referralInfo.same_as_client")} checked={client.concern_same_as_client} onChange={onCheckSameAsClient} />
            </div>
            {!client.concern_same_as_client &&
              <div className="col-xs-12 col-md-6 col-lg-6">
                <Checkbox
                  label={T.translate("newCall.referralInfo.concern_is_outside_cambodia")}
                  checked={client.concern_is_outside || false}
                  onChange={onChange("client", "concern_is_outside")}
                />
              </div>
            }
          </div>
        </legend>

        <ConcernAddress
          T={T}
          disabled={client.concern_same_as_client}
          outside={client.concern_is_outside || false}
          onChange={onChange}
          data={{
            addressTypes,
            currentDistricts: districts,
            currentCommunes: communes,
            currentVillages: villages,
            currentProvinces,
            objectKey: "client",
            objectData: client
          }}
        />

        <div className="row">
          <div className="col-xs-12 col-md-6">
            <div className="row">
              <div className="col-xs-12 col-md-6">
                <TextInput
                  T={T}
                  label={T.translate("newCall.referralInfo.relevant_contact_phone")}
                  onChange={onChange("client", "concern_phone")}
                  value={client.concern_phone}
                />
              </div>
              <div className="col-xs-12 col-md-6">
                <SelectInput
                  T={T}
                  label={T.translate("newCall.referralInfo.phone_owner")}
                  options={phoneEmailOwnerOpts}
                  value={client.concern_phone_owner}
                  onChange={onChange("client", "concern_phone_owner")}
                />
              </div>
            </div>
            <div className="row">
              <div className="col-xs-12 col-md-6">
                <TextInput
                  T={T}
                  label={T.translate("newCall.referralInfo.relevant_email")}
                  onChange={onChange("client", "concern_email")}
                  value={client.concern_email}
                />
              </div>
              <div className="col-xs-12 col-md-6">
                <SelectInput
                  T={T}
                  label={T.translate("newCall.referralInfo.email_owner")}
                  options={phoneEmailOwnerOpts}
                  value={client.concern_email_owner}
                  onChange={onChange("client", "concern_email_owner")}
                />
              </div>
            </div>
          </div>
          <div className={"col-xs-12 col-md-6" + (client.concern_is_outside ? ' hidden' : '')}>
            <TextArea
              label={T.translate("newCall.referralInfo.locatin_description")}
              value={client.concern_location}
              onChange={onChange('client', 'concern_location')} />
          </div>
        </div>
        </>
      }
    </div>
  )
}
