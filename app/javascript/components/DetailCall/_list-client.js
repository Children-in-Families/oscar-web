import React from 'react'
import { HorizontalTable, VerticalTable } from '../Commons/ListTable'

export default ({data, columns, T, local}) => {

  return (
    <VerticalTable
      title={T.translate("detailCall.listClient.list_clients")}
      data={data}
      columns={columns}
      local={local}
      T={T}
    />
  )
}
