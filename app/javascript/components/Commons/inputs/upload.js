import React from 'react'
import { FilePond, registerPlugin } from "react-filepond"
import "filepond/dist/filepond.min.css"

import FilePondPluginImagePreview from "filepond-plugin-image-preview"
import "filepond-plugin-image-preview/dist/filepond-plugin-image-preview.css"

registerPlugin(FilePondPluginImagePreview)

export default props => {
  const { label, required, onChange, url } = props

  const generateFileObject = () => {
    return [{ source: url, options: { type: 'local' } }]
  }

  return (
    <>
      <label>
        { required && <abbr title='required'>* </abbr> }
        {label}
      </label>

      <FilePond
        files={generateFileObject()}
        allowMultiple={false}
        onupdatefiles={fileItems => onChange(fileItems)}
        // maxFiles={3}
        // server="/api"
        // oninit={() => this.handleInit()}
        // onupdatefiles={fileItems => {
        //   // Set currently active file objects to this.state
        //   this.setState({
        //     files: fileItems.map(fileItem => fileItem.file)
        //   });
        // }}
      />
    </>
  )
}