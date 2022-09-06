import React, {useEffect, useState} from 'react'
import { Checkbox } from '../inputs'
import { FilePond, registerPlugin } from "react-filepond"
import FilePondPluginFileValidateType from 'filepond-plugin-file-validate-type';
import "filepond/dist/filepond.min.css"

import FilePondPluginImagePreview from "filepond-plugin-image-preview"
import "filepond-plugin-image-preview/dist/filepond-plugin-image-preview.css"

registerPlugin(FilePondPluginImagePreview)
registerPlugin(FilePondPluginFileValidateType);

export default props => {
  const { label, isError, errorText, required, onChange, object, onChangeCheckbox, removeAttachmentcheckBoxValue, showFilePond, T } = props
  const existingFiles = object.filter(file => { return file.url && file.url.length > 0 } );
  const [files, setFiles] = useState([])

  const renderExistingFiles = (files) => {
    return (
      files.map((file, index) => {
        if (file.thumb && file.thumb.url != "image-placeholder.png") {
          return (<img key={index} src={file.thumb.url}/>);
        } else {
          return (
            <a target="_blank" key={index} href={file.url}>File: { file.filename }</a>
          )
        }
      })
    )
  }

  const onUpdateFiles = (fileItems) => {
    setFiles(fileItems);
    onChange(fileItems);
  }

  return (
    <>
      <label style={isError && styles.errorText || styles.inlineDisplay }>
        { required && <abbr title='required'>* </abbr> }
        {label}
      </label>

      { existingFiles.length > 0 && showFilePond &&
        <div className='remove-files-wrapper' style={{textAlign: 'center'}}>
          { renderExistingFiles(existingFiles) }

          <div>
            <Checkbox
              label={T.translate("referralInfo.remove")}
              checked={removeAttachmentcheckBoxValue}
              onChange={onChangeCheckbox}
            />
          </div>
        </div>
      }

      {
        showFilePond === true &&
        <>
          <FilePond
            files={files}
            allowMultiple={true}
            instanceUpload={false}
            allowFileTypeValidation={true}
            labelIdle="Choose files. <span class='filepond--label-action'>Browse</span>. Only file with extension <small>.jpg .jpeg .png .pdf</small> allowed."
            labelFileTypeNotAllowed="Invalid file type"
            acceptedFileTypes={"image/jpg, image/jpeg, image/png, application/pdf"}
            onupdatefiles={onUpdateFiles}
          />
          { isError && <span style={styles.errorText}>{errorText || T.translate("validation.cannot_blank")}</span> }
        </>
      }
    </>
  )
}

const styles = {
  errorText: {
    color: 'red',
    fontSize: '14px'

  },
  errorInput: {
    borderColor: 'red'
  },
  box: {
    boxShadow: 'none',
    lineHeight: 'inherit'
  },
  inlineDisplay: {
    display: 'inline',
    fontSize: '14px'
  }
}

