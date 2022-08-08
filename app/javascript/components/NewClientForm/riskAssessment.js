import React, { useEffect, useState } from "react";
import {
  SelectInput,
  DateInput,
  TextInput,
  Checkbox,
  RadioGroup,
  FileUploadInput,
  TextArea,
} from "../Commons/inputs";
import T from 'i18n-react'
import { t } from "../../utils/i18n";

export default (props) => {
  const {
    protectionConcerns
  } = props
  const yesNoOpts = [
    { label: T.translate("newCall.refereeInfo.yes"), value: true },
    { label: T.translate("newCall.refereeInfo.no"), value: false },
  ];

  const onChange = () => {
    return
  }

  return (
    <div className="containerClass">
      <legend>
        <div className="row">
          <div className="col-xs-6">
            <p>Protection Concern</p>

          </div>
        </div>
      </legend>
      <div className="row">
        <div className="col-md-12 col-lg-5">
          <DateInput
            T={'Assessment Date'}
            isError={false}
            label={"Assessment Date"}
            value={'2022-07-20'}
            onChange={onChange("client", "")}
            />
          </div>
        </div>
      <div className="row">
        <div className="col-md-12 col-lg-6">
          <SelectInput
            isError={false}
            label={"Protection Concern"}
            asGroup
            options={[]}
            value={''}
            onChange={onChange("client", "")}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-6">
          <TextInput
            label={"If other, please specify"}
            onChange={onChange("client", "")}
            value={''}
          />
        </div>
      </div>
      <div className="row">
        <div className="col-md-12 col-lg-6">
          <SelectInput
            isError={false}
            label={"Level of Risk"}
            options={['Hight', 'Medium', 'Low', 'No Action']}
            value={''}
            onChange={onChange("client", "")}
          />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-12">
          <TextArea
            label={"Client’s perspective on their problem and needs"}
            onChange={onChange("client", "")}
            value={''}
            inlineClassName="client-perspective"
          />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-12 col-md-6">
          <RadioGroup
            inline
            label={"Does client have a known chronic disease?"}
            options={yesNoOpts}
            onChange={onChange()}
            value={false}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-6">
          <TextInput
            inline
            label={"If yes, please specify"}
            onChange={onChange("client", "")}
            value={''}
          />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-12 col-md-6">
          <RadioGroup
            inline
            label={"Does client have disability?"}
            options={yesNoOpts}
            onChange={onChange()}
            value={false}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-6">
          <TextInput
            inline
            label={"If yes, please specify"}
            onChange={onChange("client", "")}
            value={''}
          />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-12 col-md-6">
          <RadioGroup
            inline
            label={"Does client have HIV/AID?"}
            options={yesNoOpts}
            onChange={onChange()}
            value={false}
          />
        </div>
        <div className="col-xs-12 col-md-6 col-lg-6">
          <TextInput
            inline
            label={"Immediate Recommendation"}
            onChange={onChange("client", "")}
            value={''}
          />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-12">
          <SelectInput
            inline
            isError={false}
            label={"History of disability and/or illness"}
            options={[]}
            value={''}
            width={'45%'}
            onChange={onChange("client", "")}
          />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-12">
          <SelectInput
            inline
            isError={false}
            label={"History of Harm"}
            options={[]}
            value={''}
            onChange={onChange("client", "")}
          />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-12">
          <SelectInput
            inline
            isError={false}
            label={"History of high-risk behaviours"}
            options={[]}
            value={''}
            onChange={onChange("client", "")}
          />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-12">
          <SelectInput
            inline
            isError={false}
            label={"Reason for Family Separation"}
            options={[]}
            value={''}
            onChange={onChange("client", "")}
          />
        </div>
      </div>
      <div className="row">
        <div className="col-xs-12">
          <TextArea
            inline
            label={"Relevant Referral Information"}
            onChange={onChange("client", "")}
            value={''}
          />
        </div>
      </div>
    </div>
  )
}
