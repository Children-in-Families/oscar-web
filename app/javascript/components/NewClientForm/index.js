import React, { useState, useEffect } from 'react'
import objectToFormData from 'object-to-formdata'
import Loading from '../Commons/Loading'
import Modal from '../Commons/Modal'
import AdministrativeInfo from './admin'
import RefereeInfo from './refereeInfo'
import ReferralInfo from './referralInfo'
import ReferralMoreInfo from './referralMoreInfo'
import ReferralVulnerability from './referralVulnerability'
import LegalDocument from './legalDocument'
import CreateFamilyModal from './createFamilyModal'
import Address      from './address'
import MyanmarAddress   from '../Addresses/myanmarAddress'
import ThailandAddress   from '../Addresses/thailandAddress'
import LesothoAddress   from '../Addresses/lesothoAddress'
import toastr from 'toastr/toastr'

import T from 'i18n-react'
import en from '../../utils/locales/en.json'
import km from '../../utils/locales/km.json'
import my from '../../utils/locales/my.json'
import 'toastr/toastr.scss'
import './styles.scss'
import { t } from '../../utils/i18n'

const Forms = props => {
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
      current_organization,
      client: { client, user_ids, quantitative_case_ids, agency_ids, donor_ids, family_ids, national_id_files, current_family_id }, referee, referees, carer, users, birthProvinces, referralSource, referralSourceCategory, selectedCountry, internationalReferredClient,
      currentProvinces, districts, communes, villages, donors, agencies, schoolGrade, quantitativeType, quantitativeCase, ratePoor, families, clientRelationships, refereeRelationships, addressTypes, phoneOwners, refereeDistricts,
      refereeTownships, carerTownships, customId1, customId2, inlineHelpTranslation,
      refereeCommunes, refereeSubdistricts, carerSubdistricts, refereeVillages, carerDistricts, carerCommunes, carerVillages, callerRelationships, currentStates, currentTownships, subDistricts, translation, fieldsVisibility,
      brc_address, brc_islands, brc_resident_types, brc_prefered_langs, brc_presented_ids, maritalStatuses, nationalities, ethnicities, traffickingTypes
    }
  } = props

  toastr.options = {
    "closeButton": true,
    "debug": false,
    "newestOnTop": true,
    "progressBar": true,
    "positionClass": "toast-top-center",
    "preventDuplicates": false,
    "onclick": null,
    "showDuration": "300",
    "hideDuration": "1000",
    "timeOut": "5000",
    "extendedTimeOut": "1000",
    "showEasing": "swing",
    "hideEasing": "linear",
    "showMethod": "fadeIn",
    "hideMethod": "fadeOut"
  }
  const [step, setStep]               = useState(1)
  const [loading, setLoading]                           = useState(false)
  const [onSave, setOnSave]                             = useState(false)
  const [dupClientModalOpen, setDupClientModalOpen]     = useState(false)
  const [attachFamilyModal, setAttachFamilyModal]       = useState(false)

  const [dupFields, setDupFields]     = useState([])
  const [errorSteps, setErrorSteps]   = useState([])
  const [errorFields, setErrorFields] = useState([])

  const [clientData, setClientData]   = useState({ user_ids, quantitative_case_ids, agency_ids, donor_ids, family_ids, current_family_id, ...client })
  const [clientProfile, setClientProfile] = useState({})
  const [refereeData, setRefereeData] = useState(referee)
  const [refereesData, setRefereesData] = useState(referees)
  const [carerData, setCarerData]     = useState(carer)

  const address = { currentDistricts: districts, currentCommunes: communes, currentVillages: villages, currentProvinces, subDistricts, currentStates, currentTownships, current_organization, addressTypes, T }
  const adminTabData = { users, client: clientData, errorFields, T }
  const refereeTabData = { errorFields, client: clientData, referee: refereeData, referees: refereesData, referralSourceCategory, referralSource, refereeDistricts, refereeCommunes, refereeVillages, currentProvinces, refereeTownships, currentStates, refereeSubdistricts, addressTypes, T, translation, current_organization }
  const referralTabData = { errorFields, client: clientData, referee: refereeData, birthProvinces, phoneOwners, callerRelationships, ...address, T, translation, current_organization, brc_address, brc_islands, brc_presented_ids, brc_resident_types, brc_prefered_langs, maritalStatuses, nationalities, ethnicities, traffickingTypes }
  const moreReferralTabData = { errorFields, ratePoor, carer: carerData, schoolGrade, donors, agencies, families, clientRelationships, carerDistricts, carerCommunes, carerVillages, currentStates, currentTownships, carerSubdistricts, ...referralTabData, T, customId1, customId2 }
  const referralVulnerabilityTabData = { client: clientData, quantitativeType, quantitativeCase, T }
  const legalDocument = { client: clientData, T }

  const tabs = [
    {text: T.translate("index.referee_info"), step: 1},
    {text: t(translation, 'clients.form.referral_info'), step: 2},
    {text: T.translate("index.referral_more_info"), step: 3},
    {text: T.translate("index.referral_vulnerability"), step: 4},
    {text: t(translation, 'clients.form.legal_documents'), step: 5}
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
    const inputType = ['date', 'select', 'checkbox', 'radio', 'file']
    const value = inputType.includes(event.type) ? event.data : event.target.value

    // console.log(value);

    if (typeof field !== 'object')
      field = { [field]: value }

    switch (obj) {
      case 'client':
        setClientData({...clientData, ...field})
        break;
      case 'clientProfile':
        setClientProfile({ profile: field})
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
      { step: 4, data: clientData, fields: clientData.status != 'Exited' ? ['received_by_id', 'initial_referral_date', 'user_ids'] : ['received_by_id', 'initial_referral_date'] },
      { step: 5, data: clientData, fields: [] }
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

      $('.alert').hide();
      $('#save-btn-help-text').hide()
      $(`#step-${goingToStep}`).show();
      if (goingToStep === (fieldsVisibility.show_legal_doc == true ? 5 : 4))
        $('#save-btn-help-text').show()
  }

  const buttonNext = () => {
    if (handleValidation()) {
      if (step === 2 )
        checkClientExist()(() => setStep(step + 1))
      else
        setStep(step + 1)

      $('.alert').hide();
      $(`#step-${step + 1}`).show();
      $('#save-btn-help-text').hide()
      if ((step + 1) === (fieldsVisibility.show_legal_doc == true ? 5 : 4))
        $('#save-btn-help-text').show()
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
      <div>
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
      </div>
    )
  }

  const renderModalFooter = () => {
    return (
      <div>
        <p>{T.translate("index.duplicate_message")}</p>
        <div style={{display:'flex', justifyContent: 'flex-end'}}>
          <button style={{margin: 5}} className='btn btn-primary' onClick={() => (setDupClientModalOpen(false), setStep(step + 1))}>{T.translate("index.continue")}</button>
          <button style={{margin: 5}} className='btn btn-default' onClick={() => setDupClientModalOpen(false)}>{T.translate("index.cancel")}</button>
        </div>
      </div>
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

  const handleSave = () => (callback, forceSave) => {
    forceSave = forceSave === undefined ? false : forceSave

    if (handleValidation()) {
      handleCheckValue(refereeData)
      handleCheckValue(clientData)
      handleCheckValue(carerData)

      if (clientData.current_family_id === null && forceSave === false)
        setAttachFamilyModal(true)
      else {
        setOnSave(true)
        const action = clientData.id ? 'PUT' : 'POST'
        const message = clientData.id ? T.translate("index.successfully_updated") : T.translate("index.successfully_created")
        const url = clientData.id ? `/api/clients/${clientData.id}` : '/api/clients'

        let formData = new FormData()
        formData = objectToFormData({ ...clientData, ...clientProfile }, {}, formData, 'client')
        formData = objectToFormData(refereeData, {}, formData, 'referee')
        formData = objectToFormData(carerData, {}, formData, 'carer')

        $.ajax({
          url,
          type: action,
          data: formData,
          processData: false,
          contentType: false,
          beforeSend: () => { setLoading(true), setAttachFamilyModal(false) }
        }).done(response => {
          if(callback)
            callback(response)
          else
            document.location.href = `/clients/${response.slug}?notice=` + message
        }).fail(error => {
          setLoading(false)
          setOnSave(false)

          if (error.statusText == "Request Entity Too Large") {
            alert("Your data is too large, try upload your attachments part by part.");
          } else {
            let errorMessage = ''
            const errorFields = JSON.parse(error.responseText)

            setErrorFields(Object.keys(errorFields))
            if(errorFields.kid_id)
              setErrorSteps([3])

            for (const errorKey in errorFields) {
              errorMessage = `${errorKey.toLowerCase().split("_").join(" ").toUpperCase()} ${errorFields[errorKey].join(" ")}`
              toastr.error(errorMessage)
            }
          }
        })
      }
    }
  }

  const handleCancel = () => {
    window.history.back()
  }

  const buttonPrevious = () => {
    setStep(step - 1)
    $('.alert').hide();
    $(`#step-${step - 1}`).show();
    $('#save-btn-help-text').hide()
  }

  const renderAddressSwitch = (objectData, objectKey, disabled) => {
    const country_name = current_organization.country
    switch (country_name) {
      case 'myanmar':
        return <MyanmarAddress disabled={disabled} outside={objectData.outside || false} onChange={onChange} data={{addressTypes, currentStates, currentTownships, refereeTownships, carerTownships, objectKey, objectData, T}} />
        break;
      case 'thailand':
        return <ThailandAddress disabled={disabled} outside={objectData.outside || false} onChange={onChange} data={{addressTypes, currentDistricts: districts, currentProvinces, subDistricts, refereeDistricts, refereeSubdistricts, carerDistricts, carerSubdistricts, objectKey, objectData, T}} />
        break;
      case 'lesotho':
        return <LesothoAddress disabled={disabled} outside={objectData.outside || false} onChange={onChange} data={{addressTypes, objectKey, objectData, T}} />
        break;
      default:
        if(objectKey == 'referee'){
          return <Address
                  hintText={inlineHelpTranslation}
                  disabled={disabled}
                  outside={objectData.outside || false}
                  onChange={onChange}
                  current_organization={current_organization}
                  data={{
                    addressTypes,
                    currentDistricts: refereeDistricts,
                    currentCommunes: refereeCommunes,
                    currentVillages: refereeVillages,
                    currentProvinces,
                    objectKey,
                    objectData,
                    T
                  }}
                />
        }
        if(objectKey == 'carer'){
          return <Address hintText={inlineHelpTranslation} disabled={disabled} outside={objectData.outside || false} onChange={onChange} current_organization={current_organization} data={{addressTypes, currentDistricts: carerDistricts, currentCommunes: carerCommunes, currentVillages: carerVillages, currentProvinces, objectKey, objectData, T}} />
        } else{
          return <Address hintText={inlineHelpTranslation} disabled={disabled} outside={objectData.outside || false} onChange={onChange} current_organization={current_organization} data={{addressTypes, currentDistricts: districts, currentCommunes: communes, currentVillages: villages, currentProvinces, objectKey, objectData, T}} />
        }

    }
  }

  return (
    <div className='containerClass'>
      <Loading loading={loading} text={T.translate("index.wait")}/>

      <Modal
        className="p-md"
        title={T.translate("index.warning")}
        isOpen={dupClientModalOpen}
        type='warning'
        closeAction={() => setDupClientModalOpen(false)}
        content={ renderModalContent(dupFields) }
        footer={ renderModalFooter() }
      />

      <Modal
        title={T.translate("index.client_confirm")}
        isOpen={attachFamilyModal}
        type='success'
        closeAction={() => setAttachFamilyModal(false)}
        content={<CreateFamilyModal id="myModal" data={{ families, clientData, T }} onChange={onChange} onSave={handleSave} /> }
      />

      <div className='tabHead'>
        {
          tabs.slice(0, (fieldsVisibility.show_legal_doc == true ? 5 : 4)).map((tab, index) => renderTab(tab, index))
        }
      </div>

      <div className='contentWrapper'>
        <div className='leftComponent'>
          <AdministrativeInfo data={adminTabData} onChange={onChange} fieldsVisibility={fieldsVisibility} translation={translation} hintText={inlineHelpTranslation}/>
        </div>

        <div className='rightComponent'>
          <div style={{display: step === 1 ? 'block' : 'none'}}>
            <RefereeInfo current_organization={current_organization} data={refereeTabData} onChange={onChange} renderAddressSwitch={renderAddressSwitch} translation={translation} fieldsVisibility={fieldsVisibility} hintText={inlineHelpTranslation}/>
          </div>

          <div style={{display: step === 2 ? 'block' : 'none'}}>
            <ReferralInfo data={referralTabData} onChange={onChange} renderAddressSwitch={renderAddressSwitch} translation={translation} fieldsVisibility={fieldsVisibility} hintText={inlineHelpTranslation}/>
          </div>

          <div style={{ display: step === 3 ? 'block' : 'none' }}>
            <ReferralMoreInfo translation={translation} renderAddressSwitch={renderAddressSwitch} fieldsVisibility={fieldsVisibility} current_organization={current_organization} data={moreReferralTabData} onChange={onChange} hintText={inlineHelpTranslation} />
          </div>

          <div style={{ display: step === 4 ? 'block' : 'none' }}>
            <ReferralVulnerability data={referralVulnerabilityTabData} translation={translation} fieldsVisibility={fieldsVisibility} onChange={onChange} hintText={inlineHelpTranslation} />
          </div>

          {
            fieldsVisibility.show_legal_doc == true &&
            <div style={{ display: step === 5 ? 'block' : 'none' }}>
              <LegalDocument data={legalDocument} translation={translation} fieldsVisibility={fieldsVisibility} onChange={onChange} />
            </div>
          }
        </div>
      </div>

      <div className='actionfooter'>
        <div className='leftWrapper'>
          <span className='btn btn-default' onClick={handleCancel}>{T.translate("index.cancel")}</span>
        </div>

        <div className='rightWrapper'>
          <span className={step === 1 && 'clientButton preventButton' || 'clientButton allowButton'} onClick={buttonPrevious}>{T.translate("index.previous")}</span>
          { step !== (fieldsVisibility.show_legal_doc == true ? 5 : 4) && <span className={'clientButton allowButton'} onClick={buttonNext}>{T.translate("index.next")}</span> }
          <span
            id="save-btn-help-text"
            data-toggle="popover"
            role="button"
            data-html={true}
            data-placement="auto"
            data-trigger="hover"
            data-content={ inlineHelpTranslation.clients.buttons.save }
            className={onSave && errorFields.length === 0 ? 'clientButton preventButton': 'clientButton saveButton' }
            onClick={() => handleSave()()}>{T.translate("index.save")}
          </span>
        </div>
      </div>
    </div>
  )
}

export default Forms
