import React, {useState} from 'react'
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
  // const givenFiles = object.map(file => ({source: file.url, options: { type: 'local', file: { name: file.filename, size: file.size, type: file.content_type} }}))
  // const givenFiles = object.map(file => ({source: file.url, options: { type: 'local', file: { name: file.filename } }}))
  const givenFiles = object.map(file => ({source: file.url, options: { type: 'local', metadata: { filename: file.filename } }}))
  // console.log(object)
  // console.log(files)
  // object.map(file => ({source: file.url, options: { type: 'local' }}))

  const [files, setFiles] = useState(givenFiles)

  const onLoadFile = (file, success, error) => {
    // console.log('onLoadFile: ');
    // console.log(file);
    // console.log('files');
    // console.log(files);
  }

  const server = {
    // process: (fieldName, file, metadata, load, error, progress, abort) => {
    //   console.log(fieldName);
    //   console.log(file);
    //   console.log(metadata);
    // },
    load: (source, load, error, progress, abort, headers) => {
      // console.log("source" + source);
      // load(source);
      let req = new Request(source);
      fetch(req).then((response) => {
        // console.log(new Response(response.body));
        // debugger
        // let json = response.json();
        // console.log(json);

        // response.json().then((data) => {
        //   console.log(data);
        // });
        // debugger

        response.blob().then((fileBlob) => {
          // console.log('loading blob')
          // console.log(fileBlob);

          fileBlob.headers = { filename: source }
          fileBlob.original_filename = source

          load(fileBlob, load, onLoadFile)
        });
      })

      // fetch(source)
      //     .then(res => res.blob())
      //     .then(load)
      //     .catch(error)
    }
  }

  const init = (filePon)=> {
    // console.log('init');
    // debugger
    console.log(files);
  }

  const onUpdateFiles = (fileItems) => {
    // console.log("onUpdateFiles: ");
    // console.log(fileItems[0].getMetadata());
    // fileItems = fileItems.map((file) => {
    //   console.log(file.getMetadata());
    //   console.log(file.name);
    //
    //   if (file.getMetadata() && file.getMetadata().filename) {
    //     file.original_filename = file.getMetadata().filename;
    //   }
    //
    //   return file;
    // })

    setFiles(fileItems);
    onChange(fileItems);
  }

  return (
    <>
      <label>
        { required && <abbr title='required'>* </abbr> }
        {label}
      </label>

      {
        checkBoxValue === false &&
        <FilePond
          server={server}
          files={files}
          oninit={init}
          instantUpload={false}
          allowMultiple={true}
          allowFileTypeValidation={true}
          labelIdle="Choose files. <span class='filepond--label-action'>Browse</span>. Only file with extension <small>.jpg .jpeg .png .pdf</small> allowed."
          labelFileTypeNotAllowed="Invalid file type"
          acceptedFileTypes={"image/jpg, image/jpeg, image/png, application/pdf"}
          onupdatefiles={onUpdateFiles}
        />
      }
    </>
  )
}
