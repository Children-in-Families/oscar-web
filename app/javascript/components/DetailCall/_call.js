import React from 'react'
import { formatDate, formatTime, titleize } from './helper'
import { HorizontalTable } from '../Commons/ListTable'

export default ({data}) => {
  const hiddenFields =
    data.call_type === "Seeking Information" || data.call_type === "Spam Call" || data.call_type === "Wrong Number"
      ? "created_at|updated_at|receiving_staff_id|referee_id|^id$"
      : "created_at|updated_at|information_provided|receiving_staff_id|referee_id|^id$";

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
