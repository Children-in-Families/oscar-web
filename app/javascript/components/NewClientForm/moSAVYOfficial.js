import { React, useState } from "react";
import { SelectInput, TextInput, TextArea } from "../Commons/inputs";
import { t } from "../../utils/i18n";

export default (props) => {
  const {
    onChange,
    translation,
    fieldsVisibility,
    data: { client, records, T },
  } = props;

  const [RecordData, setRecordData] = useState([{ name: "Record 1", position: "position 1" }]);

  const onRemoveOfficial = () => {

  }

  const onAddOfficial = () => {

  }

  const renderUI = () => {
    return (
      RecordData.map((official, index) => {
        return (
          <div className="row">
            <div className="col-12 col-sm-3">
              <TextInput
                label="Name"
                onChange={()=>{}}
                required={ true }
                value={official.name}
              />
            </div>
  
            <div className="col-10 col-sm-3">
              <TextInput
                label="Position"
                onChange={()=>{}}
                required={ true }
                value={official.position}
              />
            </div>
  
            <div className="col-2 col-sm-2">
              <button className='btn btn-danger' onClick={onRemoveOfficial}>Remove</button>
            </div>
          </div>
        )
      })
    )
  }

  return (
    <div id="mosavy-officials" className="row">
      {  renderUI() }
      <div className="row">
        <div className="col-sm-12">
          <button className='btn btn-primary' onClick={onAddOfficial}>Add</button>
        </div>
      </div>
    </div>
  )
}
