import React, { useEffect, useState } from "react";
import { SelectInput, TextArea, TextInput, Checkbox, DateInput } from "../Commons/inputs";
import ConcernAddress from "./concernAddress";
import Address from './address'

export default props => {
  const {
    onChange,
    data: {
      users,
      clients,
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

  const [clientIndex, setClientIndex] = useState(0)
  const currentClient = clients[clientIndex]
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

  const [concernDistricts, setConcernDistricts] = useState(currentDistricts);
  const [concernCommunes, setConcernCommunes] = useState(currentCommunes);
  const [concernVillages, setConcernVillages] = useState(currentVillages);

  const fetchData = (parent, data, child, dataState) => {
    $.ajax({
      type: "GET",
      url: `/api/${parent}/${data}/${child}`
    }).success(res => {
      dataState[child](res.data);
    });
  };

  const onCheckSameAsClient = data => {
    const same = data.data

    const dataState = {
      districts: setConcernDistricts,
      communes: setConcernCommunes,
      villages: setConcernVillages
    }

    if(same) {
      if(currentClient.province_id !== null)
        fetchData('provinces', currentClient.province_id, 'districts', dataState)
      if(currentClient.district_id !== null)
        fetchData('districts', currentClient.district_id, 'communes', dataState)
      if(currentClient.commune_id !== null)
        fetchData('communes', currentClient.commune_id, 'villages', dataState)
    } else {
      setConcernDistricts([])
      setConcernCommunes([])
      setConcernVillages([])
    }

    const fields = {
      concern_is_outside: same ? currentClient.outside : false,
      concern_province_id: same ? currentClient.province_id : null,
      concern_district_id: same ? currentClient.district_id : null,
      concern_commune_id: same ? currentClient.commune_id : null,
      concern_village_id: same ? currentClient.village_id : null,
      concern_street: same ? currentClient.street_number : '',
      concern_house: same ? currentClient.house_number : '',
      concern_address: same ? currentClient.current_address : '',
      concern_address_type: same ? currentClient.address_type : '',
      concern_outside_address: same ? currentClient.outside_address : ''
    }

    modifyClientObject(clientIndex, { ...fields, concern_same_as_client: data.data })
  }

  const onRelationshipChange = event => {
    const previousSelect = currentClient.referee_relationship
    const isSelf = event.data === 'self'
    const refereeObj = referee

    const dataState = {
      districts: setDistricts,
      communes: setCommunes,
      villages: setVillages
    }

    if(isSelf) {
      if(refereeObj.province_id)
        fetchData('provinces', refereeObj.province_id, 'districts', dataState)
      if(refereeObj.district_id)
        fetchData('districts', refereeObj.district_id, 'communes', dataState)
      if(refereeObj.commune_id)
        fetchData('communes', refereeObj.commune_id, 'villages', dataState)

    } else if(previousSelect === 'self') {
      setDistricts([])
      setCommunes([])
      setVillages([])
    }

    const fields = {
      outside: isSelf ? refereeObj.outside : previousSelect === 'self' ? false : currentClient.outside,
      province_id: isSelf ? refereeObj.province_id : previousSelect === 'self' ? null : currentClient.province_id,
      district_id: isSelf ? refereeObj.district_id : previousSelect === 'self' ?  null : currentClient.district_id,
      commune_id: isSelf ? refereeObj.commune_id : previousSelect === 'self' ? null : currentClient.commune_id,
      village_id: isSelf ? refereeObj.village_id : previousSelect === 'self' ? null : currentClient.village_id,
      street_number: isSelf ? refereeObj.street_number : previousSelect === 'self' ? '' : currentClient.street_number,
      house_number: isSelf ? refereeObj.house_number : previousSelect === 'self' ? '' : currentClient.house_number,
      current_address: isSelf ? refereeObj.current_address : previousSelect === 'self' ? '' : currentClient.current_address,
      address_type: isSelf ? refereeObj.address_type : previousSelect === 'self' ? '' : currentClient.address_type,
      outside_address: isSelf ? refereeObj.outside_address : previousSelect === 'self' ? '' : currentClient.outside_address
    }

    modifyClientObject(clientIndex, { ...fields, referee_relationship: event.data })
  }

  const renderClientNavigation = () => {
    if(clients.length > 1)
      return (
        clients.map((client, index) => (
          <button
            className={`btn ${clientIndex === index ? 'btn-primary' : 'btn-default'} `}
            style={{marginLeft: 5, marginRight: 5}}
            key={index}
            onClick={() => setClientIndex(index)}>
              {index + 1}
          </button>
        ))
      )
  }

  const handleOnChangeText = name => event => modifyClientObject(clientIndex, { [name]: event.target.value })
  const handleOnChangeOther = name => data => modifyClientObject(clientIndex, { [name]: data.data })

  const hanldeOnChangeAddressInputs = (obj, field) => event => {
    const isTextInputValue = event.target && event.target.value

    if(isTextInputValue)
      modifyClientObject(clientIndex, { [field]: isTextInputValue })
    else
      modifyClientObject(clientIndex, field)
  }

  const modifyClientObject = (index, field) => {
    const getObject    = clients[index]
    const modifyObject = { ...getObject, ...field }

    const newObjects = clients.map((object, indexObject) => {
      const newObject = indexObject === index ? modifyObject : object
      return newObject
    })

    onChange('client', newObjects)({type: 'object'})
  }

  const removeClient = () => {
    const newObject = clients.filter((client, index) => clientIndex !== index)
    setClientIndex(0)
    onChange('client', newObject)({type: 'object'})
  }

  return (
    <div className="containerClass">
      <legend>
        <div className="row">
          <div className="col-xs-12 col-md-6 col-lg-4">
            <p>Client / Referral Information</p>
          </div>

          <div className="col-xs-12 col-md-6 col-lg-4">
            { renderClientNavigation()}
          </div>
        </div>
      </legend>

      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            T={T}
            label="Given Name (Latin)"
            onChange={handleOnChangeText("given_name")}
            value={currentClient.given_name}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            T={T}
            label="Family Name (Latin)"
            onChange={handleOnChangeText("family_name")}
            value={currentClient.family_name}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            T={T}
            label="Given Name(Khmer)"
            onChange={handleOnChangeText("local_given_name")}
            value={currentClient.local_given_name}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            T={T}
            label="Family Name (Khmer)"
            onChange={handleOnChangeText("local_family_name")}
            value={currentClient.local_family_name}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            T={T}
            label="Nickname"
            onChange={handleOnChangeText("nickname")}
            value={currentClient.nickname}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <DateInput
            getCurrentDate
            label="Date of Birth"
            onChange={handleOnChangeOther('date_of_birth')}
            value={currentClient.date_of_birth}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            T={T}
            required
            isError={errorFields.includes("gender")}
            label="Gender"
            options={genderLists}
            value={currentClient.gender}
            onChange={handleOnChangeOther("gender")}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            T={T}
            asGroup
            label="Birth Province"
            options={birthProvincesLists}
            value={currentClient.birth_province_id}
            onChange={handleOnChangeOther("birth_province_id")}
          />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            T={T}
            label="Relationship to Caller"
            options={refereeRelationshipOpts}
            value={currentClient.referee_relationship}
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
            value={currentClient.user_ids}
            onChange={handleOnChangeOther('user_ids')}
          />
        </div>

        <div className="col-xs-12">
          <button className="btn btn-primary" style={{margin: 5}} onClick={() => onChange('client', {})({type: 'newObject'})}>Add Another Client</button>
          { clients.length > 1 &&
            <button className="btn btn-danger" style={{margin: 5}} onClick={removeClient}>Remove Client</button>
          }
        </div>

      </div>
      <legend>
        <div className="row">
          <div className="col-xs-12 col-md-6 col-lg-3">
            <p>Contact Information</p>
          </div>
          {
            currentClient.referee_relationship !== 'self' &&
            <div className="col-xs-12 col-md-6 col-lg-6">
              <Checkbox
                label="Client is outside Cambodia"
                checked={currentClient.outside || false}
                onChange={handleOnChangeOther('outside')}
              />
            </div>
          }
        </div>
      </legend>
      <Address disabled={currentClient.referee_relationship === 'self'} outside={currentClient.outside || false} onChange={hanldeOnChangeAddressInputs} data={{addressTypes, currentDistricts: districts, currentCommunes: communes, currentVillages: villages, currentProvinces, objectKey: 'client', objectData: currentClient, T}} />
      <div className="row">
        <div className="col-xs-12 col-md-6">
          <div className="row">
            <div className="col-xs-12 col-md-6">
              <TextInput label="Client Contact Phone" type="number" onChange={handleOnChangeText('client_phone')} value={currentClient.client_phone} />
            </div>
            <div className="col-xs-12 col-md-6">
              <SelectInput label="Phone Owner" options={phoneEmailOwnerOpts} onChange={handleOnChangeOther('phone_owner')} value={currentClient.phone_owner}/>
            </div>
            <div className="col-xs-12 col-md-6">
              <TextInput label="Client Email Contact" onChange={handleOnChangeText('client_email')} value={currentClient.client_email} />
            </div>
            <div className="col-xs-12 col-md-6">
              <SelectInput label="Email Owner" options={phoneEmailOwnerOpts} onChange={handleOnChangeOther('email_owner')} value={currentClient.email_owner}/>
            </div>
          </div>
        </div>
        <div className={"col-xs-12 col-md-6" + (currentClient.outside ? ' hidden' : '')}>
          <TextArea
            label="Location Description"
            value={currentClient.location_description}
            onChange={handleOnChangeText('location_description')} />
        </div>
      </div>

      <br/>
      <legend>
        <div className="row">
          <div className="col-xs-12 col-md-6 col-lg-3">
            <p>Location of concern</p>
          </div>
          <div className="col-xs-12 col-md-6 col-lg-3">
            <Checkbox label="Same as Client" checked={currentClient.concern_same_as_client} onChange={onCheckSameAsClient} />
          </div>
          {!currentClient.concern_same_as_client &&
            <div className="col-xs-12 col-md-6 col-lg-6">
              <Checkbox
                label="Concern is outside Cambodia"
                checked={currentClient.concern_is_outside || false}
                onChange={handleOnChangeOther("concern_is_outside")}
              />
            </div>
          }
        </div>
      </legend>

      <ConcernAddress
        disabled={currentClient.concern_same_as_client}
        outside={currentClient.concern_is_outside || false}
        onChange={hanldeOnChangeAddressInputs}
        data={{
          addressTypes,
          currentDistricts: concernDistricts,
          currentCommunes: concernCommunes,
          currentVillages: concernVillages,
          currentProvinces,
          objectKey: "client",
          objectData: currentClient
        }}
      />

      <div className="row">
        <div className="col-xs-12 col-md-6">
          <div className="row">
            <div className="col-xs-12 col-md-6">
              <TextInput
                T={T}
                label="Relevant Contact Phone"
                onChange={handleOnChangeText("concern_phone")}
                value={currentClient.concern_phone}
              />
            </div>
            <div className="col-xs-12 col-md-6">
              <SelectInput
                T={T}
                label="Phone Owner"
                options={phoneEmailOwnerOpts}
                value={currentClient.concern_phone_owner}
                onChange={handleOnChangeOther("concern_phone_owner")}
              />
            </div>
          </div>
          <div className="row">
            <div className="col-xs-12 col-md-6">
              <TextInput
                T={T}
                label="Relevant Email Contact"
                onChange={handleOnChangeText("concern_email")}
                value={currentClient.concern_email}
              />
            </div>
            <div className="col-xs-12 col-md-6">
              <SelectInput
                T={T}
                label="Email Owner"
                options={phoneEmailOwnerOpts}
                value={currentClient.concern_email_owner}
                onChange={handleOnChangeOther("concern_email_owner")}
              />
            </div>
          </div>
        </div>
        <div className={"col-xs-12 col-md-6" + (currentClient.concern_is_outside ? ' hidden' : '')}>
          <TextArea
            label="Location Description"
            value={currentClient.concern_location}
            onChange={handleOnChangeText('concern_location')} />
        </div>
      </div>
    </div>
  );
};
