import React from 'react'
import { reject } from './helper'

export default ({data}) => {

  return (
    <div className='col-sm-12 col-md-6'>
      <div className="ibox">
        <div className="ibox-title">
          <h5>Referee</h5>
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
                          <strong>{data[v]}</strong>
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
