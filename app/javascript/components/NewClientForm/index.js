import React, { useState } from 'react'
import GettingStarted from './gettingStart'
import LivingDetails from './livingDetails'
import OtherDetails from './otherDetails'
import ReferralData from './referralData'
import './styles.scss'

const Forms = props => {
  const [step, setStep] = useState(1)
  const tabs = [
    {text: '1. Getting Started', step: 1},
    {text: '2. Living Details', step: 2},
    {text: '3. Other Details', step: 3},
    {text: '4. Specific Point-of-Referral-Data', step: 4}
  ]

  const activeClass = value => {
    return step === value ? 'active' : ''
  }

  const renderTab = data => {
    return (
      <span
        onClick={() => setStep(data.step)}
        className={`tabButton ${activeClass(data.step)}`}
      >
        {data.text}
      </span>
    )
  }

  return (
    <div className='container'>
      <div className='tabHead'>
        { tabs.map(tab => renderTab(tab)) }
      </div>

      <GettingStarted step={step} />
      <LivingDetails step={step} />
      <OtherDetails step={step} />
      <ReferralData step={step} />
    </div>
  )
}

export default Forms
