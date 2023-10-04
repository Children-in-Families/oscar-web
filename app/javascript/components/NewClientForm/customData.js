import React from 'react'
import {
  SelectInput,
  TextArea,
  TextInput,
  Checkbox,
  RadioGroup,
  DateInput,
  FileUploadInput
} from '../Commons/inputs'
import CheckboxGroup from '../Commons/inputs/checkboxGroup'

export default props => {
  const { onChange, customData, clientCustomData, setClientCustomData } = props

  const onAttachmentsChange = (field) => (fileItems) => {
    fileItems = fileItems.map((file) => file.file);
    setClientCustomData(prev => {
      const files = prev.attachments || {}
      files[field.split('-')[1]] = { name: field, file: fileItems }
      return {...prev, _attachments: files}
    })
  }

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
                  onChange={ onChange('custom_data', element.name) }
                  value={ clientCustomData[element.name] }
                />
              }

              {
                element.type === 'select' &&
                <SelectInput
                  onChange={ onChange('custom_data', element.name) }
                  options={element.values}
                  label={element.label}
                  value={clientCustomData[element.name]}
                />
              }

              {
                element.type === 'date' &&
                <DateInput
                  { ...element }
                  onChange={ onChange('custom_data', element.name) }
                  value={clientCustomData[element.name]}
                />
              }

              {
                element.type === 'checkbox-group' &&
                <CheckboxGroup data={element.values} onChange={onChange} label={element.label} name={element.name} />
              }

              {
                element.type === 'radio-group' &&
                <RadioGroup
                  { ...element }
                  onChange={ onChange('custom_data', element.name) }
                  options={element.values}
                  value={clientCustomData[element.name]}
                />
              }

              {
                element.type === 'textarea' &&
                <TextArea
                  { ...element }
                  onChange={ onChange('custom_data', element.name) }
                  value={clientCustomData[element.name]}
                />
              }

              {
                element.type === 'paragraph' &&
                <p>{element.name}</p>
              }

              {
                element.type === 'file' &&
                <div className="form-group">
                  <label htmlFor={element.name}>{ element.label }</label>
                  <FileUploadInput
                    onChange={ onAttachmentsChange(element.name) }
                    object={clientCustomData[element.name] || []}

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
