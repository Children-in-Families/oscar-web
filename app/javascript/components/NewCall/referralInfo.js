import React, { useEffect, useState } from "react";
import { SelectInput, TextArea, TextInput, Checkbox, DateInput } from "../Commons/inputs";
import ConcernAddress from "./concernAddress";
import Address from './address'

export default props => {
  const {
    onChange,
    data: {
      users,
      client,
      referee,
      currentDistricts,
      currentCommunes,
      currentVillages,
      birthProvinces,
      currentProvinces,
      errorFields,
      refereeRelationships,
      addressTypes,
      phoneOwners, T
    }
  } = props;

  const refereeRelationshipOpts = refereeRelationships.map(relationship => ({ label: relationship.label, value: relationship.value }))
  const userLists = users.map(user => ({label: user[0], value: user[1], isFixed: user[2] === 'locked' ? true : false }))

  const phoneEmailOwnerOpts = phoneOwners.map(phone => ({ label: phone.label, value: phone.value }))
  // same as phone owner
  // const emailOwnerOpts = phoneOwners.map(phone => ({ label: phone.label, value: phone.value }))

  const genderLists = [
    { label: "Female", value: "female" },
    { label: "Male", value: "male" },
    { label: "Other", value: "other" },
    { label: "Unknown", value: "unknown" }
  ];
  const birthProvincesLists = birthProvinces.map(province => ({
    label: province[0],
    options: province[1].map(value => ({ label: value[0], value: value[1] }))
  }));
  const [districts, setDistricts] = useState(currentDistricts);
  const [communes, setCommunes] = useState(currentCommunes);
  const [villages, setVillages] = useState(currentVillages);

  useEffect(() => {
    // SHOULD COMMENT THIS LINE BEFORE PUSHING TO PRODUCTION
    // onChange('client', 'initial_referral_date')({data: '2020-1-1', type: 'date'});
  }, [])

  const fetchData = (parent, data, child) => {
    $.ajax({
      type: "GET",
      url: `/api/${parent}/${data}/${child}`
    }).success(res => {
      const dataState = {
        districts: setDistricts,
        communes: setCommunes,
        villages: setVillages
      };
      dataState[child](res.data);
    });
  };

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

  const onRelationshipChange = event => {
    const previousSelect = client.referee_relationship
    const isSelf = event.data === 'self'
    const refereeObj = referee.referee;

    if(isSelf) {
      if(refereeObj.province_id)
        fetchData('provinces', refereeObj.province_id, 'districts')
      if(refereeObj.district_id)
        fetchData('districts', refereeObj.district_id, 'communes')
      if(refereeObj.commune_id)
        fetchData('communes', refereeObj.commune_id, 'villages')

    } else if(previousSelect === 'self') {
      setDistricts([])
      setCommunes([])
      setVillages([])
    }

    const fields = {
      outside: isSelf ? refereeObj.outside : previousSelect === 'self' ? false : client.outside,
      province_id: isSelf ? refereeObj.province_id : previousSelect === 'self' ? null : client.province_id,
      district_id: isSelf ? refereeObj.district_id : previousSelect === 'self' ?  null : client.district_id,
      commune_id: isSelf ? refereeObj.commune_id : previousSelect === 'self' ? null : client.commune_id,
      village_id: isSelf ? refereeObj.village_id : previousSelect === 'self' ? null : client.village_id,
      street_number: isSelf ? refereeObj.street_number : previousSelect === 'self' ? '' : client.street_number,
      house_number: isSelf ? refereeObj.house_number : previousSelect === 'self' ? '' : client.house_number,
      current_address: isSelf ? refereeObj.current_address : previousSelect === 'self' ? '' : client.current_address,
      address_type: isSelf ? refereeObj.address_type : previousSelect === 'self' ? '' : client.address_type,
      outside_address: isSelf ? refereeObj.outside_address : previousSelect === 'self' ? '' : client.outside_address
    }

    onChange('client', { ...fields, referee_relationship: event.data })({type: 'select'})
  }

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
          <TextInput
            T={T}
            label="Given Name (Latin)"
            onChange={onChange("client", "given_name")}
            value={client.given_name}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            T={T}
            label="Family Name (Latin)"
            onChange={onChange("client", "family_name")}
            value={client.family_name}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            T={T}
            label="Given Name(Khmer)"
            onChange={onChange("client", "local_given_name")}
            value={client.local_given_name}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            T={T}
            label="Family Name (Khmer)"
            onChange={onChange("client", "local_family_name")}
            value={client.local_family_name}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            T={T}
            label="Nickname"
            onChange={onChange("client", "nickname")}
            value={client.nickname}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <DateInput 
            getCurrentDate 
            label="Date of Birth" 
            onChange={onChange('client', 'date_of_birth')}
            value={client.date_of_birth} 
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            T={T}
            required
            isError={errorFields.includes("gender")}
            label="Gender"
            options={genderLists}
            value={client.gender}
            onChange={onChange("client", "gender")}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            T={T}
            asGroup
            label="Birth Province"
            options={birthProvincesLists}
            value={client.birth_province_id}
            onChange={onChange("client", "birth_province_id")}
          />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            T={T}
            label="Relationship to Caller"
            options={refereeRelationshipOpts}
            value={client.referee_relationship}
            onChange={onRelationshipChange}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            T={T}
            required
            isError={errorFields.includes('user_ids')}
            label={T.translate("admin.case_worker")}
            isMulti
            options={userLists}
            value={client.user_ids}
            onChange={onChange('client','user_ids')} />
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
      <Address disabled={client.referee_relationship === 'self'} outside={client.outside || false} onChange={onChange} data={{addressTypes, currentDistricts: districts, currentCommunes: communes, currentVillages: villages, currentProvinces, objectKey: 'client', objectData: client, T}} />
      <div className="row">
        <div className="col-xs-12 col-md-6">
          <div className="row">
            <div className="col-xs-12 col-md-6">
              <TextInput label="Client Contact Phone" type="number" onChange={onChange('client', 'client_phone')} value={client.client_phone} />
            </div>
            <div className="col-xs-12 col-md-6">
              <SelectInput label="Phone Owner" options={phoneEmailOwnerOpts} onChange={onChange('client', 'phone_owner')} value={client.phone_owner}/>
            </div>
            <div className="col-xs-12 col-md-6">
              <TextInput label="Client Email Contact" onChange={onChange('client', 'client_email')} value={client.client_email} />
            </div>
            <div className="col-xs-12 col-md-6">
              <SelectInput label="Email Owner" options={phoneEmailOwnerOpts} onChange={onChange('client', 'email_owner')} value={client.email_owner}/>
            </div>
          </div>
        </div>
        <div className={"col-xs-12 col-md-6" + (client.outside ? ' hidden' : '')}>
          <TextArea
            label="Location Description"
            value={client.location_description}
            onChange={onChange('client', 'location_description')} />
        </div>
      </div>

      <br/>
      <legend>
        <div className="row">
          <div className="col-xs-12 col-md-6 col-lg-3">
            <p>Location of concern</p>
          </div>
          <div className="col-xs-12 col-md-6 col-lg-3">
            <Checkbox label="Same as Client" checked={client.concern_same_as_client} onChange={onCheckSameAsClient} />
          </div>
          {!client.concern_same_as_client &&
            <div className="col-xs-12 col-md-6 col-lg-6">
              <Checkbox
                label="Concern is outside Cambodia"
                checked={client.concern_is_outside || false}
                onChange={onChange("client", "concern_is_outside")}
              />
            </div>
          }
        </div>
      </legend>

      <ConcernAddress
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
                label="Relevant Contact Phone"
                onChange={onChange("client", "concern_phone")}
                value={client.concern_phone}
              />
            </div>
            <div className="col-xs-12 col-md-6">
              <SelectInput
                T={T}
                label="Phone Owner"
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
                label="Relevant Email Contact"
                onChange={onChange("client", "concern_email")}
                value={client.concern_email}
              />
            </div>
            <div className="col-xs-12 col-md-6">
              <SelectInput
                T={T}
                label="Email Owner"
                options={phoneEmailOwnerOpts}
                value={client.concern_email_owner}
                onChange={onChange("client", "concern_email_owner")}
              />
            </div>
          </div>
        </div>
        <div className={"col-xs-12 col-md-6" + (client.concern_is_outside ? ' hidden' : '')}>
          <TextArea
            label="Location Description"
            value={client.concern_location}
            onChange={onChange('client', 'concern_location')} />
        </div>
      </div>
    </div>
  );
};
