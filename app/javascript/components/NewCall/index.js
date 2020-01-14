import React, { useState } from 'react'
import Loading from '../Commons/Loading'
import CallAdministrativeInfo from './admin'
import RefereeInfo from './refereeInfo'
import ReferralInfo from './referralInfo'
import ReferralMoreInfo from './referralMoreInfo'
import CallAbout from './callAbout'
import T from 'i18n-react'
import en from '../../utils/locales/en.json'
import km from '../../utils/locales/km.json'
import my from '../../utils/locales/my.json'
import './styles.scss'

const CallForms = props => {
  var url = window.location.href.split("&").slice(-1)[0].split("=")[1]
  switch (url) {
    case "km":
      T.setTexts(km)
      break;
    case "my":
      T.setTexts(my)
      break;
    default:
      T.setTexts(en)
      break;
  }

  const {
    data: {
      call,
      client: { client, user_ids, quantitative_case_ids, agency_ids, donor_ids, family_ids },
      referee, carer, users, birthProvinces, referralSource, referralSourceCategory,
      selectedCountry, internationalReferredClient, quantitativeType, quantitativeCase,
      currentProvinces, districts, communes, villages, donors, agencies, schoolGrade, ratePoor, families, clientRelationships, refereeRelationships, addressTypes, phoneOwners, refereeDistricts,
      refereeCommunes, refereeVillages, carerDistricts, carerCommunes, carerVillages
    }
  } = props

  const [loading, setLoading] = useState(false)
  const [onSave, setOnSave] = useState(false)
  const [errorFields, setErrorFields] = useState([])
  const [errorSteps, setErrorSteps]   = useState([])
  const [step, setStep] = useState(1)
  const [clientData, setClientData] = useState({ user_ids, quantitative_case_ids, agency_ids, donor_ids, family_ids, ...client })
  const [callData, setCallData] = useState(call) // to work for both new & edit, useState({ call | {} })
  const [refereeData, setRefereeData] = useState(referee)
  const [carerData, setCarerData] = useState(carer)

  const address = { currentDistricts: districts, currentCommunes: communes, currentVillages: villages, currentProvinces, addressTypes, T }

  // const adminTabData = { users, client: clientData, errorFields }
  const adminTabData = { call: callData, users, errorFields, T }

  const refereeTabData = { errorFields, client: clientData, referee: refereeData, referralSourceCategory, referralSource, refereeDistricts, refereeCommunes, refereeVillages, currentProvinces, addressTypes, T }

  const referralTabData = { users, errorFields, client: clientData, birthProvinces, ratePoor, ...address, refereeRelationships, phoneOwners, T  }
  const moreReferralTabData = { ratePoor, carer: carerData, schoolGrade, donors, agencies, families, carerDistricts, carerCommunes, carerVillages, clientRelationships, call: callData, ...referralTabData }
  const callAboutTabData = { client: clientData, T }

  const tabs = [
    {text: 'Caller Information', step: 1},
    {text: 'Client / Referral Information', step: 2},
    {text: 'Client / Referral - Do you want to add:', step: 3},
    {text: 'Client / Referral - Call about', step: 4}
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
    const inputType = ['date', 'select', 'checkbox', 'radio', 'datetime']
    const value = inputType.includes(event.type) ? event.data : event.target.value

    if (typeof field !== 'object')
      field = { [field]: value }

    switch (obj) {
      case 'call':
        setCallData({...callData, ...field})
        break;
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

  const handleValidation = () => {
    const components = [
      { step: 1, data: refereeData, fields: ['name', 'answered_call', 'called_before'] },
      { step: 1, data: clientData, fields: ['referral_source_category_id'] },
      { step: 1, data: callData, fields: ['phone_call_id', 'receiving_staff_id', 'call_type', 'date_of_call', 'start_datetime', 'end_datetime'] },
      { step: 2, data: clientData, fields: ['gender', 'user_ids', 'initial_referral_date']},
      { step: 3, data: clientData, fields: [] },
      { step: 4, data: clientData, fields: [] }
    ]

    const errors = []
    const errorSteps = []

    components.forEach(component => {
      if (step === component.step) {
        component.fields.forEach(field => {
          // (component.data[field] === '' || (Array.isArray(component.data[field]) && !component.data[field].length) || component.data[field] === null) && errors.push(field)
          if (component.data[field] === '' || (Array.isArray(component.data[field]) && !component.data[field].length) || component.data[field] === null) {

            errors.push(field)
            errorSteps.push(component.step)
          }
        })
      }
    })

    // if (errors.length > 0) {
    //   setErrorFields(errors)
    //   return false
    // } else {
    //   setErrorFields([])
    //   return true
    // }

    if (errors.length > 0) {
      setErrorFields(errors)
      setErrorSteps([ ...new Set(errorSteps)])
      return false
    } else {
      setErrorFields([])
      setErrorSteps([])
      return true
    }
    // return true
  }

  const handleTab = goingToStep => {
    if(goingToStep < step || handleValidation())
      setStep(goingToStep)
    if(goingToStep == 3 && step == 1 || goingToStep == 4 && step == 1 && handleValidation())
      setStep(2)
  }

  const buttonNext = () => {
    if (handleValidation())
      setStep(step + 1)
  }

  // const checkClientExist = () => callback => {
  //   const data =  {
  //     given_name: clientData.given_name ,
  //     family_name: clientData.family_name,
  //     local_given_name: clientData.local_given_name,
  //     local_family_name: clientData.local_family_name,
  //     date_of_birth: clientData.date_of_birth || '',
  //     birth_province_id: clientData.birth_province_id || '',
  //     current_province_id: clientData.province_id || '',
  //     district_id: clientData.district_id || '',
  //     village_id: clientData.village_id || '',
  //     commune_id: clientData.commune_id || ''
  //   }

  //   if(!clientData.id && clientData.outside === false) {
  //     if(data.given_name !== '' || data.family_name !== '' || data.local_given_name !== '' || data.local_family_name !== '' || data.date_of_birth !== '' || data.birth_province_id !== '' || data.current_province_id !== '' || data.district_id !== '' || data.village_id !== '' || data.commune_id !== '') {
  //       $.ajax({
  //         type: 'GET',
  //         url: '/api/clients/compare',
  //         data: data,
  //         beforeSend: () => { setLoading(true) }
  //       }).success(response => {
  //         if(response.similar_fields.length > 0) {
  //           setDupFields(response.similar_fields)
  //           setDupClientModalOpen(true)
  //         } else
  //           callback()
  //         setLoading(false)
  //       })
  //     } else
  //       callback()
  //   } else
  //     callback()
  // }

  const handleSave = event => {
    if (handleValidation()) {
      handleCheckValue(refereeData)
      handleCheckValue(clientData)
      handleCheckValue(carerData)

      // todo
      // if (clientData.family_ids.length === 0)
      if (false)
        setAttachFamilyModal(true)
      else {
        setOnSave(true)
        const action = clientData.id ? 'PUT' : 'POST'
        const url = clientData.id ? `/api/v1/calls/${clientData.id}` : '/api/v1/calls'
        const message = "Call has been successfully created"
        $.ajax({
          url,
          type: action,
          data: {
            call: { ...callData },
            client: { ...clientData },
            referee: { ...refereeData },
            carer: { ...carerData }
          },
          beforeSend: (req) => {
            setLoading(true)
          }
        })
        .success(response => {
          document.location.href = `/calls?notice=` + message
        })
        .error(err => {
          console.log("err: ", err);
        })

      }
    }
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

  const handleCancel = () => {
    window.history.back()
  }

  const buttonPrevious = () => {
    setStep(step - 1)
  }

  return (
    <div className='containerClass'>
      {/* <Loading loading={loading} text='Please wait while we are making a request to server.'/> */}

      <div className='tabHead'>
        {tabs.map((tab, index) => renderTab(tab, index))}
      </div>

      <div className='contentWrapper'>
        <div className='leftComponent'>
          <CallAdministrativeInfo data={adminTabData} onChange={onChange} />
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
            <CallAbout data={callAboutTabData} onChange={onChange} />
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

export default CallForms
