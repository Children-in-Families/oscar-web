import React, { useEffect, useState } from "react";
import { SelectInput, TextArea, TextInput, Checkbox, DateInput } from "../Commons/inputs";
import ConcernAddress from "./concernAddress";
import Address from './address'
import Modal from '../Commons/Modal'
import ConfirmRemoveClientModal from "./confirmRemoveClientModal";

export default props => {
  const {
    onChange,
    data: {
      call,
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
  const refereeRelationshipOpts = refereeRelationships.map(relationship => ({ label: T.translate("refereeRelationShip." + relationship.label), value: relationship.value }))
  const userLists = users.map(user => ({label: user[0], value: user[1], isFixed: user[2] === 'locked' ? true : false }))

  const phoneEmailOwnerOpts = phoneOwners.map(phone => ({ label: T.translate("phoneOwner." + phone.label), value: phone.value }))
  // same as phone owner
  // const emailOwnerOpts = phoneOwners.map(phone => ({ label: phone.label, value: phone.value }))

  const genderLists = [
    { label: T.translate("genderLists.female"), value: 'female' },
    { label: T.translate("genderLists.male"), value: 'male' },
    { label: T.translate("genderLists.lgbt"), value: 'lgbt' },
    { label: T.translate("genderLists.unknown"), value: 'unknown' },
    { label: T.translate("genderLists.prefer_not_to_say"), value: 'prefer_not_to_say' },
    { label: T.translate("genderLists.other"), value: 'other' }
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

  const [confirmRemoveClient, setConfirmRemoveClientModalOpen] = useState(false)

  const setAddressOptions = (obj, type) => {
    if (type === 'concern_address') {
      const concernDataState = {
        districts: setConcernDistricts,
        communes: setConcernCommunes,
        villages: setConcernVillages
      }

      if(obj.concern_province_id !== null && obj.concern_province_id !== undefined)
        fetchData('provinces', obj.concern_province_id, 'districts', concernDataState)
      if(obj.concern_district_id !== null && obj.concern_district_id !== undefined)
        fetchData('districts', obj.concern_district_id, 'communes', concernDataState)
      if(obj.concern_commune_id !== null && obj.concern_commune_id !== undefined)
        fetchData('communes', obj.concern_commune_id, 'villages', concernDataState)
    } else {
      const dataState = {
        districts: setDistricts,
        communes: setCommunes,
        villages: setVillages
      }

      if(obj.province_id !== null && obj.province_id !== undefined)
        fetchData('provinces', obj.province_id, 'districts', dataState)
      if(obj.district_id !== null && obj.district_id !== undefined)
        fetchData('districts', obj.district_id, 'communes', dataState)
      if(obj.commune_id !== null && obj.commune_id !== undefined)
        fetchData('communes', obj.commune_id, 'villages', dataState)
    }
  }

  const resetAddressOptions = type => {
    if(type === 'concern_address') {
      setConcernDistricts([])
      setConcernCommunes([])
      setConcernVillages([])
    } else {
      setDistricts([])
      setCommunes([])
      setVillages([])
    }
  }

  useEffect(() => {
    const newObjects = clients.map(client => {
      let newObject = { ...client }
      if(client.referee_relationship === 'self' || call.call_type === "Phone Counselling" ) {
        const fields = {
          referee_relationship: 'self',
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
        newObject = { ...client, ...fields }
      }
      return newObject
    })

    setAddressOptions(currentClient, 'address')

    onChange('client', newObjects)({type: 'object'})
  }, [referee, call])

  useEffect(() => {
    setAddressOptions(currentClient, 'address')
    setAddressOptions(currentClient, 'concern_address')
  }, [clientIndex])

  useEffect(() => {
    if(currentClient.concern_same_as_client) {
      const {
        concern_same_as_client, concern_is_outside,
        concern_province_id, concern_district_id, concern_commune_id, concern_village_id,
        concern_street, concern_house, concern_address, concern_address_type, concern_outside_address,
        outside,
        province_id, district_id, commune_id, village_id,
        street_number, house_number, current_address, address_type, outside_address,
      } = currentClient

      const sameOutside = concern_is_outside === outside
      const sameProvince = concern_province_id === province_id
      const sameDistrict = concern_district_id === district_id
      const sameCommune = concern_commune_id === commune_id
      const sameVillage = concern_village_id === village_id
      const sameStreet = concern_street === street_number
      const sameHouse = concern_house === house_number
      const sameAddress = concern_address === current_address
      const sameAddressType = concern_address_type === address_type
      const sameOutsideAdress = concern_outside_address === outside_address

      const same = sameOutside && sameProvince && sameDistrict && sameCommune && sameVillage && sameStreet && sameHouse && sameAddress && sameAddressType && sameOutsideAdress

      if(!same)
        onCheckSameAsClient({data: concern_same_as_client})
    }
  }, [currentClient])

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

    if(same)
      setAddressOptions(currentClient, 'concern_address')
    else
      resetAddressOptions('concern_address')

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

    if(isSelf)
      setAddressOptions(refereeObj, 'address')
    else if(previousSelect === 'self')
      resetAddressOptions('address')

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
    if(typeof(field) === 'object')
      modifyClientObject(clientIndex, field)
    else {
      const value = event.target && event.target.value || event.data
      modifyClientObject(clientIndex, { [field]: value })
    }
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
      <Modal
        title={T.translate("newCall.referralInfo.confirmation")}
        isOpen={confirmRemoveClient}
        type='warning'
        closeAction={() => setConfirmRemoveClientModalOpen(false)}
        content={
          <ConfirmRemoveClientModal
            data={{T}}
            onClick={() => { setConfirmRemoveClientModalOpen(false); removeClient() }}
            closeAction={() => setConfirmRemoveClientModalOpen(false) }
          />
        }
      />

      <legend>
        <div className="row">
          <div className="col-xs-12 col-md-6">
            <p>{T.translate("newCall.referralInfo.client_referral")}</p>
          </div>

          <div className={ `col-xs-12 col-md-6 col-lg-4 ${ call.call_type === 'Phone Counselling' ? 'hidden' : '' }` }>
            { renderClientNavigation()}
          </div>
        </div>
      </legend>

      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            T={T}
            label={T.translate("newCall.referralInfo.given_name")}
            onChange={handleOnChangeText("given_name")}
            value={currentClient.given_name}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            T={T}
            label={T.translate("newCall.referralInfo.family_name")}
            onChange={handleOnChangeText("family_name")}
            value={currentClient.family_name}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            T={T}
            label={T.translate("newCall.referralInfo.given_name_khmer")}
            onChange={handleOnChangeText("local_given_name")}
            value={currentClient.local_given_name}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            T={T}
            label={T.translate("newCall.referralInfo.family_name_khmer")}
            onChange={handleOnChangeText("local_family_name")}
            value={currentClient.local_family_name}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            T={T}
            label={T.translate("newCall.referralInfo.nickname")}
            onChange={handleOnChangeText("nickname")}
            value={currentClient.nickname}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <DateInput
            getCurrentDate
            label={T.translate("newCall.referralInfo.date_of_birth")}
            onChange={handleOnChangeOther('date_of_birth')}
            value={currentClient.date_of_birth}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            T={T}
            required
            isError={errorFields.includes("gender") && (currentClient.gender === undefined || currentClient.gender === null)}
            label={T.translate("newCall.referralInfo.gender")}
            options={genderLists}
            value={currentClient.gender}
            onChange={handleOnChangeOther("gender")}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            T={T}
            asGroup
            label={T.translate("newCall.referralInfo.birth_province")}
            options={birthProvincesLists}
            value={currentClient.birth_province_id}
            onChange={handleOnChangeOther("birth_province_id")}
          />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            isDisabled={call.call_type === 'Phone Counselling'}
            T={T}
            label={T.translate("newCall.referralInfo.relationshio_to_caller")}
            options={refereeRelationshipOpts}
            value={currentClient.referee_relationship}
            onChange={onRelationshipChange}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            T={T}
            required
            isError={errorFields.includes('user_ids') && (currentClient.user_ids !== undefined && currentClient.user_ids.length < 1) || (currentClient.user_ids === undefined || currentClient.user_ids === null) }
            label={T.translate("newCall.referralInfo.case_worker")}
            isMulti
            options={userLists}
            value={currentClient.user_ids}
            onChange={handleOnChangeOther('user_ids')}
          />
        </div>
      </div>
      <legend>
        <div className="row">
          <div className="col-xs-12 col-md-6 col-lg-3">
            <p>{T.translate("newCall.referralInfo.contact_info")}</p>
          </div>
          {
            currentClient.referee_relationship !== 'self' &&
            <div className="col-xs-12 col-md-6 col-lg-6">
              <Checkbox
                label={T.translate("newCall.referralInfo.client_is_outside")}
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
              <TextInput label={T.translate("newCall.referralInfo.client_contact_phone")} type="text" onChange={handleOnChangeText('client_phone')} value={currentClient.client_phone} />
            </div>
            <div className="col-xs-12 col-md-6">
              <SelectInput label={T.translate("newCall.referralInfo.phone_owner")} options={phoneEmailOwnerOpts} onChange={handleOnChangeOther('phone_owner')} value={currentClient.phone_owner}/>
            </div>
            <div className="col-xs-12 col-md-6">
              <TextInput label={T.translate("newCall.referralInfo.client_email")} onChange={handleOnChangeText('client_email')} value={currentClient.client_email} />
            </div>
            <div className="col-xs-12 col-md-6">
              <SelectInput label={T.translate("newCall.referralInfo.email_owner")} options={phoneEmailOwnerOpts} onChange={handleOnChangeOther('email_owner')} value={currentClient.email_owner}/>
            </div>
          </div>
        </div>
        <div className={"col-xs-12 col-md-6" + (currentClient.outside ? ' hidden' : '')}>
          <TextArea
            label={T.translate("newCall.referralInfo.location_description")}
            value={currentClient.location_description}
            onChange={handleOnChangeText('location_description')} />
        </div>
      </div>

      <div className={ `col-xs-12 text-right ${ call.call_type === 'Phone Counselling' ? 'hidden' : '' }` }>
        <button className="btn btn-primary" style={{ margin: 5 }} onClick={() => { onChange('client', {})({ type: 'newObject' }); setClientIndex(clients.length) }}>{T.translate("newCall.referralInfo.add_another_client")}</button>
        { clients.length > 1 &&
          <button className="btn btn-danger" style={{ margin: 5 }} onClick={() => setConfirmRemoveClientModalOpen(true) }>{T.translate("newCall.referralInfo.remove_client")}</button>
        }
      </div>

      <br/>

      { clientIndex === 0 ?
        <>
        <legend>
          <div className="row">
            <div className="col-xs-12 col-md-6 col-lg-3">
              <p>{T.translate("newCall.referralInfo.location_of_concern")}</p>
            </div>
            <div className="col-xs-12 col-md-6 col-lg-3">
              <Checkbox label={T.translate("newCall.referralInfo.same_as_client")} checked={currentClient.concern_same_as_client} onChange={onCheckSameAsClient} />
            </div>
            {!currentClient.concern_same_as_client &&
              <div className="col-xs-12 col-md-6 col-lg-6">
                <Checkbox
                  label={T.translate("newCall.referralInfo.concern_is_outside_cambodia")}
                  checked={currentClient.concern_is_outside || false}
                  onChange={handleOnChangeOther("concern_is_outside")}
                />
              </div>
            }
          </div>
        </legend>

        <ConcernAddress
          disabled={clients[0].concern_same_as_client}
          outside={clients[0].concern_is_outside || false}
          onChange={hanldeOnChangeAddressInputs}
          data={{
            addressTypes,
            currentDistricts: concernDistricts,
            currentCommunes: concernCommunes,
            currentVillages: concernVillages,
            currentProvinces,
            objectKey: "client",
            objectData: clients[0],
            T
          }}
        />

        <div className="row">
          <div className="col-xs-12 col-md-6">
            <div className="row">
              <div className="col-xs-12 col-md-6">
                <TextInput
                  T={T}
                  label={T.translate("newCall.referralInfo.relevant_contact_phone")}
                  onChange={handleOnChangeText("concern_phone")}
                  value={clients[0].concern_phone}
                />
              </div>
              <div className="col-xs-12 col-md-6">
                <SelectInput
                  T={T}
                  label={T.translate("newCall.referralInfo.phone_owner")}
                  options={phoneEmailOwnerOpts}
                  value={clients[0].concern_phone_owner}
                  onChange={handleOnChangeOther("concern_phone_owner")}
                />
              </div>
            </div>
            <div className="row">
              <div className="col-xs-12 col-md-6">
                <TextInput
                  T={T}
                  label={T.translate("newCall.referralInfo.relevant_email")}
                  onChange={handleOnChangeText("concern_email")}
                  value={clients[0].concern_email}
                />
              </div>
              <div className="col-xs-12 col-md-6">
                <SelectInput
                  T={T}
                  label={T.translate("newCall.referralInfo.email_owner")}
                  options={phoneEmailOwnerOpts}
                  value={clients[0].concern_email_owner}
                  onChange={handleOnChangeOther("concern_email_owner")}
                />
              </div>
            </div>
          </div>
          <div className={"col-xs-12 col-md-6" + (clients[0].concern_is_outside ? ' hidden' : '')}>
            <TextArea
              label={T.translate("newCall.referralInfo.locatin_description")}
              value={clients[0].concern_location}
              onChange={handleOnChangeText('concern_location')} />
          </div>
        </div>
      </>
      :
      <div></div>
      }
    </div>
  );
};
