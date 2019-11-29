import React from 'react'
import {
  SelectInput,
  TextInput
} from '../Commons/inputs'

export default props => {
  const { onChange, id, data: { client, schoolGrade } } = props
  const schoolGradeLists = schoolGrade.map(grade => ({ label:grade[0], value: grade[1] }))

  return (
    <div id={id} className="collapse">
      <br/>
      <div className="row">
        <div className="col-xs-3">
          <TextInput label="School Name" onChange={onChange('client', 'school_name')} value={client.school_name}/>
        </div>
        <div className="col-xs-3">
          <SelectInput
            label="School Grade"
            options={schoolGradeLists}
            value={client.school_grade}
            onChange={onChange('client', 'school_grade')}
          />
        </div>
        <div className="col-xs-3">
          <TextInput label="Main School Contact" onChange={onChange('client', 'main_school_contact')} value={client.main_school_contact} />
        </div>
      </div>
    </div>
  )
}
