import React from 'react'
import { HorizontalTable, VerticalTable } from '../Commons/ListTable'

export default ({data, columns}) => {

  return (
    <VerticalTable
      title="List Clients"
      data={data}
      columns={columns}
    />
  )
}
