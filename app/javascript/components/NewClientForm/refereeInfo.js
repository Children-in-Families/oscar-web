import React, { useEffect }       from 'react'
import {
  SelectInput,
  TextInput,
  Checkbox
}                   from '../Commons/inputs'
import { t } from '../../utils/i18n'


export default props => {
  const { onChange, renderAddressSwitch, fieldsVisibility, translation, current_organization, hintText, data: { refereeDistricts, refereeCommunes, refereeVillages, referee, client, currentProvinces, referralSourceCategory, referralSource, errorFields, addressTypes, T} } = props

  const genderLists = [
    { label: T.translate("refereeInfo.female"), value: 'female' },
    { label: T.translate("refereeInfo.male"), value: 'male' },
    { label: T.translate("refereeInfo.other"), value: 'other' },
    { label: T.translate("refereeInfo.unknown"), value: 'unknown'}
  ]

  const referralSourceCategoryLists = referralSourceCategory.map(category => ({label: category[0], value: category[1]}))
  const referralSourceLists = referralSource.filter(source => source.ancestry !== null && source.ancestry == client.referral_source_category_id).map(source => ({label: source.name, value: source.id}))

  useEffect(() => {
    if(referee.anonymous) {
      const fields = {
        anonymous: true,
        outside: false,
        name: "Anonymous",
        phone: referee.phone,
        email: '',
        gender: '',
        street_number: '',
        house_number: '',
        current_address: '',
        outside_address: '',
        address_type: '',
        province_id: null,
        district_id: null,
        commune_id: null,
        village_id: null,
        state_id: null,
        township_id: null,
        subdistrict_id: null,
        street_line1: '',
        street_line2: '',
        plot: '',
        road: '',
        postal_code: '',
        suburb: '',
        description_house_landmark: '',
        directions: ''
      }
      onChange('referee', { ...fields })({type: 'select'})
    }
  }, [referee.anonymous])

  const onReferralSourceCategoryChange = data => {
    onChange('client', { referral_source_category_id: data.data, referral_source_id: null })({type: 'select'})
  }

  const selector1 = {
    inline_classname: "selector1"
  }

  const selector2 = {
    inline_classname: "selector2"
  }

  return (
    <div className="containerClass">
      <legend>
        <div className="row">
          <div className="col-xs-12 col-md-6 col-lg-4">
            <p>{T.translate("refereeInfo.referee_info")}</p>
          </div>
        </div>
      </legend>

      <div className="row">
        <div className="col-xs-12 col-sm-6 col-md-3">
          <Checkbox label={T.translate("refereeInfo.anonymous_referee")} checked={referee.anonymous || false} objectKey="referee" onChange={onChange('referee', 'anonymous')} />
        </div>
      </div>
      <br/>
      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            T={T}
            required
            disabled={referee.anonymous}
            isError={errorFields.includes('name')}
            value={referee.name}
            label={T.translate("refereeInfo.name")}
            onChange={(value) => { onChange('referee', 'name')(value); onChange('client', 'name_of_referee')(value) }}
            inlineClassName="referee-name"
            hintText={hintText.referee.name}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput label={T.translate("refereeInfo.gender")}
            isDisabled={referee.anonymous}
            options={genderLists}
            onChange={onChange('referee', 'gender')}
            value={referee.gender}
            inlineClassName="referee-gender"
            hintText={hintText.referee.gender}
          />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            label={T.translate("refereeInfo.referee_phone")}
            type="text" disabled={referee.anonymous}
            onChange={onChange('referee', 'phone')}
            value={referee.phone}
            hintText={hintText.referee.phone}
            />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <TextInput
            label={T.translate("refereeInfo.referee_email")}
            disabled={referee.anonymous}
            onChange={onChange('referee', 'email')}
            value={referee.email}
            hintText={hintText.referee.email}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            T={T}
            required
            isError={errorFields.includes('referral_source_category_id')}
            label={T.translate("refereeInfo.referral_source_cat")}
            options={referralSourceCategoryLists}
            value={client.referral_source_category_id}
            onChange={onReferralSourceCategoryChange}
            inlineClassName="referral-source-category"
            hintText={hintText.referee.referral_source_category}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-3">
          <SelectInput
            options={referralSourceLists}
            label={T.translate("refereeInfo.referral_source")}
            onChange={onChange('client', 'referral_source_id')}
            value={client.referral_source_id}
            inlineClassName="referral-source"
            hintText={hintText.referee.referral_source}
          />
        </div>

      </div>

      <legend>
        <div className="row">
          <div className="col-xs-12 col-md-6 col-lg-3">
            <p>{ t(translation, 'activerecord.attributes.referee.referee_address') }</p>
          </div>
          {
            !referee.anonymous &&
            <div className="col-xs-12 col-md-6 col-lg-3">
              <Checkbox label={T.translate("refereeInfo.outside_cam")} checked={referee.outside || false} onChange={onChange('referee', 'outside')} />
            </div>
          }
        </div>
      </legend>
      { renderAddressSwitch(referee, 'referee', referee.anonymous) }
    </div>
  )
}
