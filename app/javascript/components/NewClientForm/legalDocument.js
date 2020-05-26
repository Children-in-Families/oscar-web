import React, { useEffect, useState }       from 'react'
import {
  SelectInput,
  DateInput,
  TextInput,
  Checkbox,
  RadioGroup,
  FileUploadInput,
  TextArea
} from '../Commons/inputs'

import { t } from '../../utils/i18n'

export default props => {
  const { onChange, fieldsVisibility, translation, data: { client, T } } = props

  const onAttachmentsChange = fileItems => {
    fileItems = fileItems.map(file => (file.file));
    onChange('client', 'national_id_files')({type: 'file', data: fileItems});
  }

  return (
    <div className="containerClass">
      <legend>
        <div className="row">
          <div className="col-xs-12 col-md-6 col-lg-5">
            <p>{ t(translation, 'clients.form.legal_documents') }</p>
          </div>
        </div>
      </legend>

      {
        fieldsVisibility.national_id == true &&
        <legend>
          <div className="row">
            <div className="col-xs-12 col-md-6 col-lg-3">
              <Checkbox label={ t(translation, 'clients.form.national_id') } checked={client.national_id} onChange={onChange('client', 'national_id')} />
            </div>
            <div className="col-xs-12">
              <FileUploadInput
                label=""
                onChange={onAttachmentsChange}
                object={client.national_id_files}
                checkBoxValue={!client.national_id}
                T={T}
              />
            </div>
          </div>
        </legend>
      }
    </div>
  )
}
