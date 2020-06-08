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

  const [clientData, setClientData]   = useState({...client})

  const onCheckBoxChange = (obj, field) => event => {
    const inputType = ['date', 'select', 'checkbox', 'radio', 'file']
    const value = inputType.includes(event.type) ? event.data : event.target.value

    if (typeof field !== 'object'){
      client[field] = value
      setClientData({...client})
    }

  }

  const onAttachmentsChange = (field) => fileItems => {
    fileItems = fileItems.map(file => (file.file));
    onCheckBoxChange('client', field)({type: 'file', data: fileItems});
  }

  const onRemoveAttachments = (field) => (data) => {
    onChange('client', {[field]: data.data})({type: 'checkbox'})
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
              <Checkbox label={ t(translation, 'clients.form.national_id') } checked={client.national_id} onChange={onCheckBoxChange('client', 'national_id')} />
            </div>
            <div className="col-xs-12">
              <FileUploadInput
                label=""
                onChange={onAttachmentsChange('national_id_files')}
                object={client.national_id_files}
                onChangeCheckbox={onRemoveAttachments('remove_national_id_files')}
                removeAttachmentcheckBoxValue={client.remove_national_id_files}
                showFilePond={client.national_id}
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
              <Checkbox label={ t(translation, 'clients.form.birth_cert') } checked={client.birth_cert} onChange={onCheckBoxChange('client', 'birth_cert')} />
            </div>
            <div className="col-xs-12">
              <FileUploadInput
                label=""
                onChange={onAttachmentsChange('birth_cert_files')}
                object={client.birth_cert_files}
                onChangeCheckbox={onRemoveAttachments('remove_birth_cert_files')}
                removeAttachmentcheckBoxValue={client.remove_birth_cert_files}
                showFilePond={client.birth_cert}
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
              <Checkbox label={ t(translation, 'clients.form.family_book') } checked={client.family_book} onChange={onCheckBoxChange('client', 'family_book')} />
            </div>
            <div className="col-xs-12">
              <FileUploadInput
                label=""
                onChange={onAttachmentsChange('family_book_files')}
                object={client.family_book_files}
                onChangeCheckbox={onRemoveAttachments('remove_family_book_files')}
                removeAttachmentcheckBoxValue={client.remove_family_book_files}
                showFilePond={client.family_book}
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
              <Checkbox label={ t(translation, 'clients.form.passport') } checked={client.passport} onChange={onCheckBoxChange('client', 'passport')} />
            </div>
            <div className="col-xs-12">
              <FileUploadInput
                label=""
                onChange={onAttachmentsChange('passport_files')}
                object={client.passport_files}
                onChangeCheckbox={onRemoveAttachments('remove_passport_files')}
                removeAttachmentcheckBoxValue={client.remove_passport_files}
                showFilePond={client.passport}
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
              <Checkbox label={ t(translation, 'clients.form.travel_doc') } checked={client.travel_doc} onChange={onCheckBoxChange('client', 'travel_doc')} />
            </div>
            <div className="col-xs-12">
              <FileUploadInput
                label=""
                onChange={onAttachmentsChange('travel_doc_files')}
                object={client.travel_doc_files}
                onChangeCheckbox={onRemoveAttachments('remove_travel_doc_files')}
                removeAttachmentcheckBoxValue={client.remove_travel_doc_files}
                showFilePond={client.travel_doc}
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
              <Checkbox label={ t(translation, 'clients.form.referral_doc') } checked={client.referral_doc} onChange={onCheckBoxChange('client', 'referral_doc')} />
            </div>
            <div className="col-xs-12">
              <FileUploadInput
                label=""
                onChange={onAttachmentsChange('referral_doc_files')}
                object={client.referral_doc_files}
                onChangeCheckbox={onRemoveAttachments('remove_referral_doc_files')}
                removeAttachmentcheckBoxValue={client.remove_referral_doc_files}
                showFilePond={client.referral_doc}
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
              <Checkbox label={ t(translation, 'clients.form.local_consent') } checked={client.local_consent} onChange={onCheckBoxChange('client', 'local_consent')} />
            </div>
            <div className="col-xs-12">
              <FileUploadInput
                label=""
                onChange={onAttachmentsChange('local_consent_files')}
                object={client.local_consent_files}
                onChangeCheckbox={onRemoveAttachments('remove_local_consent_files')}
                removeAttachmentcheckBoxValue={client.remove_local_consent_files}
                showFilePond={client.local_consent}
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
              <Checkbox label={ t(translation, 'clients.form.police_interview') } checked={client.police_interview} onChange={onCheckBoxChange('client', 'police_interview')} />
            </div>
            <div className="col-xs-12">
              <FileUploadInput
                label=""
                onChange={onAttachmentsChange('police_interview_files')}
                object={client.police_interview_files}
                onChangeCheckbox={onRemoveAttachments('remove_police_interview_files')}
                removeAttachmentcheckBoxValue={client.remove_police_interview_files}
                showFilePond={client.police_interview}
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
              <Checkbox label={ t(translation, 'clients.form.other_legal_doc') } checked={client.other_legal_doc} onChange={onCheckBoxChange('client', 'other_legal_doc')} />
            </div>
            <div className="col-xs-12">
              <FileUploadInput
                label=""
                onChange={onAttachmentsChange('other_legal_doc_files')}
                object={client.other_legal_doc_files}
                onChangeCheckbox={onRemoveAttachments('remove_other_legal_doc_files')}
                removeAttachmentcheckBoxValue={client.remove_other_legal_doc_files}
                showFilePond={client.other_legal_doc}
                T={T}
              />
            </div>
          </div>
        </legend>
      }
    </div>
  )
}
