import React from 'react'
import {
  SelectInput,
  TextInput
} from '../Commons/inputs'

export default props => {
  const { onChange, id, hintText, data: { client, schoolGrade, T } } = props
  const schoolGradeLists = schoolGrade.map(grade => ({ label: T.translate("schoolGrade."+grade[0]), value: grade[1] }))

  return (
    <div id={id} className="collapse">
      <br/>
      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            label={T.translate("schoolInfo.school_name")}
            onChange={onChange('client', 'school_name')}
            value={client.school_name}
            hintText={hintText.school.school_info}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            label={T.translate("schoolInfo.school_grade")}
            options={schoolGradeLists}
            value={client.school_grade}
            onChange={onChange('client', 'school_grade')}
            hintText={hintText.school.school_grade}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-4">
          <TextInput
            label={T.translate("schoolInfo.main_school_contact")}
            onChange={onChange('client', 'main_school_contact')}
            value={client.main_school_contact}
            inlineClassName="school-contact"
            hintText={hintText.school.school_contact}
          />
        </div>
      </div>
    </div>
  )
}
