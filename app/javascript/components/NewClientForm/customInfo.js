import React from 'react'
import {
  TextInput,
  SelectInput
} from '../Commons/inputs'

export default props => {
  const { onChange, id, translation, current_organization, data: { errorFields, ratePoor, client, T, brc_presented_ids, brc_prefered_langs } } = props

  const rateLists = ratePoor.map(rate => ({ label: rate[0], value: rate[1] }))
  const brcPresentedIdList = brc_presented_ids.map(presented_id => ({ label: presented_id, value: presented_id }))
  const brcPreferedLangsList = brc_prefered_langs.map(preferred_language => ({ label: preferred_language, value: preferred_language }))
  console.log("customInfo", current_organization);
  return (
    <div id={id} className="collapse">
      <br/>
      {
        (current_organization && current_organization == 'brc') &&
        <div className="row">
          <div className="col-xs-12 col-md-6 col-lg-3" style={{ maxHeight: '59px' }}>
            <SelectInput
              label={translation.clients.form['presented_id']}
              options={brcPresentedIdList}
              onChange={onChange('client', 'presented_id')}
              value={client.presented_id}
            />
          </div>
          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label={translation.clients.form['id_number']}
              onChange={onChange('client', 'id_number')}
              value={client.id_number}
            />
          </div>
          <div className="col-xs-12 col-md-6 col-lg-3" style={{ maxHeight: '59px' }}>
            <SelectInput
              label={translation.clients.form['preferred_language']}
              options={brcPreferedLangsList}
              onChange={onChange('client', 'preferred_language')}
              value={client.preferred_language}
            />
          </div>
          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label={translation.clients.form['whatsapp']}
              onChange={onChange('client', 'whatsapp')}
              value={client.whatsapp}
            />
          </div>
          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label={translation.clients.form['other_phone_number']}
              onChange={onChange('client', 'other_phone_number')}
              value={client.other_phone_number}
            />
          </div>
          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label={translation.clients.form['v_score']}
              type='number'
              onChange={onChange('client', 'v_score')}
              value={client.v_score}
            />
          </div>
          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label={translation.clients.form['brsc_branch']}
              onChange={onChange('client', 'brsc_branch')}
              value={client.brsc_branch}
            />
          </div>
        </div>
      }
      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput label={T.translate("customInfo.custom_id_1")} onChange={onChange('client', 'code')} value={client.code} />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            label={T.translate("customInfo.custom_id_2")}
            onChange={onChange('client', 'kid_id')}
            value={client.kid_id}
            isError={errorFields.includes('kid_id')}
            errorText={errorFields.includes('kid_id') && T.translate("customInfo.has_already_taken")}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-6">
          <SelectInput label={T.translate("customInfo.rate_client_id")} options={rateLists} value={client.rated_for_id_poor} onChange={onChange('client', 'rated_for_id_poor')} />
        </div>
      </div>
    </div>
  )
}
