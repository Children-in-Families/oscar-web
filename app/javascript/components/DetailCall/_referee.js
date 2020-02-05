import React from 'react'
import { titleize } from './helper'
import { HorizontalTable } from '../Commons/ListTable'

export default ({ data, call, T, locale}) => {

  const formatObjVal = (field, value) => {
    const boolFields = ['outside', 'anonymous', 'adult']
    const titleizeFields = ['gender', 'address_type']

    if (boolFields.indexOf(field) > -1) {
      return value === null ? '' : value ? 'Yes' : 'No'
    } else if (titleizeFields.indexOf(field) > -1) {
      return titleize(value)
    }
    return value
  }

  const renderItem = (obj, key) => {
    return (
      <tr key={`${key}`}>
        <td className="spacing-first-col">
          { T.translate("commons.listTable.index."+titleize(key)) }
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
      linkHeader={`/calls/${call.id}/edit/referee?locale=${locale}`}
      renderItem={renderItem}
      T={T}
    />
  )
}
