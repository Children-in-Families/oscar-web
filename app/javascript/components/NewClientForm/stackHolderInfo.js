import React from 'react'
import { TextInput } from '../Commons/inputs'
import { t } from '../../utils/i18n'

export default props => {
  const { onChange, id, translation, fieldsVisibility, hintText, data: { client, T } } = props

  return (
    <div id={id} className="collapse">
      <br/>
      <div className="row">
        {
          fieldsVisibility.neighbor_name == true &&
          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label={ t(translation, 'clients.form.neighbor_name') }
              onChange={onChange('client', 'neighbor_name')}
              value={client.neighbor_name}
            />
          </div>
        }

        {
          fieldsVisibility.neighbor_phone == true &&
          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label={ t(translation, 'clients.form.neighbor_phone') }
              onChange={onChange('client', 'neighbor_phone')}
              value={client.neighbor_phone}
            />
          </div>
        }
      </div>

      <div className="row">
        {
          fieldsVisibility.dosavy_name == true &&
          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label={ t(translation, 'clients.form.dosavy_name') }
              onChange={onChange('client', 'dosavy_name')}
              value={client.dosavy_name}
            />
          </div>
        }

        {
          fieldsVisibility.dosavy_phone == true &&
          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label={ t(translation, 'clients.form.dosavy_phone') }
              onChange={onChange('client', 'dosavy_phone')}
              value={client.dosavy_phone}
            />
          </div>
        }
      </div>

      <div className="row">
        {
          fieldsVisibility.chief_commune_name == true &&
          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label={ t(translation, 'clients.form.chief_commune_name') }
              onChange={onChange('client', 'chief_commune_name')}
              value={client.chief_commune_name}
            />
          </div>
        }

        {
          fieldsVisibility.chief_commune_phone == true &&
          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label={ t(translation, 'clients.form.chief_commune_phone') }
              onChange={onChange('client', 'chief_commune_phone')}
              value={client.chief_commune_phone}
            />
          </div>
        }
      </div>

      <div className="row">
        {
          fieldsVisibility.chief_village_name == true &&
          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label={ t(translation, 'clients.form.chief_village_name') }
              onChange={onChange('client', 'chief_village_name')}
              value={client.chief_village_name}
            />
          </div>
        }

        {
          fieldsVisibility.chief_village_phone == true &&
          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label={ t(translation, 'clients.form.chief_village_phone') }
              onChange={onChange('client', 'chief_village_phone')}
              value={client.chief_village_phone}
            />
          </div>
        }
      </div>

      <div className="row">
        {
          fieldsVisibility.ccwc_name == true &&
          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label={ t(translation, 'clients.form.ccwc_name') }
              onChange={onChange('client', 'ccwc_name')}
              value={client.ccwc_name}
            />
          </div>
        }

        {
          fieldsVisibility.ccwc_phone == true &&
          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label={ t(translation, 'clients.form.ccwc_phone') }
              onChange={onChange('client', 'ccwc_phone')}
              value={client.ccwc_phone}
            />
          </div>
        }
      </div>

      <div className="row">
        {
          fieldsVisibility.legal_team_name == true &&
          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label={ t(translation, 'clients.form.legal_team_name') }
              onChange={onChange('client', 'legal_team_name')}
              value={client.legal_team_name}
            />
          </div>
        }

        {
          fieldsVisibility.legal_representative_name == true &&
          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label={ t(translation, 'clients.form.legal_representative_name') }
              onChange={onChange('client', 'legal_representative_name')}
              value={client.legal_representative_name}
            />
          </div>
        }

        {
          fieldsVisibility.legal_team_phone == true &&
          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label={ t(translation, 'clients.form.legal_team_phone') }
              onChange={onChange('client', 'legal_team_phone')}
              value={client.legal_team_phone}
            />
          </div>
        }
      </div>

      <div className="row">
        {
          fieldsVisibility.other_agency_name == true &&
          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label={ t(translation, 'clients.form.other_agency_name') }
              onChange={onChange('client', 'other_agency_name')}
              value={client.other_agency_name}
            />
          </div>
        }

        {
          fieldsVisibility.other_representative_name == true &&
          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label={ t(translation, 'clients.form.other_representative_name') }
              onChange={onChange('client', 'other_representative_name')}
              value={client.other_representative_name}
            />
          </div>
        }

        {
          fieldsVisibility.other_agency_phone == true &&
          <div className="col-xs-12 col-md-6 col-lg-3">
            <TextInput
              label={ t(translation, 'clients.form.other_agency_phone') }
              onChange={onChange('client', 'other_agency_phone')}
              value={client.other_agency_phone}
            />
          </div>
        }
      </div>
    </div>
  )
}
