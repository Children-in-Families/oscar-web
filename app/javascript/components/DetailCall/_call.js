import React from 'react'
import { formatDate, formatTime, titleize } from './helper'
import { HorizontalTable } from '../Commons/ListTable'

export default ({data, T}) => {
  const renderItem = (obj, key) => {
    return (
      <tr key={`${key}`}>
        <td className="spacing-first-col">
          {titleize(formatKey(key))}
        </td>
        <td>
          {formatLabel(obj, key)}
        </td>
      </tr>
    )
  }

  const formatLabel = (obj, key) => {
    switch (key) {
      case 'date_of_call':
        return <strong>{formatDate(obj[key])}</strong>

      case 'start_datetime':
        return <strong>{formatTime(obj[key])}</strong>

      case 'end_datetime':
        return <strong>{formatTime(obj[key])}</strong>

      default:
        return <strong>{obj[key]}</strong>
    }
  }

  const formatKey = key => {
    switch (key) {
      case 'start_datetime':
        return T.translate("detailCall.call.time_call_began")

      case "end_datetime":
        return T.translate("detailCall.call.time_call_end")

      default:
        return key
    }
  }


  return (
    <HorizontalTable
      title={T.translate("detailCall.call.about_call")}
      data={data}
      linkHeader={`/calls/${data.id}/edit`}
      renderItem={renderItem}
      T={T}
    />
  )
}
