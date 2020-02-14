import React from 'react'
import { HorizontalTable, VerticalTable } from '../Commons/ListTable'

export default ({ data, columns, T, locale}) => {

  return (
    <VerticalTable
      title={T.translate("detailCall.listClient.list_clients")}
      data={data}
      columns={columns}
      local={locale}
      T={T}
    />
  )
}
