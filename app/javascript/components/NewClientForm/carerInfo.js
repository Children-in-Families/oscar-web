import React, { useState, useEffect } from 'react'
import {
  SelectInput,
  TextInput,
  Checkbox
}             from '../Commons/inputs'

import { t } from '../../utils/i18n'

export default props => {
  const { onChange, fieldsVisibility, translation, renderAddressSwitch, current_organization, id, hintText, data: { carerDistricts, carerCommunes, carerVillages, client, carer, clientRelationships, currentProvinces, currentStates, currentTownships, carerSubdistricts, families, addressTypes, T  } } = props

  const clientRelationship = clientRelationships.map(relationship => ({label: T.translate("clientRelationShip."+relationship.label), value: relationship.value}))
  const [districts, setDistricts]         = useState(carerDistricts)
  const [communes, setCommunes]           = useState(carerCommunes)
  const [villages, setVillages]           = useState(carerVillages)
  const [townships, setTownships]         = useState(currentTownships)
  const [subdistricts, setSubdistricts]   = useState(carerSubdistricts)


  const fetchData = (parent, data, child) => {
    $.ajax({
      type: 'GET',
      url: `/api/${parent}/${data}/${child}`,
    }).success(res => {
      const dataState = { districts: setDistricts, communes: setCommunes, villages: setVillages, townships: setTownships, subdistricts: setSubdistricts }
      dataState[child](res.data)
    })
  }

  const onCheckSameAsClient = data => {
    const same = data.data

    if(same) {
      if(client.province_id !== null)
        fetchData('provinces', client.province_id, 'districts')
      if(client.district_id !== null)
        if(current_organization.country == 'thailand'){
          fetchData('districts', client.district_id, 'subdistricts')
        } else{
          fetchData('districts', client.district_id, 'communes')
        }
      if(client.commune_id !== null)
        fetchData('communes', client.commune_id, 'villages')
      if(client.state_id !== null)
        fetchData('states', client.state_id, 'townships')
    } else {
      setDistricts([])
      setCommunes([])
      setVillages([])
      setTownships([])
      setSubdistricts([])
    }

    const fields = {
      outside: same ? client.outside : false,
      province_id: same ? client.province_id : null,
      district_id: same ? client.district_id : null,
      commune_id: same ? client.commune_id : null,
      village_id: same ? client.village_id : null,
      state_id: same ? client.state_id : null,
      township_id: same ? client.township_id : null,
      subdistrict_id: same ? client.subdistrict_id : null,
      street_line1: same ? client.subdistrict_id : '',
      street_line2: same ? client.subdistrict_id : '',
      plot: same ? client.plot : '',
      road: same ? client.road : '',
      postal_code: same ? client.postal_code : '',
      suburb: same ? client.suburb : '',
      description_house_landmark: same ? client.description_house_landmark : '',
      directions: same ? client.directions : '',
      street_number: same ? client.street_number : '',
      house_number: same ? client.house_number : '',
      current_address: same ? client.current_address : '',
      locality: same ? client.locality : '',
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
        if(current_organization.country == 'thailand'){
          fetchData('districts', client.district_id, 'subdistricts')
        } else{
          fetchData('districts', client.district_id, 'communes')
        }
      if(client.commune_id !== null)
        fetchData('communes', client.commune_id, 'villages')
      if(client.state_id !== null)
        fetchData('states', client.state_id, 'townships')
    }

    const fields = {
      outside: object.outside,
      province_id: object.province_id,
      district_id: object.district_id,
      commune_id: object.commune_id,
      village_id: object.village_id,
      state_id: object.state_id,
      township_id: object.township_id,
      subdistrict_id: object.subdistrict_id,
      street_number: object.street_number,
      house_number: object.house_number,
      current_address: object.current_address,
      address_type: object.address_type,
      outside_address: object.outside_address,
      locality: object.locality,
      street_line1: object.street_line1,
      street_line2: object.street_line2,
      plot: object.plot,
      road: object.road,
      postal_code: object.postal_code,
      suburb: object.suburb,
      description_house_landmark: object.description_house_landmark,
      directions: object.directions
    }

    onChange('carer', { ...fields })({type: 'select'})
  }, [carer.same_as_client, client])

  const genderLists = [
    { label: T.translate("refereeInfo.female"), value: 'female' },
    { label: T.translate("refereeInfo.male"), value: 'male' },
    { label: T.translate("refereeInfo.other"), value: 'other' },
    { label: T.translate("refereeInfo.unknown"), value: 'unknown' }
  ]
  const familyLists = families.map(family => ({ label: family.name, value: family.id }))

  const onChangeFamily = ({ data, action, type }) => {
    let values = []
    if (action === 'select-option'){
      values = client.family_ids
      values.push(data)
      values = values.filter((v, i, a) => a.indexOf(v) === i);
      onChange('client', 'family_ids')({data: values, type})
    }
    // onChange('client', 'family_ids')({data: value, type})
    onChange('client', 'current_family_id')({data: data, type})
  }

  return (
    <div id={id} className="collapse">
      <br/>
      <div className="row">
        {
          fieldsVisibility.carer_name == true &&
          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label={ t(translation, 'activerecord.attributes.carer.name')}
              onChange={onChange('carer', 'name')}
              value={carer.name}
              inlineClassName="carer-name"
              hintText={current_organization.short_name == 'ratanak' ? hintText.carer.ratanak.carer_name : hintText.carer.carer_name}
            />
          </div>
        }

        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            label={T.translate("carerInfo.gender")}
            options={genderLists} onChange={onChange('carer', 'gender')}
            value={carer.gender}
            inlineClassName="carer-gender"
            hintText={hintText.carer.carer_gender}
          />
        </div>
      </div>
      <div className="row">
        {
          fieldsVisibility.carer_phone == true &&
          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label={ t(translation, 'activerecord.attributes.carer.phone')}
              type="text" onChange={onChange('carer', 'phone')}
              value={carer.phone}
              hintText={hintText.carer.carer_phone}
            />
          </div>
        }

        {
          fieldsVisibility.carer_email == true &&
          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label={ t(translation, 'activerecord.attributes.carer.email')}
              type="text" onChange={onChange('carer', 'email')}
              value={carer.phone}
              hintText={hintText.carer.carer_email}
            />
          </div>
        }

        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            label={T.translate("carerInfo.client_relationship")}
            options={clientRelationship} onChange={onChange('carer', 'client_relationship')}
            value={carer.client_relationship}
            hintText={hintText.carer.carer_relationship}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            label={T.translate("carerInfo.family_record")}
            options={familyLists} value={client.current_family_id}
            onChange={onChangeFamily}
            hintText={hintText.carer.carer_family_record}
          />
          <TextInput type="hidden" name="client[current_family_id]" value={ client.current_family_id } />
        </div>
      </div>
      <legend>
        <div className="row">
          <div className="col-xs-12 col-md-6 col-lg-3">
            <p>{T.translate("carerInfo.address")}</p>
          </div>
          {
            !carer.outside &&
            <div className="col-xs-12 col-md-6 col-lg-3">
              <Checkbox
                label={T.translate("carerInfo.same_as_client")}
                checked={carer.same_as_client} onChange={onCheckSameAsClient}
              />
            </div>
          }
          {
            !carer.same_as_client &&
            <div className="col-xs-12 col-md-6 col-lg-3">
              <Checkbox
                label={T.translate("carerInfo.outside_cambodia")}
                checked={carer.outside} onChange={onChange('carer', 'outside')}
              />
            </div>
          }
        </div>
      </legend>
      { renderAddressSwitch(carer, 'carer', carer.same_as_client, { districts, communes, villages }) }
    </div>
  )
}
