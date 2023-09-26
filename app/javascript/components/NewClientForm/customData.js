import React from 'react'
import { t } from '../../utils/i18n'
import {
  SelectInput,
  TextArea,
  TextInput,
  Checkbox,
  RadioGroup,
  DateInput,
  FileUploadInput
} from '../Commons/inputs'

export default props => {
  const { onChange, customData, clientCustomData, setClientCustomData } = props
  console.log(customData)

  const onAttachmentsChange = (field) => (fileItems) => {
    fileItems = fileItems.map((file) => file.file);
    setClientCustomData(prev => ({...prev, form_builder_attachments_attributes: { name: field, file: fileItems } }))
  };

  const renderCustomDataFields = () => {
    return (
      customData.map((element) => {
        return (
          <div className="row" key={element.name}>
            <div className="col-xs-12 col-md-12 col-lg-12">
              {
                (element.type === 'text' || element.type === 'number') &&
                <TextInput
                  { ...element }
                  onChange={ onChange('custom_data', element.label) }
                  value={ clientCustomData[element.label] }
                />
              }

              {
                element.type === 'select' &&
                <SelectInput
                  onChange={ onChange('custom_data', element.label) }
                  options={element.values}
                  label={element.label}
                  value={clientCustomData[element.label]}
                />
              }

              {
                element.type === 'date' &&
                <DateInput
                  { ...element }
                  onChange={ onChange('custom_data', element.label) }
                  value={clientCustomData[element.label]}
                />
              }

              {
                element.type === 'checkbox-group' &&
                <Checkbox
                  label={element.label}
                  checked={clientCustomData[element.label] || false}
                  objectKey="custom_data"
                  onChange={ onChange('custom_data', element.label) }
                />
              }

              {
                element.type === 'radio-group' &&
                <RadioGroup
                  { ...element }
                  onChange={ onChange('custom_data', element.label) }
                  options={element.values}
                  value={clientCustomData[element.label]}
                />
              }

              {
                element.type === 'textarea' &&
                <TextArea
                  { ...element }
                  onChange={ onChange('custom_data', element.label) }
                  value={clientCustomData[element.label]}
                />
              }

              {
                element.type === 'paragraph' &&
                <p>{element.label}</p>
              }

              {
                element.type === 'file' &&
                <div className="form-group">
                  <label htmlFor={element.label}>{ element.label }</label>
                  <FileUploadInput
                    onChange={ onAttachmentsChange(element.label) }
                    object={clientCustomData[element.label] || []}

                    // removeAttachmentcheckBoxValue={
                    //   client.remove_national_id_files
                    // }
                    showFilePond={true}
                  />
                </div>
              }

              {
                element.type === 'separateLine' &&
                <hr />
              }
            </div>
          </div>
        )
      })
    )
  }

  return(
    <div>
      {renderCustomDataFields()}
    </div>
  )
}
