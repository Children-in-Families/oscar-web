import React, { useState } from "react";
import { t } from "../../utils/i18n";
import { TextInput, SelectInput, DateInput } from "../Commons/inputs";

export default (props) => {
  const {
    onChange,
    translation,
    fieldsVisibility,
    hintText,
    data: { users, client, errorFields, T },
  } = props;
  const userLists = users.map((user) => ({
    label: user[0],
    value: user[1],
    isFixed: user[2] === "locked" ? true : false,
  }));

  return (
    <>
      <legend className="legend">
        <div className="row">
          <div className="col-md-12 col-lg-9">
            <p>{T.translate("admin.admin_information")}</p>
          </div>
        </div>
      </legend>

      <div className="row">
        <div className="col-md-12 col-lg-9">
          <b>DADOU</b>
          <SelectInput
            T={T}
            required
            isError={errorFields.includes("received_by_id")}
            label={T.translate("admin.receiving_staff")}
            options={userLists}
            value={client.received_by_id}
            onChange={onChange("client", "received_by_id")}
            inlineClassName="admin-receiving-staff"
            hintText={hintText.admin.admin_receiving_staff}
          />
        </div>
      </div>

      <div className="row">
        <div className="col-md-12 col-lg-9">
          <DateInput
            T={T}
            required
            isError={errorFields.includes("initial_referral_date")}
            label={t(translation, "clients.form.initial_referral_date")}
            value={client.initial_referral_date}
            onChange={onChange("client", "initial_referral_date")}
            inlineClassName="admin-referral-date"
            hintText={hintText.admin.admin_referral_date}
          />
        </div>
      </div>

      <div className="row">
        <div className="col-md-12 col-lg-9">
          <SelectInput
            T={T}
            required={client.status != "Exited" ? true : false}
            isDisabled={client.status == "Exited"}
            isError={
              errorFields.includes("user_ids") && client.status != "Exited"
            }
            label={t(translation, "clients.form.user_ids")}
            isMulti
            options={userLists}
            value={client.user_ids}
            onChange={onChange("client", "user_ids")}
            inlineClassName="case-worker"
            hintText={hintText.admin.case_worker}
          />
        </div>
      </div>

      <div className="row">
        <div className="col-md-12 col-lg-9">
          <SelectInput
            label={t(translation, "clients.form.followed_up_by_id")}
            options={userLists}
            onChange={onChange("client", "followed_up_by_id")}
            value={client.followed_up_by_id}
            inlineClassName="first-follow-by"
            hintText={hintText.admin.first_follow_by}
          />
        </div>
      </div>

      <div className="row">
        <div className="col-md-12 col-lg-9">
          <DateInput
            label={t(translation, "clients.form.follow_up_date")}
            onChange={onChange("client", "follow_up_date")}
            value={client.follow_up_date}
            inlineClassName="first-follow-date"
            hintText={hintText.admin.first_follow_date}
          />
        </div>
      </div>

      <div className="row">
        {fieldsVisibility.department == true && (
          <div className="col-md-12 col-lg-9">
            <TextInput
              label={t(translation, "clients.form.department")}
              onChange={onChange("client", "department")}
              value={client.department}
            />
          </div>
        )}
      </div>
    </>
  );
};
