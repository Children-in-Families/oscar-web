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

  const legalDocOptions = [
    { value: "Labour Trafficking", label: t(translation, 'clients.form.labor_trafficking_legal_doc_option') },
    { value: "Sexual Trafficking", label: t(translation, 'clients.form.sex_trafficking_legal_doc_option') },
    { value: "Other", label: t(translation, 'clients.form.other_legal_doc_option') }
  ];

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

  const onChangeLegalDocOption = (field) => (data) => {
    const value = data.data;
     onChange('client', {[field]: value})({type: 'radio'})
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
      <fieldset className="legal-form-border">
        <legend className="legal-form-border">
          <h3 className="text-success">{ t(translation, 'clients.form.indentification_doc') }</h3>
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
      </fieldset>

      <fieldset className="legal-form-border">
        <legend className="legal-form-border">
          <h3 className="text-success">{ t(translation, 'clients.form.temp_travel_doc') }</h3>
        </legend>
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
      </fieldset>

      <fieldset className="legal-form-border">
        <legend className="legal-form-border">
          <h3 className="text-success">{ t(translation, 'clients.form.referral_document') }</h3>
        </legend>
        {
          fieldsVisibility.ngo_partner == true &&
          <legend>
            <div className="row">
              <div className="col-xs-12 col-md-6 col-lg-3">
                <Checkbox label={ t(translation, 'clients.form.ngo_partner') } checked={client.ngo_partner} onChange={onCheckBoxChange('client', 'ngo_partner')} />
              </div>
              <div className="col-xs-12">
                <FileUploadInput
                  label=""
                  onChange={onAttachmentsChange('ngo_partner_files')}
                  object={client.ngo_partner_files}
                  onChangeCheckbox={onRemoveAttachments('remove_ngo_partner_files')}
                  removeAttachmentcheckBoxValue={client.remove_ngo_partner_files}
                  showFilePond={client.ngo_partner}
                  T={T}
                />
              </div>
            </div>
          </legend>
        }

        {
          fieldsVisibility.mosavy == true &&
          <legend>
            <div className="row">
              <div className="col-xs-12 col-md-6 col-lg-3">
                <Checkbox label={ t(translation, 'clients.form.mosavy') } checked={client.mosavy} onChange={onCheckBoxChange('client', 'mosavy')} />
              </div>
              <div className="col-xs-12">
                <FileUploadInput
                  label=""
                  onChange={onAttachmentsChange('mosavy_files')}
                  object={client.mosavy_files}
                  onChangeCheckbox={onRemoveAttachments('remove_mosavy_files')}
                  removeAttachmentcheckBoxValue={client.remove_mosavy_files}
                  showFilePond={client.mosavy}
                  T={T}
                />
              </div>
            </div>
          </legend>
        }

        {
          fieldsVisibility.dosavy == true &&
          <legend>
            <div className="row">
              <div className="col-xs-12 col-md-6 col-lg-3">
                <Checkbox label={ t(translation, 'clients.form.dosavy') } checked={client.dosavy} onChange={onCheckBoxChange('client', 'dosavy')} />
              </div>
              <div className="col-xs-12">
                <FileUploadInput
                  label=""
                  onChange={onAttachmentsChange('dosavy_files')}
                  object={client.dosavy_files}
                  onChangeCheckbox={onRemoveAttachments('remove_dosavy_files')}
                  removeAttachmentcheckBoxValue={client.remove_dosavy_files}
                  showFilePond={client.dosavy}
                  T={T}
                />
              </div>
            </div>
          </legend>
        }

        {
          fieldsVisibility.msdhs == true &&
          <legend>
            <div className="row">
              <div className="col-xs-12 col-md-6 col-lg-3">
                <Checkbox label={ t(translation, 'clients.form.msdhs') } checked={client.msdhs} onChange={onCheckBoxChange('client', 'msdhs')} />
              </div>
              <div className="col-xs-12">
                <FileUploadInput
                  label=""
                  onChange={onAttachmentsChange('msdhs_files')}
                  object={client.msdhs_files}
                  onChangeCheckbox={onRemoveAttachments('remove_msdhs_files')}
                  removeAttachmentcheckBoxValue={client.remove_msdhs_files}
                  showFilePond={client.msdhs}
                  T={T}
                />
              </div>
            </div>
          </legend>
        }
      </fieldset>

      <fieldset className="legal-form-border">
        <legend className="legal-form-border">
          <h3 className="text-success">{ t(translation, 'clients.form.legal_processing_doc') }</h3>
        </legend>
        {
          fieldsVisibility.complain == true &&
          <legend>
            <div className="row">
              <div className="col-xs-12 col-md-6 col-lg-3">
                <Checkbox label={ t(translation, 'clients.form.complain') } checked={client.complain} onChange={onCheckBoxChange('client', 'complain')} />
              </div>
              <div className="col-xs-12">
                <FileUploadInput
                  label=""
                  onChange={onAttachmentsChange('complain_files')}
                  object={client.complain_files}
                  onChangeCheckbox={onRemoveAttachments('remove_complain_files')}
                  removeAttachmentcheckBoxValue={client.remove_complain_files}
                  showFilePond={client.complain}
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
          fieldsVisibility.warrant == true &&
          <legend>
            <div className="row">
              <div className="col-xs-12 col-md-6 col-lg-3">
                <Checkbox label={ t(translation, 'clients.form.warrant') } checked={client.warrant} onChange={onCheckBoxChange('client', 'warrant')} />
              </div>
              <div className="col-xs-12">
                <FileUploadInput
                  label=""
                  onChange={onAttachmentsChange('warrant_files')}
                  object={client.warrant_files}
                  onChangeCheckbox={onRemoveAttachments('remove_warrant_files')}
                  removeAttachmentcheckBoxValue={client.remove_warrant_files}
                  showFilePond={client.warrant}
                  T={T}
                />
              </div>
            </div>
          </legend>
        }

        {
          fieldsVisibility.verdict == true &&
          <legend>
            <div className="row">
              <div className="col-xs-12 col-md-6 col-lg-3">
                <Checkbox label={ t(translation, 'clients.form.verdict') } checked={client.verdict} onChange={onCheckBoxChange('client', 'verdict')} />
              </div>
              <div className="col-xs-12">
                <FileUploadInput
                  label=""
                  onChange={onAttachmentsChange('verdict_files')}
                  object={client.verdict_files}
                  onChangeCheckbox={onRemoveAttachments('remove_verdict_files')}
                  removeAttachmentcheckBoxValue={client.remove_verdict_files}
                  showFilePond={client.verdict}
                  T={T}
                />
              </div>
            </div>
          </legend>
        }
      </fieldset>

      <fieldset className="legal-form-border">
        <legend className="legal-form-border">
          <h3 className="text-success">{ t(translation, 'clients.form.form_indentification') }</h3>
        </legend>
        {
          fieldsVisibility.screening_interview_form == true &&
          <legend>
            <div className="row">
              <div className="col-xs-12 col-md-6 col-lg-3">
                <Checkbox label={ t(translation, 'clients.form.screening_interview_form') } checked={client.screening_interview_form} onChange={onCheckBoxChange('client', 'screening_interview_form')} />
              </div>
               <div className="col-xs-12">
                {
                  client.screening_interview_form &&
                  <RadioGroup
                    inline
                    options={legalDocOptions}
                    onChange={onChangeLegalDocOption('screening_interview_form_option')}
                    value={client.screening_interview_form_option}
                  />
                }
              </div>
              <div className="col-xs-12">
                <FileUploadInput
                  label=""
                  onChange={onAttachmentsChange('screening_interview_form_files')}
                  object={client.screening_interview_form_files}
                  onChangeCheckbox={onRemoveAttachments('remove_screening_interview_form_files')}
                  removeAttachmentcheckBoxValue={client.remove_screening_interview_form_files}
                  showFilePond={client.screening_interview_form}
                  T={T}
                />
              </div>
            </div>
          </legend>
        }

        {
          fieldsVisibility.short_form_of_ocdm == true &&
          <legend>
            <div className="row">
              <div className="col-xs-12">
                <Checkbox label={ t(translation, 'clients.form.short_form_of_ocdm') } checked={client.short_form_of_ocdm} onChange={onCheckBoxChange('client', 'short_form_of_ocdm')} />
              </div>
               <div className="col-xs-12">
                {
                  client.short_form_of_ocdm &&
                  <RadioGroup
                    inline
                    options={legalDocOptions}
                    onChange={onChangeLegalDocOption('short_form_of_ocdm_option')}
                    value={client.short_form_of_ocdm_option}
                  />
                }
              </div>
              <div className="col-xs-12">
                <FileUploadInput
                  label=""
                  onChange={onAttachmentsChange('short_form_of_ocdm_files')}
                  object={client.short_form_of_ocdm_files}
                  onChangeCheckbox={onRemoveAttachments('remove_short_form_of_ocdm_files')}
                  removeAttachmentcheckBoxValue={client.remove_short_form_of_ocdm_files}
                  showFilePond={client.short_form_of_ocdm}
                  T={T}
                />
              </div>
            </div>
          </legend>
        }

        {
          fieldsVisibility.short_form_of_mosavy_dosavy == true &&
          <legend>
            <div className="row">
              <div className="col-xs-12">
                <Checkbox label={ t(translation, 'clients.form.short_form_of_mosavy_dosavy') } checked={client.short_form_of_mosavy_dosavy} onChange={onCheckBoxChange('client', 'short_form_of_mosavy_dosavy')} />
              </div>
              <div className="col-xs-12">
                {
                  client.short_form_of_mosavy_dosavy &&
                  <RadioGroup
                    inline
                    options={legalDocOptions}
                    onChange={onChangeLegalDocOption('short_form_of_mosavy_dosavy_option')}
                    value={client.short_form_of_mosavy_dosavy_option}
                  />
                }
              </div>
              <div className="col-xs-12"></div>
              <div className="col-xs-12">
                <FileUploadInput
                  label=""
                  onChange={onAttachmentsChange('short_form_of_mosavy_dosavy_files')}
                  object={client.short_form_of_mosavy_dosavy_files}
                  onChangeCheckbox={onRemoveAttachments('remove_short_form_of_mosavy_dosavy_files')}
                  removeAttachmentcheckBoxValue={client.remove_short_form_of_mosavy_dosavy_files}
                  showFilePond={client.short_form_of_mosavy_dosavy}
                  T={T}
                />
              </div>
            </div>
          </legend>
        }

        {
          fieldsVisibility.detail_form_of_mosavy_dosavy == true &&
          <legend>
            <div className="row">
              <div className="col-xs-12">
                <Checkbox label={ t(translation, 'clients.form.detail_form_of_mosavy_dosavy') } checked={client.detail_form_of_mosavy_dosavy} onChange={onCheckBoxChange('client', 'detail_form_of_mosavy_dosavy')} />
              </div>
              <div className="col-xs-12">
                {
                  client.detail_form_of_mosavy_dosavy &&
                  <RadioGroup
                    inline
                    options={legalDocOptions}
                    onChange={onChangeLegalDocOption('detail_form_of_mosavy_dosavy_option')}
                    value={client.detail_form_of_mosavy_dosavy_option}
                  />
                }
              </div>
              <div className="col-xs-12"></div>
              <div className="col-xs-12">
                <FileUploadInput
                  label=""
                  onChange={onAttachmentsChange('detail_form_of_mosavy_dosavy_files')}
                  object={client.detail_form_of_mosavy_dosavy_files}
                  onChangeCheckbox={onRemoveAttachments('remove_detail_form_of_mosavy_dosavy_files')}
                  removeAttachmentcheckBoxValue={client.remove_detail_form_of_mosavy_dosavy_files}
                  showFilePond={client.detail_form_of_mosavy_dosavy}
                  T={T}
                />
              </div>
            </div>
          </legend>
        }

        {
          fieldsVisibility.short_form_of_judicial_police == true &&
          <legend>
            <div className="row">
              <div className="col-xs-12">
                <Checkbox label={ t(translation, 'clients.form.short_form_of_judicial_police') } checked={client.short_form_of_judicial_police} onChange={onCheckBoxChange('client', 'short_form_of_judicial_police')} />
              </div>
              <div className="col-xs-12">
                {
                  client.short_form_of_judicial_police &&
                  <RadioGroup
                    inline
                    options={legalDocOptions}
                    onChange={onChangeLegalDocOption('short_form_of_judicial_police_option')}
                    value={client.short_form_of_judicial_police_option}
                  />
                }
              </div>
              <div className="col-xs-12"></div>
              <div className="col-xs-12">
                <FileUploadInput
                  label=""
                  onChange={onAttachmentsChange('short_form_of_judicial_police_files')}
                  object={client.short_form_of_judicial_police_files}
                  onChangeCheckbox={onRemoveAttachments('remove_short_form_of_judicial_police_files')}
                  removeAttachmentcheckBoxValue={client.remove_short_form_of_judicial_police_files}
                  showFilePond={client.short_form_of_judicial_police}
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
              <div className="col-xs-12">
                <Checkbox label={ t(translation, 'clients.form.detail_form_of_judicial_police') } checked={client.police_interview} onChange={onCheckBoxChange('client', 'police_interview')} />
              </div>
              <div className="col-xs-12">
                {
                  client.detail_form_of_judicial_police &&
                  <RadioGroup
                    inline
                    options={legalDocOptions}
                    onChange={onChangeLegalDocOption('detail_form_of_judicial_police_option')}
                    value={client.detail_form_of_judicial_police_option}
                  />
                }
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
      </fieldset>
    </div>
  )
}
