import React from 'react'
import { setDefaultLanguage } from './helper'
import Referee from './_referee'
import Call from './_call'
import ListClient from './_list-client'

export default ({data: {call, referee, clients, hidden, locale}}) => {

  let T = setDefaultLanguage(locale)

  return (
    <div className='row'>
      <div className='col-sm-12'>
        <Call
          data={call}
          locale={locale}
          T={T}
        />
      </div>
      <div className='col-sm-12'>
        <Referee
          data={referee}
          call={call}
          locale={locale}
          T={T}
        />
      </div>
      <div className={`col-sm-12 ${ hidden ? 'hidden' : '' }`}>
        <ListClient
          columns={['full_name', 'gender']}
          data={clients}
          locale={locale}
          T={T}
        />
      </div>
    </div>
  )
}
