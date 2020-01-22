import React, { useState, useEffect } from 'react'
import { SelectInput, TextInput, Checkbox, RadioGroup } from "../Commons/inputs";
import { setDefaultLanguage } from './helper'
import Address from "../NewCall/address"
// import TaskModal from "../NewCall/addTaskModal"

export default props => {

  const {
    data: {
      call,
      refereeDistricts,
      refereeCommunes,
      refereeVillages,
      referee,
      referees,
      client,
      currentProvinces,
      referralSourceCategory,
      referralSource,
      addressTypes
    }
  } = props;

  let T = setDefaultLanguage()

  const [errorFields, setErrorFields] = useState([])
  const [refereeData, setRefereeData] = useState(referee)
  const [loading, setLoading] = useState(false)

  const answeredCallOpts = [
    { label: T.translate("newCall.refereeInfo.answeredCallOpts.call_answered"), value: true },
    { label: T.translate("newCall.refereeInfo.answeredCallOpts.return_missed_call"), value: false }
  ];

  const calledBeforeOpts = [
    { label: T.translate("newCall.refereeInfo.calledBeforeOpts.yes"), value: true },
    { label: T.translate("newCall.refereeInfo.calledBeforeOpts.no"), value: false }
  ];

  const genderLists = [
    { label: T.translate("newCall.refereeInfo.genderLists.female"), value: "female" },
    { label: T.translate("newCall.refereeInfo.genderLists.male"), value: "male" },
    { label: T.translate("newCall.refereeInfo.genderLists.other"), value: "other" },
    { label: T.translate("newCall.refereeInfo.genderLists.unknown"), value: "unknown" }
  ];

  const ageOpts = [
    { label: T.translate("newCall.refereeInfo.ageOpts.18_plus"), value: true },
    { label: T.translate("newCall.refereeInfo.ageOpts.under_18"), value: false }
  ];

  const referralSourceCategoryLists = referralSourceCategory.map(category => ({
    label: category[0],
    value: category[1]
  }));

  const referralSourceLists = referralSource
    .filter(
      source =>
        source.ancestry !== null &&
        source.ancestry == client.referral_source_category_id
    )
    .map(source => ({ label: source.name, value: source.id }));


  const refereeLists = () => {
    let newList = []
    referees.forEach(r => newList.push({ label: `${r.name} ${r.phone} ${r.email}`, value: r.id }))
    return newList
  }

  const renderNameField = () => {
    if(refereeData.called_before) {
      return (
        <SelectInput
          T={T}
          label="Name"
          required
          isDisabled={refereeData.anonymous}
          options={refereeLists()}
          onChange={onRefereeNameChange}
          isError={errorFields.includes("name")}
          value={refereeData.id}
        />
      )
    } else {
      return (
        <TextInput
          T={T}
          required
          disabled={refereeData.anonymous}
          isError={errorFields.includes("name")}
          value={refereeData.name}
          label="Name"
          onChange={(value) => { onChange('referee', 'name')(value); onChange('client', 'name_of_referee')(value) }}
        />
      )
    }
  }

  const onRefereeNameChange = evt => {
    let {email, id, name, gender, phone, province_id, district_id, commune_id, village_id, street_number, house_number, address_type, current_address} = referees.filter(r => r.id == evt.data)[0] || {}
    onChange("referee", {
      id,
      name,
      email,
      gender,
      phone,
      province_id,
      district_id,
      commune_id,
      village_id,
      street_number,
      house_number,
      address_type,
      current_address
    })({ type: "select" });
  }

  const onReferralSourceCategoryChange = data => {
    onChange("client", {
      referral_source_category_id: data.data,
      referral_source_id: null
    })({ type: "select" });
  };

  const handleSave = () => {
    if(handleValidation()) {
      $.ajax({
        url: `/api/v1/calls/${call.id}/edit/referee`,
        type: 'PUT',
        data: {
          referee: { ...refereeData }
        },
        beforeSend: (req) => {
          setLoading(true)
        }
      })
      .success(response => {
        const clientUrls = response.client_urls;
        const message = T.translate("newCall.index.message.call_has_been_updated")

        document.location.href = `/calls/${response.call.id}?notice=${message}`
        if (clientUrls) {
          clientUrls.forEach(url => {
            window.open(`${url}?notice=${message}`, '_blank');
          });
        }
      })
      .error(err => {
        console.log("err: ", err);
      })
    }
  }

  const handleValidation = () => {
    const validationFields = ['name']
    const errors = []
    
    validationFields.forEach(field => {
      if(refereeData[field].length <= 0 || refereeData[field] === null) {
        errors.push(field)
      }
    })

    if(errors.length > 0) {
      setErrorFields(errors)
      return false
    } else {
      setErrorFields([])
      return true
    }
  }

  const onChange = (obj, field) => event => {
    const inputType = ['date', 'select', 'checkbox', 'radio', 'datetime']
    const value = inputType.includes(event.type) ? event.data : event.target.value
    
    if (typeof field !== 'object')
      field = { [field]: value }

    switch (obj) {
      case 'referee':
        setRefereeData({...refereeData, ...field })
        break;
    }
  }

  return (
      <div className="containerClass">
      {/* <TaskModal data={{referee, clientTask}} onChange={onChange} /> */}

      <legend>
        <div className="row">
          <div className="col-xs-12 col-md-6 col-lg-3">
            <p>{T.translate("newCall.refereeInfo.caller_info")}</p>
          </div>
        </div>
      </legend>

      <div className="row">
        <div className="col-xs-12">
          {/* todo: add required */}
          <RadioGroup
            inline
            required
            isError={errorFields.includes("answered_call")}
            onChange={onChange("referee", "answered_call")}
            options={answeredCallOpts}
            label={T.translate("newCall.refereeInfo.did_you_answer_the_call")}
            value={refereeData.answered_call}
          />
        </div>
      </div>

      <div className="row">
        <div className="col-xs-12">
          {/* todo: add required */}
          <RadioGroup
            inline
            required
            isError={errorFields.includes("called_before")}
            label={T.translate("newCall.refereeInfo.have_you_called")}
            options={calledBeforeOpts}
            onChange={onChange("referee", "called_before")}
            value={refereeData.called_before}
          />
        </div>
      </div>

      <div className="row">
        <div className="col-xs-12 col-sm-6 col-md-3">
          <Checkbox
            label={T.translate("newCall.refereeInfo.anonymous_referee")}
            checked={refereeData.anonymous || false}
            onChange={onChange("referee", "anonymous")}
          />
        </div>
      </div>

      <br />

      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          {renderNameField()}
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            T={T}
            label={T.translate("newCall.refereeInfo.gender")}
            isDisabled={refereeData.anonymous}
            options={genderLists}
            onChange={onChange("referee", "gender")}
            value={refereeData.gender}
          />
        </div>
        <div className="col-xs-12 col-md-6">
          <RadioGroup
            inline
            label={T.translate("newCall.refereeInfo.are_you_over_18")}
            isDisabled={refereeData.anonymous}
            options={ageOpts}
            onChange={onChange("referee", "adult")}
            value={refereeData.adult}
          />
        </div>
      </div>
      
      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            T={T}
            label={T.translate("newCall.refereeInfo.referee_phone")}
            type="number"
            disabled={refereeData.anonymous}
            onChange={onChange("referee", "phone")}
            value={refereeData.phone}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            T={T}
            label={T.translate("newCall.refereeInfo.referee_email")}
            disabled={refereeData.anonymous}
            onChange={onChange("referee", "email")}
            value={refereeData.email}
          />
        </div>
      </div>

      <legend>
        <div className="row">
          <div className="col-xs-12 col-md-6 col-lg-3">
            <p>{T.translate("newCall.refereeInfo.address")}</p>
          </div>
          {!refereeData.anonymous && (
            <div className="col-xs-12 col-md-6 col-lg-3">
              <Checkbox
                label={T.translate("newCall.refereeInfo.outside_cambodia")}
                checked={refereeData.outside || false}
                onChange={onChange("referee", "outside")}
              />
            </div>
          )}
        </div>
      </legend>

      <Address
        disabled={false}
        outside={refereeData.outside || false}
        onChange={onChange}
        data={{
          currentDistricts: refereeDistricts,
          currentCommunes: refereeCommunes,
          currentVillages: refereeVillages,
          currentProvinces,
          addressTypes,
          objectKey: "referee",
          objectData: refereeData,
          T
        }}
      />

      <div className="row">
        <div className="col-xs-12">
          <Checkbox
            disabled={true}
            label={T.translate("newCall.refereeInfo.this_caller_has_requested")}
            checked={refereeData.requested_update || false}
            onChange={onChange("referee", "requested_update")}
          />
        </div>
      </div>

      <div className='row'>
        <div className='col-sm-12'>
          <span className='btn btn-success btn-block' onClick={handleSave}>{T.translate("newCall.index.save")}</span>
        </div>
      </div>

      <br />

      <div className='row'>
        <div className='col-sm-12'>
          <span className='btn btn-default btn-block' onClick={() => {}}>{T.translate("newCall.index.cancel")}</span>
        </div>
      </div>

    </div>
  
  )
}
