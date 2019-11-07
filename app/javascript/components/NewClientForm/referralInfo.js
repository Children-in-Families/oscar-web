import React       from 'react'
import {
  SelectInput,
  DateInput,
  TextInput
}                   from '../Commons/inputs'

export default props => {
  const { data: { client, users, birth_provinces, referral_source, referral_source_category}, translations } = props

  const name = []
  const phoneNumber = []
  const userLists = users.map(user => [user.first_name + ' ' + user.last_name, user.id])
  const genderLists = [ ['Female', 'female'], ['Male', 'male'], ['Other', 'other'], ['Unknown', 'unknown'] ]
  const provinces = [ ["Cambodia", [["Burmese", 52]]], ["Thai", [["Hello", 12]]] ]

  return (
    <div className="container">
      <legend>Client / Referral Information</legend>
    </div>
  )
}
