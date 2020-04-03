import React, { useState, useEffect } from 'react'
import {
  TextInput,
  SelectInput,
  TextArea
} from '../Commons/inputs'

export default props => {
  const { onChange, disabled, outside, data: { client, currentProvinces, objectKey, objectData, addressTypes, currentDistricts = [], subDistricts = [], T } } = props

  const [provinces, setprovinces] = useState(currentProvinces.map(province => ({label: province.name, value: province.id})))
  const [districts, setdistricts] = useState(currentDistricts.map(district => ({label: district.name, value: district.id})))
  const [subdistricts, setSubDistricts] = useState(subDistricts.map(subDistrict => ({ label: subDistrict.name, value: subDistrict.id})))
  const typeOfAddress = addressTypes.map(type => ({ label: T.translate("addressType."+type.label), value: type.value }))
  useEffect(() => {
    setdistricts(currentDistricts.map(district => ({label: district.name, value: district.id})))
    setSubDistricts(subDistricts.map(subDistrict => ({ label: subDistrict.name && subDistrict.name, value: subDistrict.id})))
    // if(outside) {
    //   onChange(objectKey, { province_id: null, district_id: null, subdistrict_id: null, village_id: null, house_number: '', street_number: '', current_address: '', address_type: '' })({type: 'select'})
    // } else {
    //   onChange(objectKey, { outside_address: '' })({type: 'select'})
    // }
  }, [currentDistricts, subDistricts])

  const updateValues = object => {
    const { parent, child, field, obj, data } = object

    const parentConditions = {
      'provinces': {
        fieldsTobeUpdate: { district_id: null, subdistrict_id: null, [field]: data },
        optionsTobeResets: [setdistricts, setSubDistricts]
      },
      'districts': {
        fieldsTobeUpdate: { subdistrict_id: null, [field]: data },
        optionsTobeResets: [setSubDistricts]
      },
      'subdistricts': {
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

    if(parent !== 'subdistricts' && data !== null) {
      $.ajax({
        type: 'GET',
        url: `/api/${parent}/${data}/${child}`,
      }).success(res => {
        const formatedData = res.data.map(data => ({ label: data.name, value: data.id }))
        const dataState = { districts: setdistricts, subdistricts: setSubDistricts }
        dataState[child](formatedData)
      })
    }
  }

  return (
    outside == true ?
      <TextArea label={T.translate("address.outside_address")} disabled={disabled} value={objectData.outside_address} onChange={onChange(objectKey, 'outside_address')} />
    :
      <>
        <div className="row">
          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label={T.translate("address.thailand.plot")}
              disabled={disabled}
              onChange={onChange(objectKey, 'plot')}
              value={objectData.plot}
            />
          </div>

          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label={T.translate("address.thailand.road")}
              disabled={disabled}
              onChange={onChange(objectKey, 'road')}
              value={objectData.road}
            />
          </div>

          <div className="col-xs-12 col-md-6 col-lg-3">
            <SelectInput
              label={T.translate("address.thailand.province")}
              options={provinces}
              isDisabled={disabled}
              value={objectData.province_id}
              onChange={onChangeParent({parent: 'provinces', child: 'districts', obj: objectKey, field: 'province_id'})}
            />
          </div>

          <div className="col-xs-12 col-md-6 col-lg-3">
            <SelectInput
              label={T.translate("address.thailand.district")}
              isDisabled={disabled}
              options={districts}
              value={objectData.district_id}
              onChange={onChangeParent({parent: 'districts', child: 'subdistricts', obj: objectKey, field: 'district_id'})}
            />
          </div>
        </div>

        <div className="row">
          <div className="col-xs-12 col-md-6 col-lg-3">
            <SelectInput
              label={T.translate("address.thailand.subdistrict")}
              isDisabled={disabled}
              options={subdistricts}
              value={objectData.subdistrict_id}
              onChange={onChangeParent({parent: 'subdistricts', child: 'subdistricts', obj: objectKey, field: 'subdistrict_id'})}
            />
          </div>

          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label={T.translate("address.thailand.postal_code")}
              disabled={disabled}
              onChange={onChange(objectKey, 'postal_code')}
              value={objectData.postal_code}
            />
          </div>

          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label={T.translate("address.street_number")}
              disabled={disabled}
              onChange={onChange(objectKey, 'street_number')}
              value={objectData.street_number}
            />
          </div>

          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label={T.translate("address.house_number")}
              disabled={disabled}
              onChange={onChange(objectKey, 'house_number')}
              value={objectData.house_number}
            />
          </div>
        </div>

        <div className="row">
          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label={T.translate("address.address_name")}
              disabled={disabled}
              onChange={onChange(objectKey, 'current_address')}
              value={objectData.current_address}
            />
          </div>

          <div className="col-xs-12 col-md-6 col-lg-3">
            <SelectInput
              label={T.translate("address.address_type")}
              isDisabled={disabled}
              options={typeOfAddress}
              onChange={onChange(objectKey, 'address_type')}
              value={objectData.address_type}
            />
          </div>
        </div>
      </>
  )
}
