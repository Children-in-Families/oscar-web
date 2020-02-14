import React, { useEffect, useState } from 'react'
import { reject, isEmpty, titleize } from '../../DetailCall/helper'

export const HorizontalTable = ({ title, data, renderItem, linkHeader, disabledEdit=false, rejectField = "id|created_at|updated_at" }) => {
  let keyLists = Object.keys(reject(data, rejectField)) || []

  return (
    <div className='col-sm-12'>
      <div className="ibox">
        <div className="ibox-title">
          <h5>{title}</h5>
          <div className="ibox-tools">
            <a className={`btn btn-success btn-outline ${disabledEdit ? 'disabled' : ''}`} href={linkHeader} target="_blank">
              <i className="fa fa-pencil"></i>
            </a>
            <a className="collapse-link">
              <div className="btn btn-outline btn-primary">
                <i className="fa fa-chevron-up"></i>
              </div>
            </a>
          </div>
        </div>

        <div className="ibox-content">
          <div className="row">
            <div className="col-sm-12 first-table">
              <table className="table table-bordered">
                <tbody>
                  {

                    keyLists.map((key, i) => renderItem ? renderItem(data, key) : "")
                  }
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

export const VerticalTable = ({ title, data, renderItem, columns, T, local }) => {

  return (
    <div className='col-sm-12'>
      <div className="ibox">
        <div className="ibox-title">
          <h5>{title}</h5>
          <div className="ibox-tools">
            <a className="collapse-link">
              <div className="btn btn-outline btn-primary">
                <i className="fa fa-chevron-up"></i>
              </div>
            </a>
          </div>
        </div>

        <div className="ibox-content">
          <div className="row">
            <div className="col-sm-12 first-table">
              <table className="table table-bordered">
                <thead>
                  <tr>
                    {
                      data && data[0] && columns.map(key => <th key={key} scope="col">{T.translate("commons.listTable.index."+titleize(key))}</th>)
                    }
                    <th scope="col">{T.translate("commons.listTable.index.action")}</th>
                  </tr>
                </thead>
                <tbody>
                  {
                    data.map((obj, i) => {
                      return (
                        isEmpty(Object.values(obj)) && data.length == 1
                        ?
                          <tr key={`${i}`}>
                            <td className="spacing-first-col" colspan={Object.keys(obj).length}>
                              {T.translate("commons.listTable.index.no_client")}
                            </td>
                          </tr>
                        :
                          <tr key={`${i}`}>
                            {
                              columns.map(key => {
                                return (
                                  <td
                                    style={{cursor: 'pointer'}}
                                    key={key}
                                    className="spacing-first-col"
                                    data-href={`/clients/${obj['slug']}?locale=${local}`}
                                    onClick={(e) => {
                                      window.open(e.target.getAttribute('data-href'), "_blank")
                                    }}
                                  >
                                    {obj[key]}
                                  </td>
                                )
                              })


                            }
                            <td
                              className="spacing-first-col"
                            >
                              <a className="btn btn-xs btn-success btn-outline" href={`/clients/${obj['slug']}/edit?type=call&local=${local}`} target="_blank">
                                <i className="fa fa-pencil"></i>
                              </a>
                            </td>
                          </tr>
                      )

                    })
                  }
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
