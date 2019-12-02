import React, { useState } from 'react'
import {
  TextInput,
  SelectInput,
  TextArea
} from '../Commons/inputs'

export default props => {
  const { onChange, checked, data: { currentProvinces, objectKey, objectData, currentCommunes = [], currentDistricts = [], currentVillages = [] } } = props

  const addressType = [{ label: 'Floor', value: 'floor' }, { label: 'Building', value: 'building' }, { label: 'Office', value: 'office' }]

  const [districts, setdistricts] = useState(currentDistricts.map(district => ({label: district.name, value: district.id})))
  const [communes, setcommunes] = useState(currentCommunes.map(commune => ({ label: commune.name_kh + ' / ' + commune.name_en, value: commune.id})))
  const [villages, setvillages] = useState(currentVillages.map(village => ({ label: village.name_kh + ' / ' + village.name_en, value: village.id})))
  const [provinces, setprovinces] = useState(currentProvinces.map(province => ({label: province.name, value: province.id})))

  const onChangeParent = object => ({data, type}) => {
    const { parent, child, field, obj } = object
    const functions = [setdistricts, setcommunes, setvillages]

    if (parent === 'provinces') {
      onChange(obj, {district_id: null, commune_id: null, village_id: null, [field]: data})({type})
      if (data === null)
        functions.forEach(func => func([]))
    } else if (parent === 'districts') {
      onChange(obj, {commune_id: null, village_id: null, [field]: data})({type})
      if (data === null)
        functions.splice(0, 1).forEach(func => func([]))
    } else if (parent === 'communes') {
      onChange(obj, {village_id: null, [field]: data})({type})
      if (data === null)
        functions.splice(0, 2).forEach(func => func([]))
    } else if (parent === 'villages') {
      onChange(obj, {[field]: data})({type})
    }else{
      onChange(obj, field)(data)
    }

    if(parent !== 'villages' && data !== null)
      $.ajax({
        type: 'GET',
        url: `/api/${parent}/${data}/${child}`,
      }).success(res => {
        const formatedData = res.data.map(data => ({ label: data.name, value: data.id }))
        const dataState = { districts: setdistricts, communes: setcommunes, villages: setvillages }
        dataState[child](formatedData)
      })
  }

  return (
    checked == true ?
      <TextArea label="Out Side Address" value={objectData.outside_address} onChange={onChange(objectKey, 'outside_address')} /> :
      <>
        <div className="row">
          <div className="col-xs-3">
            <SelectInput
              label="Province"
              options={provinces}
              value={objectData.province_id}
              onChange={onChangeParent({parent: 'provinces', child: 'districts', obj: objectKey, field: 'province_id'})}
            />
          </div>
          <div className="col-xs-3">
            <SelectInput
              label="District / Khan"
              options={districts}
              value={objectData.district_id}
              onChange={onChangeParent({parent: 'districts', child: 'communes', obj: objectKey, field: 'district_id'})}
            />
          </div>
          <div className="col-xs-3">
            <SelectInput
              label="Commune / Sangkat"
              options={communes}
              value={objectData.commune_id}
              onChange={onChangeParent({parent: 'communes', child: 'villages', obj: objectKey, field: 'commune_id'})}
            />
          </div>
          <div className="col-xs-3">
            <SelectInput
              label="Village"
              options={villages}
              value={objectData.village_id}
              onChange={onChangeParent({parent: 'villages', child: 'villages', obj: objectKey, field: 'village_id'})}
            />
          </div>
        </div>
        <div className="row">
          <div className="col-xs-3">
            <TextInput label="Street Number" onChange={onChange(objectKey, 'street_number')} value={objectData.street_number} />
          </div>
          <div className="col-xs-3">
            <TextInput label="House Number" onChange={onChange(objectKey, 'house_number')} value={objectData.house_number} />
          </div>
          <div className="col-xs-3">
            <TextInput label="Address Name" onChange={onChange(objectKey, 'current_address')} value={objectData.current_address} />
          </div>
          <div className="col-xs-3">
            <SelectInput label="Address Type" options={addressType} onChange={onChange(objectKey, 'address_type')} value={objectData.address_type}/>
          </div>
        </div>
      </>
  )
}
