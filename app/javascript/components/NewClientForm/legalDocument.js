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

  const onAttachmentsChange = (field) => fileItems => {
    fileItems = fileItems.map(file => (file.file));
    onChange('client', field)({type: 'file', data: fileItems});
  }

  const onRemoveAttachments = (field) => (data) => {
    let clientData = {};
    clientData[field] = data.data;

    onChange('client', clientData)({type: 'checkbox'})
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
                onChange={onAttachmentsChange('national_id_files')}
                object={client.national_id_files}
                onChangeCheckbox={onRemoveAttachments('remove_national_id_files')}
                checkBoxValue={client.remove_national_id_files || !client.national_id}
                T={T}
              />
            </div>
          </div>
        </legend>
      }

      {
        fieldsVisibility.birth_cert == true &&
        <legend>
          <div className="row">
            <div className="col-xs-12 col-md-6 col-lg-3">
              <Checkbox label={ t(translation, 'clients.form.birth_cert') } checked={client.birth_cert} onChange={onChange('client', 'birth_cert')} />
            </div>
            <div className="col-xs-12">
              <FileUploadInput
                label=""
                onChange={onAttachmentsChange('birth_cert_files')}
                object={client.birth_cert_files}
                checkBoxValue={!client.birth_cert}
                T={T}
              />
            </div>
          </div>
        </legend>
      }

      {
        fieldsVisibility.family_book == true &&
        <legend>
          <div className="row">
            <div className="col-xs-12 col-md-6 col-lg-3">
              <Checkbox label={ t(translation, 'clients.form.family_book') } checked={client.family_book} onChange={onChange('client', 'family_book')} />
            </div>
            <div className="col-xs-12">
              <FileUploadInput
                label=""
                onChange={onAttachmentsChange('family_book_files')}
                object={client.family_book_files}
                checkBoxValue={!client.family_book}
                T={T}
              />
            </div>
          </div>
        </legend>
      }

      {
        fieldsVisibility.passport == true &&
        <legend>
          <div className="row">
            <div className="col-xs-12 col-md-6 col-lg-3">
              <Checkbox label={ t(translation, 'clients.form.passport') } checked={client.passport} onChange={onChange('client', 'passport')} />
            </div>
            <div className="col-xs-12">
              <FileUploadInput
                label=""
                onChange={onAttachmentsChange('passport_files')}
                object={client.passport_files}
                checkBoxValue={!client.passport}
                T={T}
              />
            </div>
          </div>
        </legend>
      }

      {
        fieldsVisibility.travel_doc == true &&
        <legend>
          <div className="row">
            <div className="col-xs-12 col-md-6 col-lg-3">
              <Checkbox label={ t(translation, 'clients.form.travel_doc') } checked={client.travel_doc} onChange={onChange('client', 'travel_doc')} />
            </div>
            <div className="col-xs-12">
              <FileUploadInput
                label=""
                onChange={onAttachmentsChange('travel_doc_files')}
                object={client.travel_doc_files}
                checkBoxValue={!client.travel_doc}
                T={T}
              />
            </div>
          </div>
        </legend>
      }

      {
        fieldsVisibility.referral_doc == true &&
        <legend>
          <div className="row">
            <div className="col-xs-12 col-md-6 col-lg-3">
              <Checkbox label={ t(translation, 'clients.form.referral_doc') } checked={client.referral_doc} onChange={onChange('client', 'referral_doc')} />
            </div>
            <div className="col-xs-12">
              <FileUploadInput
                label=""
                onChange={onAttachmentsChange('referral_doc_files')}
                object={client.referral_doc_files}
                checkBoxValue={!client.referral_doc}
                T={T}
              />
            </div>
          </div>
        </legend>
      }

      {
        fieldsVisibility.local_consent == true &&
        <legend>
          <div className="row">
            <div className="col-xs-12 col-md-6 col-lg-3">
              <Checkbox label={ t(translation, 'clients.form.local_consent') } checked={client.local_consent} onChange={onChange('client', 'local_consent')} />
            </div>
            <div className="col-xs-12">
              <FileUploadInput
                label=""
                onChange={onAttachmentsChange('local_consent_files')}
                object={client.local_consent_files}
                checkBoxValue={!client.local_consent}
                T={T}
              />
            </div>
          </div>
        </legend>
      }

      {
        fieldsVisibility.police_interview == true &&
        <legend>
          <div className="row">
            <div className="col-xs-12 col-md-6 col-lg-3">
              <Checkbox label={ t(translation, 'clients.form.police_interview') } checked={client.police_interview} onChange={onChange('client', 'police_interview')} />
            </div>
            <div className="col-xs-12">
              <FileUploadInput
                label=""
                onChange={onAttachmentsChange('police_interview_files')}
                object={client.police_interview_files}
                checkBoxValue={!client.police_interview}
                T={T}
              />
            </div>
          </div>
        </legend>
      }

      {
        fieldsVisibility.other_legal_doc == true &&
        <legend>
          <div className="row">
            <div className="col-xs-12 col-md-6 col-lg-3">
              <Checkbox label={ t(translation, 'clients.form.other_legal_doc') } checked={client.other_legal_doc} onChange={onChange('client', 'other_legal_doc')} />
            </div>
            <div className="col-xs-12">
              <FileUploadInput
                label=""
                onChange={onAttachmentsChange('other_legal_doc_files')}
                object={client.other_legal_doc_files}
                checkBoxValue={!client.other_legal_doc}
                T={T}
              />
            </div>
          </div>
        </legend>
      }
    </div>
  )
}
