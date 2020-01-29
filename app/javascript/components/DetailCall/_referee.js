import React from 'react'
import { titleize } from './helper'
import { HorizontalTable } from '../Commons/ListTable'

export default ({data, call, T}) => {

  const formatObjVal = (field, value) => {
    const boolFields = ['outside', 'anonymous', 'answered_call', 'called_before', 'adult', 'requested_update']
    const titleizeFields = ['gender', 'address_type']

    if (boolFields.indexOf(field) > -1) {
      return value ? 'Yes' : 'No'
    } else if (titleizeFields.indexOf(field) > -1) {
      return titleize(value)
    }
    return value
  }

  const renderItem = (obj, key) => {
    return (
      <tr key={`${key}`}>
        <td className="spacing-first-col">
          {titleize(key)}
        </td>
        <td>
          { formatObjVal(key, obj[key]) }
        </td>
      </tr>
    )
  }

  return (
    <HorizontalTable
      title={T.translate("detailCall.referee.referee")}
      data={data}
      linkHeader={`/calls/${call.id}/edit/referee`}
      renderItem={renderItem}
      T={T}
    />
  )
}
