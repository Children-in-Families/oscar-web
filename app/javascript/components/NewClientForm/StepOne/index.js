import React        from 'react'
import {
  SelectInput,
  DateInput,
  TextInput,
  UploadInput,
  CheckBoxUpload
}                   from '../../Commons/inputs'
import styles       from './styles'

export default props => {
  const {
    data: {
      client, users, birthProvinces, referralSource, referralSourceCategory, selectedCountry, internationalReferredClient
    },
  } = props
  const exitNgo = client.status === 'Exited'
  const referred = client.status === 'Referred'

  const userLists = users.map(user => [user.first_name + ' ' + user.last_name, user.id])
  const genderLists = [ ['Female', 'female'], ['Male', 'male'], ['Other', 'other'], ['Unknown', 'unknown'] ]

  return (
    <div style={styles.container}>
      <legend className='legend'>Referee Information</legend>
    </div>
  )
}