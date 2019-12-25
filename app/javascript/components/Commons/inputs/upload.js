import React from 'react'
import { Checkbox } from '../inputs'
import { FilePond, registerPlugin } from "react-filepond"
import "filepond/dist/filepond.min.css"

import FilePondPluginImagePreview from "filepond-plugin-image-preview"
import "filepond-plugin-image-preview/dist/filepond-plugin-image-preview.css"

registerPlugin(FilePondPluginImagePreview)

export default props => {
  const { label, required, onChange, object, onChangeCheckbox, checkBoxValue } = props
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
            label="Remove"
            checked={checkBoxValue}
            onChange={onChangeCheckbox}
          />
        </div>
      }

      {
        checkBoxValue === false &&
        <FilePond
          allowMultiple={false}
          onupdatefiles={fileItems => onChange(fileItems)}
        />
      }
    </>
  )
}