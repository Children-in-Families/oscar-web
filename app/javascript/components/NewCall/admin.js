import React from 'react'
import {
  SelectInput,
  TextInput,
  RadioGroup,
  DateInput,
  DateTimePicker,
  Checkbox
} from '../Commons/inputs'

export default props => {
  const { onChange, data: { users, call, errorFields, errorObjects, T, step } } = props
  const userLists = users.map(user => ({label: user[0], value: user[1], isFixed: user[2] === 'locked' ? true : false }))

  const callTypes = [
    { label: T.translate("newCall.admin.calltypes.new_referral_case"), value: "New Referral: Case Action Required" },
    { label: T.translate("newCall.admin.calltypes.new_referral_notifier"), value: "New Referral: Case Action NOT Required" },
    { label: T.translate("newCall.admin.calltypes.providing_update"), value: "Providing Update" },
    { label: T.translate("newCall.admin.calltypes.phone_conseling"), value: "Phone Counselling" },
    { label: T.translate("newCall.admin.calltypes.seeking_information"), value: "Seeking Information" },
    { label: T.translate("newCall.admin.calltypes.spam_call"), value: "Spam Call" },
    { label: T.translate("newCall.admin.calltypes.wrong_number"), value: "Wrong Number" }
  ];


  const callTypeList = callTypes.map(type => (
    { label: type.label, value: type.value, isFixed: false }
  ));

  const onCallTypeChanged = data => {
    const type = data.data;
    let requestedUpdate = call.requested_update;
    if (
      type === "Seeking Information" ||
      type === "Spam Call" ||
      type === "Wrong Number"
    ) {
      requestedUpdate = false;
    }
    const callFields = { requested_update: requestedUpdate, call_type: type };
    onChange("call", { ...callFields })({ type: "radio" });
  };

  return (
    <>
      <legend className='legend'>
        <div className="row">
          <div className="col-md-12 col-lg-9">
            <p>{T.translate("newCall.admin.call_information")}</p>
          </div>
        </div>
      </legend>

      <div className='row'>
        <div className='col-md-12 col-lg-9'>
          <SelectInput
            T={T}
            required
            isError={errorFields.includes('receiving_staff_id')}
            label={T.translate("newCall.admin.receiving_staff")}
            options={userLists}
            value={call.receiving_staff_id}
            onChange={onChange('call', 'receiving_staff_id')}
          />
        </div>
      </div>

      <div className='row'>
        <div className='col-md-12 col-lg-9'>
          <Checkbox
            label={T.translate("newCall.admin.not_a_phone_call")}
            checked={call.not_a_phone_call || false}
            onChange={onChange('call', 'not_a_phone_call')}
          />
        </div>
      </div>
      <br/>


      <div className='row'>
        <div className='col-md-12 col-lg-9'>
          {/* <DateInput
            T={T}
            required
            isError={errorFields.includes('date_of_call')}
            getCurrentDate
            label={T.translate("newCall.admin.date_of_call")}
            onChange={onChange('call', 'date_of_call')}
            value={call.date_of_call}
          /> */}
          <TextInput
            T={T}
            type="date"
            required
            isError={errorFields.includes('date_of_call')}
            label={T.translate("newCall.admin.date_of_call")}
            onChange={onChange('call', 'date_of_call')}
            value={call.date_of_call}
          />
        </div>
      </div>

      <div className='row'>
        <div className='col-md-12 col-lg-9'>
          {/* <DateTimePicker
            T={T}
            isError={errorFields.includes('start_datetime')}
            label="Time Call Began"
            required={true}
            onChange={onChange('call', 'start_datetime')}
            value={call.start_datetime}
          /> */}
          <TextInput
            type="time"
            T={T}
            isError={errorFields.includes('start_datetime')}
            label={T.translate("newCall.admin.time_call_began")}
            required={true}
            onChange={onChange('call', 'start_datetime')}
            value={call.start_datetime}
          />
        </div>
      </div>

      <div className='row'>
        <div className='col-md-12 col-lg-9'>
          <RadioGroup
            disabled={step > 1}
            T={T}
            required
            isError={errorFields.includes('call_type')}
            label={T.translate("newCall.admin.call_type")}
            options={callTypeList}
            value={call.call_type}
            onChange={onCallTypeChanged} />
        </div>
      </div>
    </>
  )
}
