import React from 'react'
import {
  SelectInput,
  TextInput
} from '../Commons/inputs'

export default props => {
  const { onChange, id, data: { client, schoolGrade, T } } = props
  const schoolGradeLists = schoolGrade.map(grade => ({ label:grade[0], value: grade[1] }))

  const handleOnChangeText = name => event => modifyClientObject({ [name]: event.target.value })
  const handleOnChangeSelect = name => data => modifyClientObject({ [name]: data.data })

  const modifyClientObject = field => {
    const getObject    = client[0]
    const modifyObject = { ...getObject, ...field }

    const newObjects = client.map((object, indexObject) => {
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
          <TextInput T={T} label="School Name" onChange={handleOnChangeText('school_name')} value={client[0].school_name}/>
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            T={T}
            label="School Grade"
            options={schoolGradeLists}
            value={client[0].school_grade}
            onChange={handleOnChangeSelect('school_grade')}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput T={T} label="Main School Contact" onChange={handleOnChangeText('main_school_contact')} value={client[0].main_school_contact} />
        </div>
      </div>
    </div>
  )
}
