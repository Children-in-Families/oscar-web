import React from 'react'
import {
  SelectInput,
  TextInput
} from '../Commons/inputs'

export default props => {
  const { onChange, id, data: { clients, schoolGrade, T } } = props
  const client = clients[0]
  const schoolGradeLists = schoolGrade.map(grade => ({ label: T.translate("schoolGrade." + grade[0]), value: grade[1] }))

  const handleOnChangeText = name => event => modifyClientObject({ [name]: event.target.value })
  const handleOnChangeSelect = name => data => modifyClientObject({ [name]: data.data })

  const modifyClientObject = field => {
    const modifyObject = { ...client, ...field }

    const newObjects = clients.map((object, indexObject) => {
      const newObject = indexObject === 0 ? modifyObject : object
      return newObject
    })

    onChange('client', newObjects)({type: 'object'})
  }

  return (
    <div id={id} className="collapse">
      <br/>
      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput T={T} label={T.translate("newCall.schoolInfo.school_name")} onChange={handleOnChangeText('school_name')} value={client.school_name}/>
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            T={T}
            label={T.translate("newCall.schoolInfo.school_grade")}
            options={schoolGradeLists}
            value={client.school_grade}
            onChange={handleOnChangeSelect('school_grade')}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput T={T} label={T.translate("newCall.schoolInfo.main_school_contact")} onChange={handleOnChangeText('main_school_contact')} value={client.main_school_contact} />
        </div>
      </div>
    </div>
  )
}
