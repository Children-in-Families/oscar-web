import React from 'react'
import {
  SelectInput,
  TextInput,
  DateInput
} from '../Commons/inputs'
import styles from './styles'

export default props => {
  const { data: { client, users, birth_provinces, referral_source, referral_source_category }, translations } = props

  const name = []
  const phoneNumber = []
  const userLists = users.map(user => [user.first_name + ' ' + user.last_name, user.id])
  const genderLists = [['Female', 'female'], ['Male', 'male'], ['Other', 'other'], ['Unknown', 'unknown']]
  const provinces = [["Cambodia", [["Burmese", 52]]], ["Thai", [["Hello", 12]]]]
  const rate = [[1], [2], [3], [4]]


  return (
    <div className="container">
      <legend>Client / Referral - More Information</legend>
      <div className="row">
        <div className="col-xs-12 col-sm-6 col-md-3">
        <label>Do you want to add: </label>
        </div>
      </div>
    </div>
  )
}
