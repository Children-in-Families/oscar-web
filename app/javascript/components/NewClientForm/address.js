import React, { useState } from 'react'
import {
  TextInput,
  SelectInput,
  TextArea
} from '../Commons/inputs'

export default props => {
  const { onChange, checked, data: { currentProvinces, client } } = props

  const addressType = [{ label: 'Floor', value: 'floor' }, { label: 'Building', value: 'building' }, { label: 'Office', value: 'office' }]

  const [districts, setdistricts] = useState([])
  const [communes, setcommunes] = useState([])
  const [villages, setvillages] = useState([])
  const [provinces, setprovinces] = useState(currentProvinces.map(province => ({ label: province.name, value: province.id })))

  const getSeletedObject = (obj, id) => {
    let object = {}
    obj.forEach(list => {
      if (list.value === id)
        object = list
    })
    return object
  }
  const [selectedProvince, setselectedProvince] = useState(getSeletedObject(provinces, client.province_id))
  const [selectedDistrict, setselectedDistrict] = useState(getSeletedObject(districts, client.district_id))
  const [selectedCommune, setselectedCommune] = useState(getSeletedObject(communes, client.commune_id))
  const [selectedVillage, setselectedVillage] = useState(getSeletedObject(villages, client.village_id))

  const onChangeParent = object => data => {
    const { parent, child, field, obj } = object
    let selectedOption = ''
    if (parent === 'provinces') {
      selectedOption = getSeletedObject(provinces, data)
      setselectedProvince(selectedOption)
      onChange(obj, { district_id: null, commune_id: null, village_id: null, [field]: selectedOption.value || null })()
      setselectedDistrict(null)
      setselectedCommune(null)
      setselectedVillage(null)
    } else if (parent === 'districts') {
      selectedOption = getSeletedObject(districts, data)
      setselectedDistrict(selectedOption)
      onChange(obj, { commune_id: null, village_id: null, [field]: selectedOption.value || null })()
      setselectedCommune(null)
      setselectedVillage(null)
    } else if (parent === 'communes') {
      selectedOption = getSeletedObject(communes, data)
      setselectedCommune(selectedOption)
      onChange(obj, { village_id: null, [field]: selectedOption.value || null })()
      setselectedVillage(null)
    } else if (parent === 'villages') {
      selectedOption = getSeletedObject(villages, data)
      setselectedVillage(selectedOption)
      onChange(obj, { [field]: selectedOption.value || null })()
    } else {
      onChange(obj, field)(data)
    }

    if (parent !== 'villages')
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
      <TextArea label="Other" onChange={onChange('client', 'client_outside_address')} /> :
      <>
        <div className="row">
          <div className="col-xs-3">
            <SelectInput
              asGroup
              label="Province"
              options={provinces}
              value={!$.isEmptyObject(selectedProvince) && selectedProvince || null}
              onChange={onChangeParent({ parent: 'provinces', child: 'districts', obj: 'client', field: 'province_id' })}
            />
          </div>
          <div className="col-xs-3">
            <SelectInput
              label="District / Khan"
              options={districts}
              value={!$.isEmptyObject(selectedDistrict) && selectedDistrict || null}
              onChange={onChangeParent({ parent: 'districts', child: 'communes', obj: 'client', field: 'district_id' })}
            />
          </div>
          <div className="col-xs-3">
            <SelectInput
              label="Commune / Sangkat"
              options={communes}
              value={!$.isEmptyObject(selectedCommune) && selectedCommune || null}
              onChange={onChangeParent({ parent: 'communes', child: 'villages', obj: 'client', field: 'commune_id' })}
            />
          </div>
          <div className="col-xs-3">
            <SelectInput
              label="Village"
              options={villages}
              value={!$.isEmptyObject(selectedVillage) && selectedVillage || null}
              onChange={onChangeParent({ parent: 'villages', child: 'villages', obj: 'client', field: 'village_id' })}
            />
          </div>
        </div>
        <div className="row">
          <div className="col-xs-3">
            <TextInput label="Street Number" onChange={onChange('client', 'street_number')} />
          </div>
          <div className="col-xs-3">
            <TextInput label="House Number" onChange={onChange('client', 'house_number')} />
          </div>
          <div className="col-xs-3">
            <TextInput label="Address Name" onChange={onChange('client', 'current_address')} />
          </div>
          <div className="col-xs-3">
            <SelectInput label="Address Type" options={addressType} onChange={onChange('referee', 'address_type')} />
          </div>
        </div>
      </>
  )
}
