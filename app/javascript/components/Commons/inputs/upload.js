import React from 'react'
import { Checkbox } from '../inputs'
import { FilePond, registerPlugin } from "react-filepond"
import FilePondPluginFileValidateType from 'filepond-plugin-file-validate-type';
import "filepond/dist/filepond.min.css"

import FilePondPluginImagePreview from "filepond-plugin-image-preview"
import "filepond-plugin-image-preview/dist/filepond-plugin-image-preview.css"

registerPlugin(FilePondPluginImagePreview)
registerPlugin(FilePondPluginFileValidateType);

export default props => {
  const { label, required, onChange, object, onChangeCheckbox, checkBoxValue, T } = props
  const url = object.thumb && object.thumb.url

  return (
    <>
      <label>
        { required && <abbr title='required'>* </abbr> }
        {label}
      </label>

      { url && url !== 'image-placeholder.png' &&
        <div style={{textAlign: 'center'}}>
          <img src={url} />

          <Checkbox
            label={T.translate("referralInfo.remove")}
            checked={checkBoxValue}
            onChange={onChangeCheckbox}
          />
        </div>
      }

      {
        checkBoxValue === false &&
        <FilePond
          allowMultiple={false}
          allowFileTypeValidation={true}
          labelIdle="Choose image. <span class='filepond--label-action'>Browse</span>. Only image with extension <small>.jpg .jpeg .gif .png</small> allowed."
          labelFileTypeNotAllowed="Invalid Image file"
          acceptedFileTypes={"image/jpg, image/jpeg, image/gif, image/png"}
          onupdatefiles={fileItems => onChange(fileItems)}
        />
      }
    </>
  )
}
