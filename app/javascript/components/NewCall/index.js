import React, { useState, useEffect } from 'react'
import objectToFormData from 'object-to-formdata'
import Loading from '../Commons/Loading'
import Modal from '../Commons/Modal'
import CallAdministrativeInfo from './admin'
import RefereeInfo from './refereeInfo'
import ReferralInfo from './referralInfo'
import ReferralMoreInfo from './referralMoreInfo'
import CallAbout from './callAbout'
import NoClientAttachedModal from './noClientAttachedModal'
import T from 'i18n-react'
import en from '../../utils/locales/en.json';
import km from '../../utils/locales/km.json';
import my from '../../utils/locales/my.json';
import './styles.scss'
import ProvidingUpdate from './providingUpdate'

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
      call: { call, client_ids, necessity_ids, protection_concern_ids },
      client: { clients, clientTask, user_ids, quantitative_case_ids, agency_ids, donor_ids, family_ids, current_family_id },
      referee, referees, carer, users, birthProvinces, referralSource, referralSourceCategory,
      currentProvinces, districts, communes, villages, donors, agencies, necessities, protection_concerns, schoolGrade, ratePoor, families, clientRelationships, refereeRelationships, addressTypes, phoneOwners, refereeDistricts,
      refereeCommunes, refereeVillages, carerDistricts, carerCommunes, carerVillages, providingUpdateClients, local
    }
  } = props

  const [loading, setLoading] = useState(false)
  const [duplicateLoading, setDuplicateLoading] = useState(false)
  const [onSave, setOnSave] = useState(false)
  const [dupClientModalOpen, setDupClientModalOpen]     = useState(false)
  const [dupFields, setDupFields]     = useState([])
  const [errorFields, setErrorFields] = useState([])
  const [errorObjects, setErrorObjects] = useState({})
  const [errorSteps, setErrorSteps]   = useState([])
  const [step, setStep] = useState(1)
  const [clientData, setClientData] = useState(call.id && clients || [{ user_ids, quantitative_case_ids, agency_ids, donor_ids, family_ids, current_family_id, ...clients }])
  const [taskData, setTaskData] = useState(clientTask)
  const [callData, setCallData] = useState({ client_ids, necessity_ids, protection_concern_ids, ...call})
  const [refereeData, setRefereeData] = useState(referee)
  const [refereesData, setRefereesData] = useState(referees)
  const [carerData, setCarerData] = useState(carer)
  const [caseActionNotRequired, setCaseActionNotRequiredModalOpen] = useState(false)
  const [providingUpdate, setProvidingUpdateModalOpen] = useState(false)
  const [noClientAttached, setNoClientAttachedModalOpen] = useState(false)

  const address = { currentDistricts: districts, currentCommunes: communes, currentVillages: villages, currentProvinces, addressTypes, T }

  const adminTabData = { call: callData, users, errorFields, errorObjects, T, step }

  const refereeTabData = { errorFields, call: callData, clients: clientData, clientTask, referee: refereeData, referees: refereesData, referralSourceCategory, referralSource, refereeDistricts, refereeCommunes, refereeVillages, currentProvinces, addressTypes, T }
  const referralTabData = { call: callData, users, errorFields, clients: clientData, birthProvinces, ratePoor, refereeRelationships, phoneOwners, T, referee: refereeData, ...address,  }
  const moreReferralTabData = { ratePoor, carer: carerData, schoolGrade, donors, agencies, families, carerDistricts, carerCommunes, carerVillages, clientRelationships, call: callData, ...referralTabData }
  const callAboutTabData = { clients: clientData, call: callData, T, necessities, protection_concerns }

  const tabs = [
    {text: T.translate("newCall.index.tabs.caller_info"), step: 1},
    {text: T.translate("newCall.index.tabs.client_referral_info"), step: 2 },
    {text: T.translate("newCall.index.tabs.client_referral_question"), step: 3},
    {text: T.translate("newCall.index.tabs.client_referral_call"), step: 4}
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
    const inputType = ['date', 'select', 'checkbox', 'radio', 'datetime', 'newObject', 'object']
    const value = inputType.includes(event.type) ? event.data : event.target.value

    if (typeof field !== 'object')
      field = { [field]: value }

    switch (obj) {
      case 'call':
        setCallData({...callData, ...field})
        break;
      case 'client':
        if(event.type === 'newObject')
          setClientData([...clientData, {}])
        else
          setClientData(field)
        break;
      case 'referee':
        setRefereeData({...refereeData, ...field })
        break;
      case 'carer':
        setCarerData({...carerData, ...field })
        break;
      case 'task':
        setTaskData({...taskData, ...field })
        break;
    }
  }

  const handleValidation = () => {
    const counselling = callData.call_type === "Phone Counselling"
    const components = [
      { step: 1, data: refereeData, fields: ['name'] },
      { step: 1, data: clientData, fields: ['referral_source_category_id'] },
      { step: 1, data: callData, fields: ['receiving_staff_id', 'call_type', 'date_of_call', 'start_datetime', 'answered_call', 'called_before', 'childsafe_agent'] },
      { step: 2, data: clientData, fields: ['gender', 'user_ids']},
      { step: 3, data: clientData, fields: counselling ? ['phone_counselling_summary'] : [] },
      { step: 4, data: clientData, fields: [] },
      { step: 4, data: callData, fields: ['receiving_staff_id', 'call_type', 'date_of_call', 'start_datetime'] }
    ]

    const errors = []
    const errorSteps = []

    components.forEach(component => {
      if (step === component.step) {
        const isArray = Array.isArray(component.data)
        if(isArray)
          component.fields.forEach(field => {
            component.data.forEach(data => {
              if (data[field] === '' || (Array.isArray(data[field]) && !data[field].length) || data[field] === null || data[field] === undefined) {
                errors.push(field)
                errorSteps.push(component.step)
              }
            })
          })
        else
          component.fields.forEach(field => {
            // (component.data[field] === '' || (Array.isArray(component.data[field]) && !component.data[field].length) || component.data[field] === null) && errors.push(field)
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
      if(step === 1)
        checkCallType()(() => setStep(goingToStep))
      else if (step === 2 )
        checkClientExist()(() => setStep(goingToStep))
      else
        setStep(goingToStep)
  }

  const buttonNext = () => {
    if (handleValidation()) {
      if (step === 1 )
        checkCallType()(() => setStep(step + 1))
      else if (step === 2 ) {
        checkClientExist()(() => setStep(step + 1))
      }
      else
        setStep(step + 1)
    }
  }

  const checkCallType = () => callback => {
    if (callData.call_type === "New Referral: Case Action NOT Required") {
      setCaseActionNotRequiredModalOpen(true)
    } else if (callData.call_type === "Providing Update") {
      setProvidingUpdateModalOpen(true)
    } else if (callData.call_type === "Seeking Information" || callData.call_type === "Spam Call" || callData.call_type === "Wrong Number") {
      setNoClientAttachedModalOpen(true)
    } else {
      callback()
    }
  }

  const checkClientExist = () => callback => {
    const data =  {
      given_name: clientData[0].given_name ,
      family_name: clientData[0].family_name,
      local_given_name: clientData[0].local_given_name,
      local_family_name: clientData[0].local_family_name,
      date_of_birth: clientData[0].date_of_birth || '',
      birth_province_id: clientData[0].birth_province_id || '',
      current_province_id: clientData[0].province_id || '',
      district_id: clientData[0].district_id || '',
      village_id: clientData[0].village_id || '',
      commune_id: clientData[0].commune_id || ''
    }

    if(clientData[0].outside === undefined || clientData[0].outside === false) {
      if(data.given_name !== '' || data.family_name !== '' || data.local_given_name !== '' || data.local_family_name !== '' || data.date_of_birth !== '' || data.birth_province_id !== '' || data.current_province_id !== '' || data.district_id !== '' || data.village_id !== '' || data.commune_id !== '') {
        $.ajax({
          type: 'GET',
          url: '/api/clients/compare',
          data: data,
          beforeSend: () => { setDuplicateLoading(true) }
        }).success(response => {
          if(response.similar_fields.length > 0) {
            setDupFields(response.similar_fields)
            setDupClientModalOpen(true)
          } else
            callback()
          setDuplicateLoading(false)
        })
      } else
        callback()
    } else
      callback()
  }

  const handleSave = () => {
    if (handleValidation()) {
      handleCheckValue(refereeData)
      clientData.map(client => handleCheckValue(client))
      handleCheckValue(carerData)
      if(refereeData.requested_update === false)
        setTaskData({})

      setOnSave(true)
      const action = callData.id ? 'PUT' : 'POST'
      const url = callData.id ? `/api/v1/calls/${callData.id}` : '/api/v1/calls'
      const message = T.translate("newCall.index.message.call_has_been_created")

      let formData = new FormData()
      formData = objectToFormData(refereeData, {}, formData, 'referee')
      formData = objectToFormData(callData, {}, formData, 'call')
      // taskData may need to be filterd out if no client attached
      formData = objectToFormData(taskData, {}, formData, 'task')

      if (callData.call_type === "New Referral: Case Action Required" || callData.call_type === "New Referral: Case Action NOT Required" || callData.call_type === "Phone Counselling") {
        formData = objectToFormData(clientData, {}, formData, 'clients')
        formData = objectToFormData(carerData, {}, formData, 'carer')
      }

      $.ajax({
        url,
        type: action,
        data: formData,
        processData: false,
        contentType: false,
        beforeSend: () => { setLoading(true) }
      })
      .done(response => {
        if (response.client_urls && response.client_urls.length > 0) {
          response.client_urls.forEach(url => {
            window.open(`${url}?notice=${message}`, '_blank')
          })
        }
        document.location.href = `/calls/${response.call.id}?notice=${message}&locale=${local}`
      })
      .fail(error => {
        setLoading(false)
        setOnSave(false)
        const fieldErrors = JSON.parse(error.responseText)
        setErrorFields(Object.keys(fieldErrors))
        setErrorObjects(fieldErrors)
        if(fieldErrors.kid_id)
          setErrorSteps([3])
      })
    }
  }

  const renderModalContent = data => {
    return (
      <>
        <p>{T.translate("index.similar_record")}</p>
        <ul>
          {
            data.map((fields,index) => {
              let newFields = fields.split('_')
              newFields.splice(0, 1)
              return <li key={index} style={{textTransform: 'capitalize'}}>{newFields.join(' ')}</li>
            })
          }
        </ul>
        <p>{T.translate("index.checking_message")}</p>
      </>
    )
  }

  const renderModalFooter = () => {
    return (
      <>
        <p>{T.translate("index.duplicate_message")}</p>
        <div style={{display:'flex', justifyContent: 'flex-end'}}>
          <button style={{margin: 5}} className='btn btn-primary' onClick={() => (setDupClientModalOpen(false), setStep(step + 1))}>{T.translate("index.continue")}</button>
          <button style={{margin: 5}} className='btn btn-default' onClick={() => setDupClientModalOpen(false)}>{T.translate("index.cancel")}</button>
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

    if(object.concern_is_outside === undefined)
      return

    if(object.concern_is_outside) {
      object.concern_province_id = null
      object.concern_district_id = null
      object.concern_commune_id = null
      object.concern_village_id = null
      object.concern_street_number = ''
      object.concern_current_address = ''
      object.concern_address_type = ''
      object.concern_house_number = ''
    } else {
      object.concern_outside_address = ''
    }
  }

  const handleCancel = () => {
    let result = confirm("Are you sure? Yes/No");
    if(result)
      window.history.back()
  }

  const buttonPrevious = () => {
    setStep(step - 1)
  }

  const caseActionNotRequiredModalFooter = () => {
    return (
      <>
        <div style={{display:'flex', justifyContent: 'flex-end'}}>
          <button style={{margin: 5}} className='btn btn-default' onClick={() => setCaseActionNotRequiredModalOpen(false)}>{T.translate("newCall.caseActionNotRequiredModalFooter.go_back")}</button>
          <button style={{margin: 5}} className='btn btn-primary' onClick={() => (setCaseActionNotRequiredModalOpen(false), setStep(step + 1))}>{T.translate("newCall.caseActionNotRequiredModalFooter.iam_sure")}</button>
        </div>
      </>
    )
  }

  return (
    <div className='containerClass'>
      <Loading loading={loading} text={T.translate("index.wait")}/>
      <Loading loading={duplicateLoading} text={T.translate("index.duplicate_checker")} />

      <Modal
        title={T.translate("index.warning")}
        isOpen={dupClientModalOpen}
        type='warning'
        closeAction={() => setDupClientModalOpen(false)}
        content={ renderModalContent(dupFields) }
        footer={ renderModalFooter() }
      />

      <Modal
        title={T.translate("newCall.admin.confirmation")}
        isOpen={caseActionNotRequired}
        type='warning'
        closeAction={() => setCaseActionNotRequiredModalOpen(false)}
        content={T.translate("newCall.admin.verify_message")}
        footer={ caseActionNotRequiredModalFooter() }
      />
      <Modal
        title={T.translate("newCall.admin.go_to_client")}
        isOpen={providingUpdate}
        type='primary'
        closeAction={() => setProvidingUpdateModalOpen(false)}
        content={
          <ProvidingUpdate
            data={{providingUpdateClients, callData, T}}
            onChange={onChange}
            onSave={() => { setProvidingUpdateModalOpen(false); handleSave() }}
            closeAction={() => setProvidingUpdateModalOpen(false) }
          />
        }
      />
      <Modal
        title={`${T.translate("newCall.admin.save_call_as")} ${T.translate("detailCall.call." + callData.call_type)}?`}
        isOpen={noClientAttached}
        type='warning'
        closeAction={() => setNoClientAttachedModalOpen(false)}
        content={
          <NoClientAttachedModal
            data={{callData, T}}
            onChange={onChange}
            onSave={() => { setNoClientAttachedModalOpen(false); handleSave() }}
            closeAction={() => setNoClientAttachedModalOpen(false) }
          />
        }
      />

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

      <div className='actionfooter' style={{paddingTop: '15px'}}>
        <div className='leftWrapper'>
          <span className='btn btn-default' onClick={handleCancel}>{T.translate("newCall.index.cancel")}</span>
        </div>

        <div className='rightWrapper'>
          <span className={step === 1 && 'clientButton preventButton' || 'clientButton allowButton'} onClick={buttonPrevious}>{T.translate("newCall.index.previous")}</span>
          {step !== 4 && <span className={'clientButton allowButton'} onClick={buttonNext}>{T.translate("newCall.index.next")}</span> }

          {step === 4 && <span className={onSave && errorFields.length === 0 ? 'clientButton preventButton' : 'clientButton saveButton'} onClick={handleSave}>{T.translate("newCall.index.save")}</span>}
        </div>
      </div>
    </div>
  )
}

export default CallForms
