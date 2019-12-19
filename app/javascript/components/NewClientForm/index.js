import React, { useState } from 'react'
import Loading from '../Commons/Loading'
import Modal from '../Commons/Modal'
import AdministrativeInfo from './admin'
import RefereeInfo from './refereeInfo'
import ReferralInfo from './referralInfo'
import ReferralMoreInfo from './referralMoreInfo'
import ReferralVulnerability from './referralVulnerability'
import CreateFamilyModal from './createFamilyModal'
import './styles.scss'

const Forms = props => {
  const {
    data: {
      client: { client, user_ids, quantitative_case_ids, agency_ids, donor_ids, family_ids }, referee, carer, users, birthProvinces, referralSource, referralSourceCategory, selectedCountry, internationalReferredClient,
      currentProvinces, districts, communes, villages, donors, agencies, schoolGrade, quantitativeType, quantitativeCase, ratePoor, families, clientRelationships, refereeRelationships, addressTypes, phoneOwners, refereeDistricts,
      refereeCommunes, refereeVillages, carerDistricts, carerCommunes, carerVillages
    }
  } = props

  const [step, setStep]               = useState(1)
  const [loading, setLoading]                           = useState(false)
  const [onSave, setOnSave]                             = useState(false)
  const [dupClientModalOpen, setDupClientModalOpen]     = useState(false)
  const [attachFamilyModal, setAttachFamilyModal]       = useState(false)

  const [dupFields, setDupFields]     = useState([])
  const [errorSteps, setErrorSteps]   = useState([])
  const [errorFields, setErrorFields] = useState([])

  const [clientData, setClientData]   = useState({ user_ids, quantitative_case_ids, agency_ids, donor_ids, family_ids, ...client })
  const [refereeData, setRefereeData] = useState(referee)
  const [carerData, setCarerData]     = useState(carer)

  const address = { currentDistricts: districts, currentCommunes: communes, currentVillages: villages, currentProvinces, addressTypes  }
  const adminTabData = { users, client: clientData, errorFields }
  const refereeTabData = { errorFields, client: clientData, referee: refereeData, referralSourceCategory, referralSource, refereeDistricts, refereeCommunes, refereeVillages, currentProvinces, addressTypes }
  const referralTabData = { errorFields, client: clientData, referee: refereeData, birthProvinces, refereeRelationships, phoneOwners, ...address  }
  const moreReferralTabData = { ratePoor, carer: carerData, schoolGrade, donors, agencies, families, clientRelationships, carerDistricts, carerCommunes, carerVillages, ...referralTabData }
  const referralVulnerabilityTabData = { client: clientData, quantitativeType, quantitativeCase }

  const tabs = [
    {text: 'Referee Information', step: 1},
    {text: 'Client / Referral Information', step: 2},
    {text: 'Client / Referral - More Information', step: 3},
    {text: 'Client / Referral - Vulnerability Information and Referral Note', step: 4}
  ]

  const classStyle = value => errorSteps.includes(value) ? 'errorTab' : step === value ? 'activeTab' : 'normalTab'

  const renderTab = (data, index) => {
    return (
      <span
        key={index}
        onClick={() => handleTab(data.step)}
        className={`tabButton ${classStyle(data.step)}`}
      >
        {data.text}
      </span>
    )
  }

  const onChange = (obj, field) => event => {
    const inputType = ['date', 'select', 'checkbox', 'radio']
    const value = inputType.includes(event.type) ? event.data : event.target.value

    if (typeof field !== 'object')
      field = { [field]: value }

    switch (obj) {
      case 'client':
        setClientData({...clientData, ...field})
        break;
      case 'referee':
        setRefereeData({...refereeData, ...field })
        break;
      case 'carer':
        setCarerData({...carerData, ...field })
        break;
    }
  }

  const handleValidation = (stepTobeCheck = 0) => {
    const components = [
      { step: 1, data: refereeData, fields: ['name'] },
      { step: 1, data: clientData, fields: ['referral_source_category_id'] },
      { step: 2, data: clientData, fields: ['gender']},
      { step: 3, data: clientData, fields: [] },
      { step: 4, data: clientData, fields: ['received_by_id', 'initial_referral_date', 'user_ids'] }
    ]

    const errors = []
    const errorSteps = []

    components.forEach(component => {
      if (step === component.step || (stepTobeCheck !== 0 && component.step === stepTobeCheck)) {
        component.fields.forEach(field => {
          if (component.data[field] === '' || (Array.isArray(component.data[field]) && !component.data[field].length) || component.data[field] === null) {
            errors.push(field)
            errorSteps.push(component.step)
          }
        })
      }
    })

    if (errors.length > 0) {
      setErrorFields(errors)
      setErrorSteps([ ...new Set(errorSteps)])
      return false
    } else {
      setErrorFields([])
      setErrorSteps([])
      return true
    }
  }

  const handleTab = goingToStep => {
    const goBack    = goingToStep < step
    const goForward = goingToStep === step + 1
    const goOver    = goingToStep >= step + 2 || goingToStep >= step + 3

    if((goForward && handleValidation()) || (goOver && handleValidation(1) && handleValidation(2)) || goBack)
      if(step === 2)
        checkClientExist()(() => setStep(goingToStep))
      else
        setStep(goingToStep)
  }

  const buttonNext = () => {
    if (handleValidation()) {
      if (step === 2 )
        checkClientExist()(() => setStep(step + 1))
      else
        setStep(step + 1)
    }
  }

  const checkClientExist = () => callback => {
    const data =  {
      given_name: clientData.given_name ,
      family_name: clientData.family_name,
      local_given_name: clientData.local_given_name,
      local_family_name: clientData.local_family_name,
      date_of_birth: clientData.date_of_birth || '',
      birth_province_id: clientData.birth_province_id || '',
      current_province_id: clientData.province_id || '',
      district_id: clientData.district_id || '',
      village_id: clientData.village_id || '',
      commune_id: clientData.commune_id || ''
    }

    if(!clientData.id && clientData.outside === false) {
      if(data.given_name !== '' || data.family_name !== '' || data.local_given_name !== '' || data.local_family_name !== '' || data.date_of_birth !== '' || data.birth_province_id !== '' || data.current_province_id !== '' || data.district_id !== '' || data.village_id !== '' || data.commune_id !== '') {
        $.ajax({
          type: 'GET',
          url: '/api/clients/compare',
          data: data,
          beforeSend: () => { setLoading(true) }
        }).success(response => {
          if(response.similar_fields.length > 0) {
            setDupFields(response.similar_fields)
            setDupClientModalOpen(true)
          } else
            callback()
          setLoading(false)
        })
      } else
        callback()
    } else
      callback()
  }

  const renderModalContent = data => {
    return (
      <>
        <p>The client record you are saving has similarities to other records in OSCaR in the following fields:</p>
        <ul>
          {
            data.map((fields,index) => {
              let newFields = fields.split('_')
              newFields.splice(0, 1)
              return <li key={index} style={{textTransform: 'capitalize'}}>{newFields.join(' ')}</li>
            })
          }
        </ul>
        <p>Please check with the client whether they have ever worked with another organisation that may have put their details into OSCaR.</p>
      </>
    )
  }

  const renderModalFooter = () => {
    return (
      <>
        <p>Duplicate Checker feature is currently in Beta testing, please Email: info@oscarhq.com if you have any issues with excessive false positive/negative results.</p>
        <div style={{display:'flex', justifyContent: 'flex-end'}}>
          <button style={{margin: 5}} className='btn btn-primary' onClick={() => (setDupClientModalOpen(false), setStep(step + 1))}>Continue</button>
          <button style={{margin: 5}} className='btn btn-default' onClick={() => setDupClientModalOpen(false)}>Cancel</button>
        </div>
      </>
    )
  }

  const handleCheckValue = object => {
    if(object.outside) {
      object.province_id = null
      object.district_id = null
      object.commune_id = null
      object.village_id = null
      object.street_number = ''
      object.current_address = ''
      object.address_type = ''
      object.house_number = ''
    } else {
      object.outside_address = ''
    }
  }

  const handleSave = event => {
    if (handleValidation()) {
      handleCheckValue(refereeData)
      handleCheckValue(clientData)
      handleCheckValue(carerData)

      if (clientData.family_ids.length === 0)
        setAttachFamilyModal(true)
      else {
        setOnSave(true)
        const action = clientData.id ? 'PUT' : 'POST'
        const url = clientData.id ? `/api/clients/${clientData.id}` : '/api/clients'

        $.ajax({
          url,
          type: action,
          data: { client: { ...clientData }, referee: { ...refereeData }, carer: { ...carerData } },
          beforeSend: () => { setLoading(true) }
        }).success(response => {document.location.href=`/clients/${response.id}?notice=success`})
      }
    }
  }

  const handleCancel = () => {
    window.history.back()
  }

  const buttonPrevious = () => {
    setStep(step - 1)
  }

  return (
    <div className='containerClass'>
      <Loading loading={loading} text='Please wait while we are making a request to server.'/>

      <Modal
        title='Warning'
        isOpen={dupClientModalOpen}
        type='warning'
        closeAction={() => setDupClientModalOpen(false)}
        content={ renderModalContent(dupFields) }
        footer={ renderModalFooter() }
      />

      <Modal
        title='Client Confirmation'
        isOpen={attachFamilyModal}
        type='success'
        closeAction={() => setAttachFamilyModal(false)}
        content={<CreateFamilyModal id="myModal" data={{ families, clientData, refereeData, carerData }} onChange={onChange} /> }
      />

      <div className='tabHead'>
        {tabs.map((tab, index) => renderTab(tab, index))}
      </div>

      <div className='contentWrapper'>
        <div className='leftComponent'>
          <AdministrativeInfo data={adminTabData} onChange={onChange} />
        </div>

        <div className='rightComponent'>
          <div style={{display: step === 1 ? 'block' : 'none'}}>
            <RefereeInfo data={refereeTabData} onChange={onChange} />
          </div>

          <div style={{display: step === 2 ? 'block' : 'none'}}>
            <ReferralInfo data={referralTabData} onChange={onChange} />
          </div>

          <div style={{ display: step === 3 ? 'block' : 'none' }}>
            <ReferralMoreInfo data={moreReferralTabData} onChange={onChange} />
          </div>

          <div style={{ display: step === 4 ? 'block' : 'none' }}>
            <ReferralVulnerability data={referralVulnerabilityTabData} onChange={onChange} />
          </div>
        </div>
      </div>

      <div className='actionfooter'>
        <div className='leftWrapper'>
          <span className='btn btn-default' onClick={handleCancel}>Cancel</span>
        </div>

        <div className='rightWrapper'>
          <span className={step === 1 && 'clientButton preventButton' || 'clientButton allowButton'} onClick={buttonPrevious}>Previous</span>
          { step !== 4 && <span className={'clientButton allowButton'} onClick={buttonNext}>Next</span> }

          { step === 4 && <span className={onSave && errorFields.length === 0 ? 'clientButton preventButton': 'clientButton saveButton' } onClick={handleSave}>Save</span>}
        </div>
      </div>
    </div>
  )
}

export default Forms
