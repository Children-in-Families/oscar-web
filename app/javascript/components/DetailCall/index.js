import React, { useEffect, useState } from 'react'
import { reject, formatDate, formatTime } from './helper'
import Referee from './_referee'
import Call from './_call'

export default ({data: {call, referee}}) => {

  return (
    <div className='row'>
      <Call 
        data={call}
      />
      <Referee 
        data={referee}
      />
    </div>
  )
}
