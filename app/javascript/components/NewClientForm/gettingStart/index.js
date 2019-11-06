import React        from 'react'
import {
  SelectInput,
  DateInput,
  TextInput
}                   from '../../Commons/inputs'
import styles       from './styles'

export default props => {
  const { step, data: { client, users, birth_provinces, referral_source, referral_source_category}, translations } = props
  const exitNgo = client.status === 'Exited'
  const referred = client.status === 'Referred'

  const userLists = users.map(user => [user.first_name + ' ' + user.last_name, user.id])
  const genderLists = [ ['Female', 'female'], ['Male', 'male'], ['Other', 'other'], ['Unknown', 'unknown'] ]
  const provinces = [ ["Cambodia", [["Burmese", 52]]], ["Thai", [["Hello", 12]]] ]

  return (
    step === 1 &&
    <div style={styles.container}>
      <legend style={styles.legend}>{translations.staff_responsibilities}</legend>
      <div className='row'>
        <div className='col-xs-12 col-sm-6 col-md-4'>
          <SelectInput required label={translations.received_by_id} collections={userLists} />
        </div>

        <div className='col-xs-12 col-sm-6 col-md-4'>
          <SelectInput label={translations.followed_up_by_id} collections={userLists} />
        </div>

        <div className='col-xs-12 col-sm-6 col-md-4'>
          <SelectInput required={!exitNgo || referred } multiple label={translations.users} collections={userLists} />
        </div>
      </div>

      <div className='row'>
        <div className='col-xs-12 col-sm-6 col-md-4'>
          <DateInput required label={translations.initial_referral_date} />
        </div>

        <div className='col-xs-12 col-sm-6 col-md-4'>
          <DateInput required label={translations.follow_up_date} />
        </div>
      </div>

      <legend style={styles.legend}>{translations.referral_information}</legend>
      <div className='row'>
        <div className='col-xs-12 col-sm-6 col-md-4'>
          <TextInput label='Given Name (Latin)' />
        </div>

        <div className='col-xs-12 col-sm-6 col-md-4'>
          <TextInput label='Family Name (Latin)' />
        </div>

        <div className='col-xs-12 col-sm-6 col-md-4'>
          <SelectInput required label='Gender' collections={genderLists} />
        </div>
      </div>

      <div className='row'>
        <div className='col-xs-12 col-sm-6 col-md-4'>
          <TextInput label='Given Name (Khmer)' />
        </div>

        <div className='col-xs-12 col-sm-6 col-md-4'>
          <TextInput label='Family Name (Khmer)' />
        </div>

        <div className='col-xs-12 col-sm-6 col-md-4'>
          <DateInput required label='Date of Birth' />
        </div>
      </div>

      <div className='row'>
        <div className='col-xs-12 col-sm-6 col-md-4'>
          <SelectInput asGroup label='Birth Province' collections={provinces} />
        </div>

        <div className='col-xs-12 col-sm-6 col-md-4'>
          <SelectInput required label='Referral Source Category' collections={referral_source_category} />
        </div>

        <div className='col-xs-12 col-sm-6 col-md-4'>
          <SelectInput label='Referral Source' collections={referral_source} />
        </div>
      </div>
    </div>
  )
}