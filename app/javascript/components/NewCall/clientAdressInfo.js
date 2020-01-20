import React, { useState, useEffect } from 'react'
import {
  SelectInput,
  TextInput,
  Checkbox,
  TextArea
}             from '../Commons/inputs'
import Address from './address'

export default props => {
  const { onChange, id, data: { client, currentDistricts, currentCommunes, currentVillages, currentProvinces, addressTypes, phoneOwners, T } } = props
  const phoneOwner = phoneOwners.map(phone => ({ label: T.translate("phoneOwner."+phone.label), value: phone.value }))

  // const [districts, setDistricts]         = useState(currentDistricts)
  // const [communes, setCommunes]           = useState(currentCommunes)
  // const [villages, setVillages]           = useState(currentVillages)

  // const fetchData = (parent, data, child) => {
  //   $.ajax({
  //     type: 'GET',
  //     url: `/api/${parent}/${data}/${child}`,
  //   }).success(res => {
  //     const dataState = { districts: setDistricts, communes: setCommunes, villages: setVillages }
  //     dataState[child](res.data)
  //   })
  // }

  // useEffect(() => {
  //   let object = client

  //   if(client.same_as_concern_location) {
  //     object = client
  //     if(client.province_id !== null)
  //       fetchData('provinces', client.province_id, 'districts')
  //     if(client.district_id !== null)
  //       fetchData('districts', client.district_id, 'communes')
  //     if(client.commune_id !== null)
  //       fetchData('communes', client.commune_id, 'villages')
  //   }

  //   const fields = {
  //     outside: object.outside,
  //     province_id: object.province_id,
  //     district_id: object.district_id,
  //     commune_id: object.commune_id,
  //     village_id: object.village_id,
  //     street_number: object.street_number,
  //     house_number: object.house_number,
  //     current_address: object.current_address,
  //     address_type: object.address_type,
  //     outside_address: object.outside_address
  //   }

  //   onChange('client', { ...fields })({type: 'select'})
  // }, [client.same_as_concern_location, client])

  return (
    // <div id={id} className="collapse">
    <div id="" className="">
      <br/>
      <legend>
        <div className="row">
          <div className="col-xs-12 col-md-6 col-lg-3">
            <p>{T.translate("newCall.clientAddressInfo.address")}</p>
          </div>
          {
            // !client.outside &&
            // <div className="col-xs-12 col-md-6 col-lg-4">
            //   {/* todo: add same_as_concern_location to clients table */}
            //   <Checkbox label="Same as Location of Concern" checked={client.same_as_concern_location} onChange={onChange('client', 'same_as_concern_location')} />
            // </div>
          }
          {
            !client.same_as_concern_location &&
            <div className="col-xs-12 col-md-6 col-lg-3">
              <Checkbox label={T.translate("newCall.clientAddressInfo.outside_cambodia")} checked={client.outside} onChange={onChange('client', 'outside')} />
            </div>
          }
        </div>
      </legend>
      <Address disabled={client.same_as_concern_location} outside={client.outside} onChange={onChange} data={{client, currentDistricts, currentCommunes, currentVillages, currentProvinces, addressTypes, objectKey: 'client', objectData: client, T}} />

      <div className="row">
        <div className="col-xs-12 col-md-6">
          <div className="row">
            <div className="col-xs-12 col-md-6">
              <TextInput label={T.translate("newCall.clientAddressInfo.client_contact")} type="number" onChange={onChange('client', 'client_phone')} value={client.client_phone} />
            </div>
            <div className="col-xs-12 col-md-6">
              <SelectInput label={T.translate("newCall.clientAddressInfo.phone_owner")} options={phoneOwner} onChange={onChange('client', 'phone_owner')} value={client.phone_owner}/>
            </div>
            <div className="col-xs-12 col-md-6">
              <TextInput label={T.translate("newCall.clientAddressInfo.client_email")} onChange={onChange('client', 'client_email')} value={client.client_email} />
            </div>
            <div className="col-xs-12 col-md-6">
              <SelectInput label={T.translate("newCall.clientAddressInfo.email_owner")} options={phoneOwner} onChange={onChange('client', 'email_owner')} value={client.email_owner}/>
            </div>
          </div>
        </div>
        <div className={"col-xs-12 col-md-6" + (client.outside ? ' hidden' : '')}>
          <TextArea
            label={T.translate("newCall.clientAddressInfo.location_description")}
            value={client.location_description}
            onChange={onChange('client', 'location_description')} />
        </div>
      </div>
    </div>
  )
}
