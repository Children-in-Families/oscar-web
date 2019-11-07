import React, { useState } from 'react'
import RefereeInformation from './refereeInformation'
// import LivingDetails from './livingDetail'
// import OtherDetails from './otherDetail'
// import ReferralData from './referralData'
import './styles.scss'

const Forms = props => {
  const { translations, data: {client, users, birth_provinces, referral_source, referral_source_category} } = props
  const [step, setStep] = useState(1)
  const gettingStartData = { client, users, birth_provinces, referral_source_category, referral_source }

  const tabs = [
    {text: '1. Referee Information', step: 1},
    // {text: '2. Living Details', step: 2},
    // {text: '3. Other Details', step: 3},
    // {text: '4. Specific Point-of-Referral-Data', step: 4}
  ]

  const activeClass = value => step === value ? 'active' : ''

  const renderTab = (data, index) => {
    return (
      <span
        key={index}
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
        <RefereeInformation step={step} data={gettingStartData} translations={translations} />
      </div>


      {/* <LivingDetails step={step} />
      <OtherDetails step={step} />
      <ReferralData step={step} /> */}
    </div>
  )
}

export default Forms
