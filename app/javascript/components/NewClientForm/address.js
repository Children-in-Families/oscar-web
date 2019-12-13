import React, { useState, useEffect } from 'react'
import {
  TextInput,
  SelectInput,
  TextArea
} from '../Commons/inputs'

export default props => {
  const { onChange, sameAsClient, outside, data: { client, currentProvinces, objectKey, objectData, addressTypes, currentCommunes = [], currentDistricts = [], currentVillages = [] } } = props

  const [provinces, setprovinces] = useState(currentProvinces.map(province => ({label: province.name, value: province.id})))
  const [districts, setdistricts] = useState(currentDistricts.map(district => ({label: district.name, value: district.id})))
  const [communes, setcommunes] = useState(currentCommunes.map(commune => ({ label: commune.name_kh + ' / ' + commune.name_en, value: commune.id})))
  const [villages, setvillages] = useState(currentVillages.map(village => ({ label: village.name_kh + ' / ' + village.name_en, value: village.id})))

  useEffect(() => {
    setdistricts(currentDistricts.map(district => ({label: district.name, value: district.id})))
    setcommunes(currentCommunes.map(commune => ({ label: commune.name && commune.name || `${commune.name_kh} / ${commune.name_en}`, value: commune.id})))
    setvillages(currentVillages.map(village => ({ label: village.name && village.name || `${village.name_kh} / ${village.name_en}`, value: village.id})))

    if(outside) {
      onChange(objectKey, {province_id: null, district_id: null, commune_id: null, village_id: null, house_number: '', street_number: '', address: '', address_type: ''})({type: 'select'})
    } else {
      onChange(objectKey, {outside_address: ''})({type: 'select'})
    }
  }, [currentDistricts, currentCommunes, currentVillages, outside])

  const updateValues = object => {
    const { parent, child, field, obj, data } = object

    const parentConditions = {
      'provinces': {
        fieldsTobeUpdate: { district_id: null, commune_id: null, village_id: null, [field]: data },
        optionsTobeResets: [setdistricts, setcommunes, setvillages]
      },
      'districts': {
        fieldsTobeUpdate: { commune_id: null, village_id: null, [field]: data },
        optionsTobeResets: [setcommunes, setvillages]
      },
      'communes': {
        fieldsTobeUpdate: { village_id: null, [field]: data },
        optionsTobeResets: [setvillages]
      },
      'villages': {
        fieldsTobeUpdate: { [field]: data },
        optionsTobeResets: []
      }
    }

    onChange(obj, parentConditions[parent].fieldsTobeUpdate)({type: 'select'})

    if(data === null)
      parentConditions[parent].optionsTobeResets.forEach(func => func([]))
  }

  const onChangeParent = object => ({ data }) => {
    const { parent, child } = object

    updateValues({ ...object, data})

    if(parent !== 'villages' && data !== null) {
      $.ajax({
        type: 'GET',
        url: `/api/${parent}/${data}/${child}`,
      }).success(res => {
        const formatedData = res.data.map(data => ({ label: data.name, value: data.id }))
        const dataState = { districts: setdistricts, communes: setcommunes, villages: setvillages }
        dataState[child](formatedData)
      })
    }
  }

  return (
    outside == true ?
      <TextArea label="Out Side Address" disabled={sameAsClient} value={objectData.outside_address} onChange={onChange(objectKey, 'outside_address')} />
    :
      <>
        <div className="row">
          <div className="col-xs-12 col-md-6 col-lg-3">
            <SelectInput
              label="Province"
              options={provinces}
              isDisabled={sameAsClient}
              value={objectData.province_id}
              onChange={onChangeParent({parent: 'provinces', child: 'districts', obj: objectKey, field: 'province_id'})}
            />
          </div>

          <div className="col-xs-12 col-md-6 col-lg-3">
            <SelectInput
              label="District / Khan"
              isDisabled={sameAsClient}
              options={districts}
              value={objectData.district_id}
              onChange={onChangeParent({parent: 'districts', child: 'communes', obj: objectKey, field: 'district_id'})}
            />
          </div>

          <div className="col-xs-12 col-md-6 col-lg-3">
            <SelectInput
              label="Commune / Sangkat"
              isDisabled={sameAsClient}
              options={communes}
              value={objectData.commune_id}
              onChange={onChangeParent({parent: 'communes', child: 'villages', obj: objectKey, field: 'commune_id'})}
            />
          </div>

          <div className="col-xs-12 col-md-6 col-lg-3">
            <SelectInput
              label="Village"
              isDisabled={sameAsClient}
              options={villages}
              value={objectData.village_id}
              onChange={onChangeParent({parent: 'villages', child: 'villages', obj: objectKey, field: 'village_id'})}
            />
          </div>
        </div>

        <div className="row">
          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label="Street Number"
              disabled={sameAsClient}
              onChange={onChange(objectKey, 'street_number')}
              value={objectData.street_number}
            />
          </div>

          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label="House Number"
              disabled={sameAsClient}
              onChange={onChange(objectKey, 'house_number')}
              value={objectData.house_number}
            />
          </div>

          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label="Address Name"
              disabled={sameAsClient}
              onChange={onChange(objectKey, 'current_address')}
              value={objectData.current_address}
            />
          </div>

          <div className="col-xs-12 col-md-6 col-lg-3">
            <SelectInput
              label="Address Type"
              isDisabled={sameAsClient}
              options={addressTypes}
              onChange={onChange(objectKey, 'address_type')}
              value={objectData.address_type}
            />
          </div>
        </div>
      </>
  )
}
