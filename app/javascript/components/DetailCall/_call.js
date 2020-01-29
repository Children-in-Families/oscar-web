import React from 'react'
import { formatDate, formatTime, titleize } from './helper'
import { HorizontalTable } from '../Commons/ListTable'

export default ({data}) => {
  const hiddenFields =
    data.call_type === "Seeking Information" || data.call_type === "Spam Call" || data.call_type === "Wrong Number"
      ? "created_at|updated_at|referee_id|^id$"
      : "created_at|updated_at|information_provided|referee_id|^id$";

  const renderItem = (obj, key) => {
    return (
      <tr key={`${key}`}>
        <td className="spacing-first-col">
          {titleize(formatKey(key))}
        </td>
        <td>
          <strong>{formatLabel(obj, key)}</strong>
        </td>
      </tr>
    )
  }

  const formatLabel = (obj, key) => {
    switch (key) {
      case 'date_of_call':
        return formatDate(obj[key])
      
      case 'start_datetime':
        return formatTime(obj[key])

      case 'end_datetime':
        return formatTime(obj[key])

      case 'answered_call':
      case 'called_before':
      case 'requested_update':
        return obj[key] ? 'Yes' : 'No'

      default:
        return obj[key]
    }
  }

  const formatKey = key => {
    switch (key) {
      case 'start_datetime':
        return "Time Call Began"

      case "end_datetime":
        return "Time Call Ended"

      default:
        return key
    }
  }


  return (
    <HorizontalTable 
      title="About Call"
      data={data}
      linkHeader={`/calls/${data.id}/edit`}
      renderItem={renderItem}
      rejectField={ hiddenFields }
    />
  )
}
