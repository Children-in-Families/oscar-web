import React from 'react'
import { titleize } from './helper'
import { HorizontalTable } from '../Commons/ListTable'

export default ({data, call}) => {

  const renderItem = (obj, key) => {
    return (
      <tr key={`${key}`}>
        <td className="spacing-first-col">
          {titleize(key)}
        </td>
        <td>
          {obj[key]}
        </td>
      </tr>
    )
  }

  return (
    <HorizontalTable
      title="Referee"
      data={data}
      linkHeader={`/calls/${call.id}/edit/referee`}
      renderItem={renderItem}
    />
  )
}
