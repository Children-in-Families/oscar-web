import React from 'react'
import {
  SelectInput,
  TextInput,
  TextArea
} from '../Commons/inputs'
import { t } from '../../utils/i18n'

export default props => {
  const { onChange, id, translation, fieldsVisibility, hintText, data: { client, schoolGrade, T } } = props
  const schoolGradeLists = schoolGrade.map(grade => ({ label: T.translate("schoolGrade."+grade[0]), value: grade[1] }))

  return (
    <div id={id} className="collapse">
      <br/>
      <div className="row">
        {
          fieldsVisibility.school_name == true &&
          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label={ t(translation, 'clients.form.school_name') }
              onChange={onChange('client', 'school_name')}
              value={client.school_name}
              hintText={hintText.school.school_info}
            />
          </div>
        }

        {
          fieldsVisibility.school_grade == true &&
          <div className="col-xs-12 col-md-6 col-lg-3">
            <SelectInput
              label={ t(translation, 'clients.form.school_grade') }
              options={schoolGradeLists}
              value={client.school_grade}
              onChange={onChange('client', 'school_grade')}
              hintText={hintText.school.school_grade}
            />
          </div>
        }

        {
          fieldsVisibility.main_school_contact == true &&
          <div className="col-xs-12 col-md-6 col-lg-4">
            <TextInput
              label={ t(translation, 'clients.form.main_school_contact') }
              onChange={onChange('client', 'main_school_contact')}
              value={client.main_school_contact}
              inlineClassName="school-contact"
              hintText={hintText.school.school_contact}
            />
          </div>
        }

        {
          fieldsVisibility.education_background == true &&
          <div className="col-xs-12 col-md-6 col-lg-4">
            <TextArea
              label={ t(translation, 'clients.form.education_background') }
              onChange={onChange('client', 'education_background')}
              value={client.education_background}
            />
          </div>
        }
      </div>
    </div>
  )
}
