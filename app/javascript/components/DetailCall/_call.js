import React from 'react'
import { formatDate, titleize } from './helper'
import { HorizontalTable } from '../Commons/ListTable'

export default ({data, T, locale}) => {
  const hiddenFields =
    data.call_type === "Seeking Information" || data.call_type === "Spam Call" || data.call_type === "Wrong Number"
      ? "created_at|updated_at|referee_id|^id$"
      : "created_at|updated_at|information_provided|referee_id|^id$";

  const buildList = (items) => {
    const listItems = items.map((item, index) =>
      (<li key={index}>{item}</li>)
    )
    return <ul>{listItems}</ul>
  }

  const renderItem = (obj, key) => {
    return (
      <tr key={`${key}`}>
        <td className="spacing-first-col">
          { T.translate("commons.listTable.index."+titleize(key)) }
        </td>
        <td>
          {
            Array.isArray(obj[key]) ?
              buildList(obj[key])
            : formatLabel(obj, key)
          }
        </td>
      </tr>
    )
  }

  const formatLabel = (obj, key) => {
    switch (key) {
      case 'date_of_call':
        return formatDate(obj[key])

      case 'answered_call':
      case 'called_before':
      case 'childsafe_agent':
      case 'requested_update':
      case 'not_a_phone_call':
        return obj[key] ? 'Yes' : 'No'
      case 'call_type':
        return T.translate(`detailCall.call.${obj[key]}`)
      default:
        return obj[key]
    }
  }

  return (
    <HorizontalTable
      title={T.translate("detailCall.call.about_call")}
      data={data}
      linkHeader={`/calls/${data.id}/edit?locale=${locale}`}
      renderItem={renderItem}
      T={T}
      rejectField={ hiddenFields }
    />
  )
}
