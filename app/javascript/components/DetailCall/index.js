import React from 'react'
import { setDefaultLanguage } from './helper'
import Referee from './_referee'
import Call from './_call'
import ListClient from './_list-client'

export default ({data: {call, referee, clients, hidden}}) => {
  var url = window.location.href.split("&").slice(-1)[0].split("=")[1]

  let T = setDefaultLanguage(url)

  return (
    <div className='row'>
      <div className='col-sm-12 col-md-6'>
        <Call
          data={call}
          local={url}
          T={T}
        />
      </div>
      <div className='col-sm-12 col-md-6'>
        <Referee
          data={referee}
          call={call}
          local={url}
          T={T}
        />
      </div>
      <div className={`col-sm-12 ${ hidden ? 'hidden' : '' }`}>
        <ListClient
          columns={['full_name', 'gender']}
          data={clients}
          local={url}
          T={T}
        />
      </div>
    </div>
  )
}
