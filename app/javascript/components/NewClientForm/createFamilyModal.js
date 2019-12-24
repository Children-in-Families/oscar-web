import React, { useState } from 'react'
import { SelectInput } from '../Commons/inputs'
import { RadioButton } from 'primereact/radiobutton'

export default props => {
  const { onChange, onSave, data: { families, clientData } } = props

  const [showSave, setShowSave]     = useState(false)
  const [showSelect, setShowSelect] = useState(false)
  const [value, setValue] = useState("")

  const familyLists = families.map(family => ({ label: family.name, value: family.id }))

  const onChangeFamily = ({ data, action, type }) => {
    setShowSave(true)
    let value = []
    if (action === 'select-option') {
      value.push(data)
    } else if (action === 'clear') {
      value = []
    }
    onChange('client', 'family_ids')({ data: value, type })
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
        url = `/families/new?children=${response.id}`
      else
        url = `/clients/${response.slug}?notice=success`

      document.location.href=url
    }, true)
  }

  return (
    <>
      <p>Would you like to create a family record for this client, or attach them to an existing family?</p>
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
          <p>Create a new family with client</p>
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
          <p>Attach with existing family record</p>
          { showSelect && <SelectInput options={familyLists} value={clientData.family_ids.length > 0 && clientData.family_ids[0] || null} onChange={onChangeFamily} /> }
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
          <p>No</p>
        </div>
      </div>

      <hr />
      <div style={{display: 'flex', justifyContent: 'flex-end'}}>
        <span type="button" style={showSave && styles.allowButton || styles.preventButton} onClick={handleSave}>Save</span>
      </div>
    </>
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

