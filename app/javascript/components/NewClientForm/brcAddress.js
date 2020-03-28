import React, { useState, useEffect } from 'react'
import {
  TextInput,
  SelectInput,
  TextArea
} from '../Commons/inputs'
import { t } from '../../utils/i18n'

export default props => {
  const { onChange, disabled, translation, fieldsVisibility,
          data: { client, objectKey, objectData, T, current_organization, brc_address, brc_islands, brc_household_types, brc_resident_types }
        } = props

  const [brcIslands, setBrcIslands] = useState(brc_islands && brc_islands.map(island  => ({label: island, value: island})))
  const [brcHouseholdTypes, setBrcHouseholdTypes] = useState(brc_household_types && brc_household_types.map(household  => ({label: household, value: household})))
  const [brcResidentTypes, setBrcResidentTypes] = useState(brc_resident_types && brc_resident_types.map(type  => ({label: type, value: type})))

  return (
    <div>
      {
        fieldsVisibility && fieldsVisibility.brc_client_address != false &&
        <legend className="brc-address">
          <div className="row">
            <div className="col-xs-12 col-md-6 col-lg-6">
              <p>Current Address</p>
            </div>
          </div>
        </legend>
      }

      <div className="row">
        {
          fieldsVisibility && fieldsVisibility.current_island != false &&
          <div className="col-xs-12 col-md-6 col-lg-4" style={{ maxHeight: '59px' }}>
            <SelectInput
              label={translation.clients.form['current_island']}
              options={brcIslands}
              isDisabled={disabled}
              onChange={onChange(objectKey, 'current_island')}
              value={objectData.current_island}
            />
          </div>
        }

        {
          fieldsVisibility && fieldsVisibility.current_street != false &&
          <div className="col-xs-12 col-md-6 col-lg-4">
            <TextInput
              label={translation.clients.form['current_street']}
              disabled={disabled}
              onChange={onChange(objectKey, 'current_street')}
              value={objectData.current_street}
            />
          </div>
        }

        {
          fieldsVisibility && fieldsVisibility.current_po_box != false &&
          <div className="col-xs-12 col-md-6 col-lg-4">
            <TextInput
              label={translation.clients.form['current_po_box']}
              disabled={disabled}
              onChange={onChange(objectKey, 'current_po_box')}
              value={objectData.current_po_box}
            />
          </div>
        }
      </div>
      <div className="row">
        {
          fieldsVisibility && fieldsVisibility.current_city != false &&
          <div className="col-xs-12 col-md-6 col-lg-4">
            <TextInput
              label={translation.clients.form['current_city']}
              disabled={disabled}
              onChange={onChange(objectKey, 'current_city')}
              value={objectData.current_city}
            />
          </div>
        }

        {
          fieldsVisibility && fieldsVisibility.current_settlement != false &&
          <div className="col-xs-12 col-md-6 col-lg-4">
            <TextInput
              label={translation.clients.form['current_settlement']}
              disabled={disabled}
              onChange={onChange(objectKey, 'current_settlement')}
              value={objectData.current_settlement}
            />
          </div>
        }

        {
          fieldsVisibility && fieldsVisibility.current_resident_own_or_rent != false &&
          <div className="col-xs-12 col-md-6 col-lg-4" style={{ maxHeight: '59px' }}>
            <SelectInput
              label={translation.clients.form['current_resident_own_or_rent']}
              disabled={disabled}
              options={brcResidentTypes}
              onChange={onChange(objectKey, 'current_resident_own_or_rent')}
              value={objectData.current_resident_own_or_rent}
            />
          </div>
        }
      </div>
      <div className="row">
        {
          fieldsVisibility && fieldsVisibility.current_household_type != false &&
          <div className="col-xs-12 col-md-6" style={{ maxHeight: '59px' }}>
            <SelectInput
              label={translation.clients.form['current_household_type']}
              disabled={disabled}
              options={brcHouseholdTypes}
              onChange={onChange(objectKey, 'current_household_type')}
              value={objectData.current_household_type}
            />
          </div>
        }
      </div>

      {
        fieldsVisibility && fieldsVisibility.brc_client_other_address != false &&
        <legend className="brc-address">
          <div className="row">
            <div className="col-xs-12 col-md-6 col-lg-6">
              <p>Other Address</p>
            </div>
          </div>
        </legend>
      }

      <div className="row">

        {
          fieldsVisibility && fieldsVisibility.island2 != false &&
          <div className="col-xs-12 col-md-12 col-lg-4">
            <SelectInput
              label={translation.clients.form['island2']}
              options={brcIslands}
              isDisabled={disabled}
              onChange={onChange(objectKey, 'island2')}
              value={objectData.island2}
            />
          </div>
        }

        {
          fieldsVisibility && fieldsVisibility.street2 != false &&
          <div className="col-xs-12 col-md-6 col-lg-4">
            <TextInput
              label={translation.clients.form['street2']}
              disabled={disabled}
              onChange={onChange(objectKey, 'street2')}
              value={objectData.street2}
            />
          </div>
        }

        {
          fieldsVisibility && fieldsVisibility.po_box2 != false &&
          <div className="col-xs-12 col-md-6 col-lg-4">
            <TextInput
              label={translation.clients.form['po_box2']}
              disabled={disabled}
              onChange={onChange(objectKey, 'po_box2')}
              value={objectData.po_box2}
            />
          </div>
        }

      </div>
      <div className="row">
        {
          fieldsVisibility && fieldsVisibility.city2 != false &&
          <div className="col-xs-12 col-md-6 col-lg-4">
            <TextInput
              label={translation.clients.form['city2']}
              disabled={disabled}
              onChange={onChange(objectKey, 'city2')}
              value={objectData.city2}
            />
          </div>
        }

        {
          fieldsVisibility && fieldsVisibility.settlement2 != false &&
          <div className="col-xs-12 col-md-6 col-lg-4">
            <TextInput
              label={translation.clients.form['settlement2']}
              disabled={disabled}
              onChange={onChange(objectKey, 'settlement2')}
              value={objectData.settlement2}
            />
          </div>
        }

        {
          fieldsVisibility && fieldsVisibility.resident_own_or_rent2 != false &&
          <div className="col-xs-12 col-md-6 col-lg-4">
            <SelectInput
              label={translation.clients.form['resident_own_or_rent2']}
              disabled={disabled}
              options={brcResidentTypes}
              onChange={onChange(objectKey, 'resident_own_or_rent2')}
              value={objectData.resident_own_or_rent2}
            />
          </div>
        }
      </div>
      <div className="row">
        {
          fieldsVisibility && fieldsVisibility.household_type2 != false &&
          <div className="col-xs-12 col-md-6 col-lg-6">
            <SelectInput
              label={translation.clients.form['household_type2']}
              disabled={disabled}
              options={brcHouseholdTypes}
              onChange={onChange(objectKey, 'household_type2')}
              value={objectData.household_type2}
            />
          </div>
        }
      </div>

      <div className="row">
        {
          fieldsVisibility && fieldsVisibility.province_id != false &&
          <div className="col-xs-12 col-md-6 col-lg-3">
            <SelectInput
              label={T.translate("address.provicne")}
              options={provinces}
              isDisabled={disabled}
              value={objectData.province_id}
              onChange={onChangeParent({parent: 'provinces', child: 'districts', obj: objectKey, field: 'province_id'})}
            />
          </div>
        }

        {
          fieldsVisibility && fieldsVisibility.district_id != false &&
          <div className="col-xs-12 col-md-6 col-lg-3">
            <SelectInput
              label={T.translate("address.district")}
              isDisabled={disabled}
              options={districts}
              value={objectData.district_id}
              onChange={onChangeParent({parent: 'districts', child: 'communes', obj: objectKey, field: 'district_id'})}
            />
          </div>
        }

        {
          fieldsVisibility && fieldsVisibility.commune_id != false &&
          <div className="col-xs-12 col-md-6 col-lg-3">
            <SelectInput
              label={T.translate("address.commune")}
              isDisabled={disabled}
              options={communes}
              value={objectData.commune_id}
              onChange={onChangeParent({parent: 'communes', child: 'villages', obj: objectKey, field: 'commune_id'})}
            />
          </div>
        }

        {
          fieldsVisibility && fieldsVisibility.village_id != false &&
          <div className="col-xs-12 col-md-6 col-lg-3">
            <SelectInput
              label={T.translate("address.village")}
              isDisabled={disabled}
              options={villages}
              value={objectData.village_id}
              onChange={onChangeParent({parent: 'villages', child: 'villages', obj: objectKey, field: 'village_id'})}
            />
          </div>
        }
      </div>

      <div className="row">
        {
          fieldsVisibility && fieldsVisibility.street_number != false &&
          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label={T.translate("address.street_number")}
              disabled={disabled}
              onChange={onChange(objectKey, 'street_number')}
              value={objectData.street_number}
            />
          </div>
        }

        {
          fieldsVisibility && fieldsVisibility.house_number != false &&
          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label={T.translate("address.house_number")}
              disabled={disabled}
              onChange={onChange(objectKey, 'house_number')}
              value={objectData.house_number}
            />
          </div>
        }

        {
          fieldsVisibility && fieldsVisibility.current_address != false &&
          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label={T.translate("address.address_name")}
              disabled={disabled}
              onChange={onChange(objectKey, 'current_address')}
              value={objectData.current_address}
            />
          </div>
        }

        {
          fieldsVisibility && fieldsVisibility.address_type != false &&
          <div className="col-xs-12 col-md-6 col-lg-3">
            <SelectInput
              label={T.translate("address.address_type")}
              isDisabled={disabled}
              options={typeOfAddress}
              onChange={onChange(objectKey, 'address_type')}
              value={objectData.address_type}
            />
          </div>
        }
      </div>
    </div>
  )
}
