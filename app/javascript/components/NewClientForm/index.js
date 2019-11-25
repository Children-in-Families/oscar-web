import React, { useState } from 'react'
import AdministrativeInfo from './admin'
import RefereeInfo from './refereeInfo'
import ReferralInfo from './referralInfo'
import ReferralMoreInfo from './referralMoreInfo'
import ReferralVulnerability from './referralVulnerability'
import './styles.scss'

const Forms = props => {
  const {
    data: {
      client, users, birthProvinces, referralSource, referralSourceCategory, selectedCountry, internationalReferredClient,
      currentProvinces, district, commune, village, donors, agencies, schoolGrade, quantitativeType, quantitativeCase
    }
  } = props

  const referee = {
    id: null,
    referee_name: '',
    referee_referral_source_catgeory_id: null
  }

  const [errorFields, seterrorFields] = useState([])
  const [step, setStep] = useState(1)
  const [clientData, setClientData] = useState(client)
  const [refereeData, setrefereeData] = useState(referee)

  const gettingStartData = { client, users, birthProvinces, referralSourceCategory, referralSource, selectedCountry,
                            internationalReferredClient, currentProvinces, district, commune, village, errorFields,
                            donors, agencies, schoolGrade, quantitativeType, quantitativeCase
                          }

  const tabs = [
    {text: 'Referee Information', step: 1},
    {text: 'Client / Referral Information', step: 2},
    {text: 'Client / Referral - More Information', step: 3},
    {text: 'Client / Referral - Vulnerability Information and Referral Note', step: 4}
  ]

  const activeClass = value => step === value ? 'active' : ''

  const renderTab = (data, index) => {
    return (
      <span
        key={index}
        onClick={() => handleTab(data.step)}
        className={`tabButton ${activeClass(data.step)}`}
      >
        {data.text}
      </span>
    )
  }

  const onChange = (obj, field) => event => {
    const value = (typeof event === 'object' && !Array.isArray(event) && event !== null) ?  event.target.value : event

    if (typeof field !== 'object')
      field = { [field]: value }

    switch (obj) {
      case 'client':
        setClientData({...clientData, ...field})
        break;
      case 'referee':
        setrefereeData({...refereeData, ...field })
        break;
    }
  }

  const handleTab = value => {
    const components = [
      { step: 1, data: refereeData, fields: ['referee_name', 'referee_referral_source_catgeory_id'] },
      { step: 2, data: clientData, fields: ['gender'] },
      { step: 3, data: clientData, fields: [] },
      { step: 4, data: clientData, fields: [] }
    ]

    components.forEach(component => {
      if (step === component.step) {
        const errors = []
        component.fields.forEach(field => {
          component.data[field] == '' && errors.push(field)
          component.data[field] === null && errors.push(field)
        })
        if (errors.length > 0) {
          seterrorFields(errors)
        } else {
          seterrorFields([])
          setStep(value)
        }
      }
    })
  }

  const buttonNext = () => {
    const components = [
      { step: 1, data: refereeData, fields: ['referee_name', 'referee_referral_source_catgeory_id'] },
      { step: 2, data: clientData, fields: ['gender']},
      { step: 3, data: clientData, fields: [] },
      { step: 4, data: clientData, fields: [] }
    ]

    components.forEach(component => {
      if (step === component.step) {
        const errors = []
        component.fields.forEach(field => {
          component.data[field] == '' && errors.push(field)
          component.data[field] === null && errors.push(field)
        })
        if (errors.length > 0) {
          seterrorFields(errors)
        } else {
          seterrorFields([])
          setStep(step + 1)
        }
      }
    })
  }

  const handleSave = () => {
    const compoentFields = [
      { data: clientData, fields: ['received_by_id', 'initial_referral_date', 'user_id'] }
    ]
    const errors=[]

    compoentFields[0].fields.forEach(field => {
      compoentFields[0].data[field] == '' && errors.push(field)
      compoentFields[0].data[field] === null && errors.push(field)
    })
    if (errors.length > 0) {
      seterrorFields(errors)
    } else {
      seterrorFields([])
      alert('Yay !')
    }
  }

  const buttonPrevious = () => {
    setStep(step-1)
  }

  console.log('clientData', clientData)
  // console.log('refereeData', refereeData)

  return (
    <div className='container'>
      <div className='tabHead'>
        {tabs.map((tab, index) => renderTab(tab, index))}
      </div>

      <div className='contentWrapper'>
        <div className='leftComponent'>
          <AdministrativeInfo data={gettingStartData} onChange={onChange} />
        </div>

        <div className='rightComponent'>
          <div style={{display: step === 1 ? 'block' : 'none'}}>
            <RefereeInfo data={gettingStartData} onChange={onChange} />
          </div>

          <div style={{display: step === 2 ? 'block' : 'none'}}>
            <ReferralInfo data={gettingStartData} onChange={onChange} />
          </div>

          <div style={{ display: step === 3 ? 'block' : 'none' }}>
            <ReferralMoreInfo data={gettingStartData} onChange={onChange} />
          </div>

          <div style={{ display: step === 4 ? 'block' : 'none' }}>
            <ReferralVulnerability data={gettingStartData} onChange={onChange} />
          </div>
        </div>
      </div>

      <div className='actionfooter'>
        <div className='leftWrapper'>
          <span className='btn btn-default'>Cancel</span>
        </div>

        <div className='rightWrapper'>
          <span className={step === 1 && 'clientButton preventButton' || 'clientButton allowButton'} onClick={buttonPrevious}>Previous</span>
          { step !== 4 && <span className={'clientButton allowButton'} onClick={buttonNext}>Next</span> }
          { step === 4 && <span className='clientButton saveButton' onClick={handleSave}>Save</span> }
        </div>
      </div>
    </div>
  )
}

export default Forms
