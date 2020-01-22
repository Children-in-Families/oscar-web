import React, { useEffect, useState } from 'react'
import { reject, formatDate, formatTime } from './helper'
import Referee from './_referee'
import Call from './_call'
import ListClient from './_list-client'

export default ({data: {call, referee, clients, hidden}}) => {

  return (
    <div className='row'>
      <div className='col-sm-12 col-md-6'>
        <Call 
          data={call}
        />
      </div>
      <div className='col-sm-12 col-md-6'>
        <Referee 
          data={referee}
          call={call}
        />
      </div>
      <div className={`col-sm-12 ${ hidden ? 'hidden' : '' }`}>
        <ListClient
          columns={['full_name', 'gender']}
          data={clients}
        />
      </div>
    </div>
  )
}
