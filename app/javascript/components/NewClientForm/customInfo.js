import React from 'react'
import { t } from '../../utils/i18n'
import {
  TextInput,
  SelectInput
} from '../Commons/inputs'

export default props => {
  const { onChange, fieldsVisibility, current_organization, translation, id, hintText, data: { errorFields, ratePoor, client, T, customId1, customId2, } } = props

  const rateLists = ratePoor.map(rate => ({ label: rate[0], value: rate[1] }))

  return (
    <div id={id} className="collapse">
      <br/>
      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            label={ customId1 } onChange={onChange('client', 'code')}
            value={client.code}
            inlineClassName="custom-id1"
            hintText={hintText.custom.custom_id1}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            label={ customId2 }
            onChange={onChange('client', 'kid_id')}
            value={client.kid_id}
            isError={errorFields.includes('kid_id')}
            errorText={errorFields.includes('kid_id') && T.translate("customInfo.has_already_taken")}
            inlineClassName="custom-id2"
            hintText={hintText.custom.custom_id2}
          />
        </div>

        {
          fieldsVisibility.rated_for_id_poor == true && current_organization.country != 'nepal' &&
          <div className="col-xs-12 col-md-6 col-lg-6">
            <SelectInput
              label={t(translation, 'clients.form.rated_for_id_poor')}
              options={rateLists} value={client.rated_for_id_poor}
              onChange={onChange('client', 'rated_for_id_poor')}
              hintText={hintText.custom.custom_id_poor}
            />
          </div>
        }
      </div>
    </div>
  )
}
