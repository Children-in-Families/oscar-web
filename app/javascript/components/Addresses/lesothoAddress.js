import React, { useState, useEffect } from 'react'
import {
  TextInput,
  SelectInput,
  TextArea
} from '../Commons/inputs'

export default props => {
  const { onChange, disabled, outside, data: { client, objectKey, objectData, addressTypes, T } } = props

  const typeOfAddress = addressTypes.map(type => ({ label: T.translate("addressType."+type.label), value: type.value }))

  return (
    outside == true ?
      <TextArea label={T.translate("address.outside_address")} disabled={disabled} value={objectData.outside_address} onChange={onChange(objectKey, 'outside_address')} />
    :
      <>
        <div className="row">
          <div className="col-xs-12 col-md-6 col-lg-4">
            <TextInput
              label={T.translate("address.lesotho.suburb")}
              disabled={disabled}
              onChange={onChange(objectKey, 'suburb')}
              value={objectData.suburb}
            />
          </div>

          <div className="col-xs-12 col-md-6 col-lg-4">
            <TextInput
              label={T.translate("address.lesotho.description_house_landmark")}
              disabled={disabled}
              onChange={onChange(objectKey, 'description_house_landmark')}
              value={objectData.description_house_landmark}
            />
          </div>

          <div className="col-xs-12 col-md-6 col-lg-4">
            <TextInput
              label={T.translate("address.lesotho.directions")}
              disabled={disabled}
              onChange={onChange(objectKey, 'directions')}
              value={objectData.directions}
            />
          </div>
        </div>

        <div className="row">
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
