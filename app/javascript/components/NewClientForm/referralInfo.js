import React, { useState }       from 'react'
import {
  SelectInput,
  DateInput,
  TextInput,
  Checkbox
}                   from '../Commons/inputs'

export default props => {
  const { onChange, data: { client, birthProvinces, currentProvinces, errorFields } } = props

  const [districts, setdistricts] = useState([])
  const [communes, setcommunes] = useState([])
  const [villages, setvillages] = useState([])
  const [provinces, setprovinces] = useState(currentProvinces.map(province => ({label: province.name, value: province.id})))

  const blank = []
  const rateLists = [{label: '1', value: 1}, {label: '2', value: 2}, {label: '3', value: 3}, {label: '4', value: 4}]
  const genderLists = [{label: 'Female', value: 'female'}, {label: 'Male', value: 'male'}, {label: 'Other', value: 'other'}, {label: 'Unknown', value: 'unknown'}]
  const addressType = [{label: 'Floor', value: 'floor'}, {label: 'Building', value: 'building'}, {label: 'Office', value: 'office'}]
  const birthProvincesLists = birthProvinces.map(province => ({label: province[0], options: province[1].map(value => ({label: value[0], value: value[1]}))}))

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
      onChange(obj, {district_id: null, commune_id: null, village_id: null, [field]: selectedOption.value || null})()
      setselectedDistrict(null)
      setselectedCommune(null)
      setselectedVillage(null)
    } else if (parent === 'districts') {
      selectedOption = getSeletedObject(districts, data)
      setselectedDistrict(selectedOption)
      onChange(obj, {commune_id: null, village_id: null, [field]: selectedOption.value || null})()
      setselectedCommune(null)
      setselectedVillage(null)
    } else if (parent === 'communes') {
      selectedOption = getSeletedObject(communes, data)
      setselectedCommune(selectedOption)
      onChange(obj, {village_id: null, [field]: selectedOption.value || null})()
      setselectedVillage(null)
    } else if (parent === 'villages') {
      selectedOption = getSeletedObject(villages, data)
      setselectedVillage(selectedOption)
      onChange(obj, {[field]: selectedOption.value || null})()
    }else{
      onChange(obj, field)(data)
    }

    if(parent !== 'villages')
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
    <div className="container">
      <legend>
        <div className="row">
          <div className="col-xs-4">
            <p>Client / Referral Information</p>
          </div>
        </div>
      </legend>

      <div className="row">
        <div className="col-xs-3">
          <TextInput required isError={errorFields.includes('given_name')} label="Given Name (Latin)" onChange={onChange('client', 'given_name')} />
        </div>
        <div className="col-xs-3">
          <TextInput required isError={errorFields.includes('family_name')} label="Family Name (Latin)" onChange={onChange('client', 'family_name')} />
        </div>
        <div className="col-xs-3">
          <TextInput label="Given Name(Khmer)" onChange={onChange('client', 'local_given_name')} />
        </div>
        <div className="col-xs-3">
          <TextInput label="Family Name (Khmer)" onChange={onChange('client', 'local_family_name')}  />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-3">
          <SelectInput
            required
            isError={errorFields.includes('gender')}
            label="Gender"
            options={genderLists}
            onChange={onChange('client', 'gender')}
          />
        </div>
        <div className="col-xs-3">
          <DateInput label="Date of Birth" onChange={onChange('client', 'date_of_birth')} />
        </div>
        <div className="col-xs-3">
          <SelectInput
            asGroup
            label="Birth Province"
            options={birthProvincesLists}
            onChange={onChange('client', 'birth_province_id')}
          />
        </div>
        <div className="col-xs-3">
          <SelectInput label="Is client rated for ID Poor?" options={rateLists} onChange={onChange('client', 'rated_for_id_poor')} />
        </div>
      </div>
      <legend>
        <div className="row">
          <div className="col-xs-3">
            <p>Contact Information</p>
          </div>
          <div className="col-xs-6">
            <Checkbox label="Client is outside Cambodia" onChange={onChange('referee', 'client_outside_cambodia')}/>
          </div>
        </div>
      </legend>
      <div className="row">
        <div className="col-xs-3">
          <SelectInput
            asGroup
            required
            isError={errorFields.includes('province_id')}
            label="Province"
            options={provinces}
            value={!$.isEmptyObject(selectedProvince) && selectedProvince || null }
            onChange={onChangeParent({parent: 'provinces', child: 'districts', obj: 'client', field: 'province_id'}, )}
          />
        </div>
        <div className="col-xs-3">
          <SelectInput
            label="District / Khan"
            options={districts}
            value={!$.isEmptyObject(selectedDistrict) && selectedDistrict || null}
            onChange={onChangeParent({parent: 'districts', child: 'communes', obj: 'client', field: 'district_id'}, )}
          />
        </div>
        <div className="col-xs-3">
          <SelectInput
            label="Commune / Sangkat"
            options={communes}
            value={!$.isEmptyObject(selectedCommune) && selectedCommune || null}
            onChange={onChangeParent({parent: 'communes', child: 'villages', obj: 'client', field: 'commune_id'}, )}
          />
        </div>
        <div className="col-xs-3">
          <SelectInput
            label="Village"
            options={villages}
            value={!$.isEmptyObject(selectedVillage) && selectedVillage || null}
            onChange={onChangeParent({parent: 'villages', child: 'villages', obj: 'client', field: 'village_id'}, )}
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
          <SelectInput label="Address Type" options={addressType} onChange={onChange('referee', 'address_type')}/>
        </div>
      </div>
      <div className="row">
        <div className="col-xs-3">
          <TextInput label="What3Words" onChange={onChange('client', 'what3words')} />
        </div>
        <div className="col-xs-3">
          <TextInput label="Client Contact Phone" onChange={onChange('client', 'telephone_number')} />
        </div>
        <div className="col-xs-3">
          <SelectInput label="Phone Owner" options={blank} />
        </div>
        <div className="col-xs-3">
          <TextInput label="Client Email Address" />
        </div>
      </div>
    </div>
  )
}
