import React from 'react'
import { reject, formatDate, formatTime } from './helper'

export default ({data}) => {
  
  const renderItem = (obj, key) => {
    if(key == 'date_of_call') {
      return <strong>{formatDate(obj[key])}</strong>
    } else if (key == 'start_datetime' || key == 'end_datetime') {
      return <strong>{formatTime(obj[key])}</strong>
    } else {
      return <strong>{obj[key]}</strong>
    }
  }

  return (
    <div className='col-sm-12 col-md-6'>
      <div className="ibox">
        <div className="ibox-title">
          <h5>About Call</h5>
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
                <tbody>
                  {
                    Object.keys(reject(data)).map((v, i) =>
                      <tr key={`${v} ${i}`}>
                        <td className="spacing-first-col">
                          {v}
                        </td>
                        <td>
                          {renderItem(data, v)}
                        </td>
                      </tr>
                    )
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
