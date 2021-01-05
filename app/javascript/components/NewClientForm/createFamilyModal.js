import React, { useState } from 'react'
import { SelectInput } from '../Commons/inputs'
import { RadioButton } from 'primereact/radiobutton'

export default props => {
  const { onChange, onSave, data: { families, clientData, familyMemberData, T } } = props

  const [showSave, setShowSave]     = useState(false)
  const [showSelect, setShowSelect] = useState(false)
  const [value, setValue] = useState("")

  const familyLists = families.map(family => ({ label: family.name, value: family.id }))

  const onChangeFamily = ({ data, action, type }) => {
    setShowSave(true)
    onChange('familyMember', 'family_id')({data: data, type})
  }

  const handleCreateNewFamily = (boolean) => event => {
    setShowSelect(false)
    setShowSave(boolean)
    setValue(event.target.value)
  }

  const handleAttachClientToFamily = (boolean) => event => {
    setShowSave(false)
    setShowSelect(boolean)
    setValue(event.target.value)
  }

  const handleNo = (boolean) => event => {
    setShowSelect(false)
    setShowSave(boolean)
    setValue(event.target.value)
  }

  const handleSave = () => {
    onSave()(response => {
      let url = ''

      if(value === 'createNewFamilyRecord')
        url = `/families/new?client=${response.id || clientData.id}`
      else
        url = `/clients/${response.slug}?notice=` + T.translate("createFamilyModal.successfully_created")

      document.location.href=url
    }, true)
  }

  return (
    <div className="p-md">
      <p>{T.translate("createFamilyModal.create_family_record")}</p>
      <br/>

      <div className="row">
        <div className="col-xs-1">
          <RadioButton
            inputId="newFamily"
            name="clientConfirmation"
            value="createNewFamilyRecord"
            onChange={handleCreateNewFamily(true)}
            checked={value === 'createNewFamilyRecord'}
          />
        </div>
        <div className="col-xs-6">
          <p>{T.translate("createFamilyModal.create_family")}</p>
        </div>
      </div>

      <div className="row">
        <div className="col-xs-1">
          <RadioButton
            inputId="newFamily"
            name="clientConfirmation"
            value="attachWithExistingFamily"
            onChange={handleAttachClientToFamily(true)}
            checked={value === 'attachWithExistingFamily'}
          />
        </div>
        <div className="col-xs-6">
          <p>{T.translate("createFamilyModal.attach_family_to_client")}</p>
          { showSelect && <SelectInput options={familyLists} value={familyMemberData.family_id} onChange={onChangeFamily} /> }
        </div>
      </div>

      <div className="row">
        <div className="col-xs-1">
          <RadioButton
            inputId="newFamily"
            name="clientConfirmation"
            value="no"
            onChange={handleNo(true)}
            checked={value === 'no'}
          />
        </div>
        <div className="col-xs-6">
          <p>{T.translate("createFamilyModal.no")}</p>
        </div>
      </div>

      <hr />
      <div style={{display: 'flex', justifyContent: 'flex-end'}}>
        <span type="button" style={showSave && styles.allowButton || styles.preventButton} onClick={handleSave}>{T.translate("createFamilyModal.save")}</span>
      </div>
    </div>
  )
}

const styles = {
  allowButton: {
    padding: '0.5em 1em',
    textDecoration: 'none',
    borderRadius: '5px',
    margin: '0 0.5em',
    background: '#1AB394',
    color: '#fff',
    cursor: 'pointer'
  },
  preventButton: {
    color: '#aaa',
    padding: '0.5em 1em',
    textDecoration: 'none',
    borderRadius: '5px',
    margin: '0 0.5em',
    background: '#eee',
    cursor: 'not-allowed',
    pointerEvents: 'none'
  }
}
