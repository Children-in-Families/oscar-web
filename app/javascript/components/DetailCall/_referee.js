import React from 'react'
import { HorizontalTable } from '../Commons/ListTable'

export default ({data}) => {

  const renderItem = (obj, key) => {
    return (
      <tr key={`${key}`}>
        <td className="spacing-first-col">
          {key}
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
      renderItem={renderItem}
    />
  )
}
