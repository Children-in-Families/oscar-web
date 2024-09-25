import { T, t, params } from "../../utils";
import React, { useState, useEffect } from "react";
import objectToFormData from "object-to-formdata";
import Loading from "../Commons/Loading";
import Modal from "../Commons/Modal";
import AdministrativeInfo from "./admin";
import RefereeInfo from "./refereeInfo";
import ReferralInfo from "./referralInfo";
import ReferralMoreInfo from "./referralMoreInfo";
import ReferralVulnerability from "./referralVulnerability";
import RiskAssessment from "./riskAssessment";
import LegalDocument from "./legalDocument";
import CreateFamilyModal from "./createFamilyModal";
import Address from "./address";
import MyanmarAddress from "../Addresses/myanmarAddress";
import ThailandAddress from "../Addresses/thailandAddress";
import LesothoAddress from "../Addresses/lesothoAddress";
import NepalAddress from "../Addresses/nepalAddress";
import IndonesianAddress from "../Addresses/IndonesianAddress";
import toastr from "toastr/toastr";
import "toastr/toastr.scss";
import "./styles.scss";

import { confirmCancel } from "../Commons/confirmCancel.js";

const Forms = (props) => {
  const {
    data: {
      current_organization,
      client: {
        client,
        user_ids,
        ratanak_achievement_program_staff_client_ids,
        quantitative_case_ids,
        agency_ids,
        donor_ids,
        family_ids,
        national_id_files,
        current_family_id,
        isTestClient,
        isForTesting,
        referral_id
      },
      client_quantitative_free_text_cases,
      family_member,
      family,
      moSAVYOfficials,
      referee,
      referees,
      carer,
      users,
      birthProvinces,
      referralSource,
      referralSourceCategory,
      selectedCountry,
      internationalReferredClient,
      currentProvinces,
      cities,
      districts,
      communes,
      villages,
      donors,
      agencies,
      schoolGrade,
      quantitativeType,
      customData,
      quantitativeCase,
      families,
      clientRelationships,
      refereeRelationships,
      addressTypes,
      phoneOwners,
      refereeCities,
      refereeDistricts,
      clientCustomFields,
      refereeTownships,
      carerTownships,
      customId1,
      customId2,
      inlineHelpTranslation,
      riskAssessment,
      ratePoor,
      refereeCommunes,
      refereeSubdistricts,
      carerSubdistricts,
      refereeVillages,
      carerCities,
      carerDistricts,
      carerCommunes,
      carerVillages,
      callerRelationships,
      currentStates,
      currentTownships,
      subDistricts,
      translation,
      fieldsVisibility,
      requiredFields,
      brc_address,
      brc_islands,
      brc_resident_types,
      brc_prefered_langs,
      brc_presented_ids,
      maritalStatuses,
      nationalities,
      ethnicities,
      traffickingTypes,
      protectionConcerns,
      historyOfHarms,
      historyOfHighRiskBehaviours,
      reasonForFamilySeparations,
      historyOfDisabilities,
      isRiskAssessmentEnabled
    }
  } = props;

  toastr.options = {
    closeButton: true,
    debug: false,
    newestOnTop: true,
    progressBar: true,
    positionClass: "toast-top-center",
    preventDuplicates: false,
    onclick: null,
    showDuration: "300",
    hideDuration: "1000",
    timeOut: "5000",
    extendedTimeOut: "1000",
    showEasing: "swing",
    hideEasing: "linear",
    showMethod: "fadeIn",
    hideMethod: "fadeOut"
  };
  const [step, setStep] = useState(1);
  const [loading, setLoading] = useState(false);
  const [onSave, setOnSave] = useState(false);
  const [dupClientModalOpen, setDupClientModalOpen] = useState(false);
  const [attachFamilyModal, setAttachFamilyModal] = useState(false);

  const [dupFields, setDupFields] = useState([]);
  const [errorSteps, setErrorSteps] = useState([]);
  const [errorFields, setErrorFields] = useState([]);

  const [clientData, setClientData] = useState({
    user_ids,
    ratanak_achievement_program_staff_client_ids,
    quantitative_case_ids,
    client_quantitative_free_text_cases,
    agency_ids,
    donor_ids,
    family_ids,
    current_family_id,
    isTestClient,
    isForTesting,
    referral_id,
    ...client
  });
  const [clientProfile, setClientProfile] = useState({});
  const [refereeData, setRefereeData] = useState(referee);
  const [familyMemberData, setfamilyMemberData] = useState(family_member);
  const [refereesData, setRefereesData] = useState(referees);
  const [carerData, setCarerData] = useState(carer);
  const [
    clientQuantitativeFreeTextCasesData,
    setClientQuantitativeFreeTextCases
  ] = useState(client_quantitative_free_text_cases);
  const [moSAVYOfficialsData, setMoSAVYOfficialsData] =
    useState(moSAVYOfficials);
  const [riskAssessmentData, setRiskAssessmentData] = useState(riskAssessment);
  const [clientCustomData, setClientCustomData] = useState(clientCustomFields);

  useEffect(() => {
    // scroll to top 👆 on page load
    let topOffset = getPageOffset($('label[style*="color: red"]')[0]);
    window.scrollTo({ top: topOffset, left: 0, behavior: "smooth" });
  }, [errorFields]);

  const address = {
    currentProvinces,
    currentCities: cities,
    currentDistricts: districts,
    currentCommunes: communes,
    currentVillages: villages,
    subDistricts,
    currentStates,
    currentTownships,
    current_organization,
    addressTypes,
    T
  };
  const adminTabData = { users, client: clientData, errorFields, T };
  const refereeTabData = {
    errorFields,
    client: clientData,
    referee: refereeData,
    referees: refereesData,
    referralSourceCategory,
    referralSource,
    currentProvinces,
    currentCities: cities,
    refereeDistricts,
    refereeCommunes,
    refereeVillages,
    refereeTownships,
    currentStates,
    refereeSubdistricts,
    addressTypes,
    T,
    translation,
    current_organization
  };

  const referralTabData = {
    errorFields,
    client: clientData,
    referee: refereeData,
    birthProvinces,
    phoneOwners,
    callerRelationships,
    ...address,
    T,
    translation,
    current_organization,
    brc_address,
    brc_islands,
    brc_presented_ids,
    brc_resident_types,
    brc_prefered_langs,
    maritalStatuses,
    nationalities,
    ethnicities,
    traffickingTypes
  };
  const moreReferralTabData = {
    errorFields,
    users,
    ratePoor,
    carer: carerData,
    familyMember: familyMemberData,
    schoolGrade,
    donors,
    agencies,
    families,
    clientRelationships,
    carerCities,
    carerDistricts,
    carerCommunes,
    carerVillages,
    currentStates,
    currentTownships,
    carerSubdistricts,
    ...referralTabData,
    T,
    customId1,
    customId2,
    moSAVYOfficialsData
  };
  const referralVulnerabilityTabData = {
    client: clientData,
    errorFields,
    clientQuantitativeFreeTextCasesData,
    quantitativeType,
    customData,
    clientCustomData,
    setClientCustomData,
    quantitativeCase,
    T
  };
  const legalDocument = { client: clientData, T, errorFields };
  const [isError, setIsError] = useState(false);

  const onChangeMoSAVYOfficialsData = (newData) => {
    setMoSAVYOfficialsData(newData);
  };

  const onChangeOfficial = (data, field, index) => {
    let official = moSAVYOfficialsData[index];
    official[field] = data;
    onChangeMoSAVYOfficialsData(
      moSAVYOfficialsData.map((record, ind) => {
        return ind == index ? official : record;
      })
    );
  };

  const onRemoveOfficial = (index) => {
    onChangeOfficial(true, "_destroy", index);
  };

  const onAddOfficial = () => {
    onChangeMoSAVYOfficialsData((moSAVYOfficialsData) => [
      ...moSAVYOfficialsData,
      { name: "", position: "", id: "" }
    ]);
  };

  const onChange = (obj, field) => (event) => {
    const inputType = ["date", "select", "checkbox", "radio", "file"];
    const value = inputType.includes(event.type)
      ? event.data
      : event.target.value;

    if (typeof field !== "object") field = { [field]: value };

    switch (obj) {
      case "client":
        setClientData((prev) => ({ ...prev, ...field }));
        break;
      case "clientProfile":
        setClientProfile({ profile: field });
        break;
      case "familyMember":
        setfamilyMemberData({ ...familyMemberData, ...field });
        break;
      case "referee":
        setRefereeData({ ...refereeData, ...field });
        break;
      case "carer":
        setCarerData({ ...carerData, ...field });
        break;
      case "cqFreeText":
        setClientQuantitativeFreeTextCases(
          clientQuantitativeFreeTextCasesData.map((quantitativeFreeText) => {
            return quantitativeFreeText.quantitative_type_id ==
              field.quantitative_type_id
              ? field
              : quantitativeFreeText;
          })
        );
        break;
      case "riskAssessment":
        setRiskAssessmentData({ ...riskAssessmentData, ...field });
        break;
      case "custom_data":
        setClientCustomData((prev) => ({ ...prev, ...field }));
        break;
      default:
        console.log("not match");
    }
  };

  const getPageOffset = (elem) => {
    if (!elem) return 50;

    let topOffset = elem.getBoundingClientRect().top;

    while (elem != document.documentElement) {
      elem = elem.parentElement;
      topOffset += elem.scrollTop;
    }

    return topOffset - 50;
  };

  const handleValidation = (stepToBeCheck = 0) => {
    const step5RequiredFields = Object.entries(requiredFields.fields)
      .map((keypair) => {
        const checkboxKey = keypair[0];
        const docKey = requiredFields.mapping[checkboxKey];

        return keypair[1] === true && clientData[checkboxKey] === true
          ? docKey
          : null;
      })
      .filter((item) => {
        return item !== null;
      });

    const components = [
      { step: 1, data: refereeData, fields: ["name"] },
      { step: 1, data: clientData, fields: ["referral_source_category_id"] },
      { step: 1, data: clientData, fields: ["gender"] },
      { step: 1, data: moSAVYOfficialsData, fields: ["name", "position"] },
      { step: 1, data: riskAssessmentData, fields: [] },
      {
        step: 1,
        data: clientData,
        fields:
          clientData.status != "Exited"
            ? ["received_by_id", "initial_referral_date", "user_ids"]
            : ["received_by_id", "initial_referral_date"]
      },
      { step: 1, data: clientData, fields: step5RequiredFields }
    ];

    const errors = [];
    const errorSteps = [];

    components.forEach((component) => {
      if (
        step === component.step ||
        (stepToBeCheck !== 0 && component.step === stepToBeCheck)
      ) {
        component.fields.forEach((field) => {
          if (
            component.data[field] === "" ||
            (Array.isArray(component.data) &&
              component.data.filter((item) => {
                return (
                  item._destroy !== true &&
                  (item[field].length == 0 || item[field].length == null)
                );
              }).length > 0) ||
            (Array.isArray(component.data[field]) &&
              !component.data[field].length) ||
            component.data[field] === null
          ) {
            errors.push(field);
            errorSteps.push(component.step);
          }
        });

        if (riskAssessmentData.level_of_risk === "high") {
          if (
            riskAssessmentData.tasks_attributes.filter(
              (task) => task._destroy === undefined
            ).length === 0
          ) {
            setIsError(true);
            errors.push("tasks_attributes");
            errorSteps.push(component.step);
          }
        }
      }
    });

    params("step") === "customDataInfo" &&
      quantitativeType.forEach((qttType) => {
        if (qttType.is_required) {
          if (qttType.field_type == "free_text") {
            const item = clientQuantitativeFreeTextCasesData.find(
              (cqFreeText) => {
                return cqFreeText.quantitative_type_id == qttType.id;
              }
            );

            if (item.content === null || item.content === "") {
              errors.push(`qtt_type_${qttType.id}`);
              errorSteps.push(5);
            }
          } else {
            const qttCasees = quantitativeCase.filter((ftr) => {
              return ftr.quantitative_type_id === qttType.id;
            });
            let error = true;

            qttCasees.forEach((qttCase) => {
              if (clientData.quantitative_case_ids.includes(qttCase.id)) {
                error = false;
              }
            });

            if (error) {
              errors.push(`qtt_type_${qttType.id}`);
              errorSteps.push(5);
            }
          }
        }
      });

    if (errors.length > 0) {
      setErrorFields(errors);
      setErrorSteps([...new Set(errorSteps)]);
      return false;
    } else {
      setErrorFields([]);
      setErrorSteps([]);
      return true;
    }
  };

  const handleClientDataValidation = (customDataObj = {}) => {
    customDataObj.properties = customDataObj.properties || {};
    customDataObj.form_builder_attachments_attributes =
      customDataObj.form_builder_attachments_attributes ||
      clientCustomData._attachments ||
      {};
    const customDataRequiredFields = Object.entries(customData)
      .filter(([key, value]) => {
        if (value.type === "file")
          return (
            value.required &&
            _.isEmpty(
              clientCustomData[value.name]?.files ||
                customDataObj.form_builder_attachments_attributes[
                  value.name.split("-")[1]
                ]?.file
            )
          );

        if (value.type === "checkbox-group")
          return (
            value.required &&
            _.isEmpty(
              clientCustomData[value.name] ||
                customDataObj.properties[value.name] ||
                []
            )
          );

        return (
          value.required &&
          _.isEmpty(
            clientCustomData[value.name] || customDataObj.properties[value.name]
          )
        );
      })
      .map(([index, element]) => element.name);

    if (!_.isEmpty(customDataRequiredFields)) {
      setErrorFields(customDataRequiredFields);
      setErrorSteps([5]);
      setStep(5);
      $("#save-btn-help-text").show();
      return false;
    }

    setErrorFields([]);
    setErrorSteps([]);
    setOnSave(false);
    return true;
  };

  const checkClientExist = () => (callback) => {
    const data = {
      slug: clientData.slug || "",
      given_name: clientData.given_name,
      family_name: clientData.family_name,
      local_given_name: clientData.local_given_name,
      local_family_name: clientData.local_family_name,
      date_of_birth: clientData.date_of_birth || "",
      birth_province_id: clientData.birth_province_id || "",
      current_province_id: clientData.province_id || "",
      district_id: clientData.district_id || "",
      city_id: clientData.city_id || "",
      village_id: clientData.village_id || "",
      commune_id: clientData.commune_id || "",
      gender: clientData.gender || ""
    };

    if (clientData.outside === false) {
      if (
        data.given_name !== "" ||
        data.family_name !== "" ||
        data.local_given_name !== "" ||
        data.local_family_name !== "" ||
        data.date_of_birth !== "" ||
        data.birth_province_id !== "" ||
        data.current_province_id !== "" ||
        data.district_id !== "" ||
        data.village_id !== "" ||
        data.commune_id !== ""
      ) {
        $.ajax({
          type: "GET",
          url: "/api/clients/compare",
          data: data,
          beforeSend: () => {
            setLoading(true);
          }
        }).success((response) => {
          if (response.similar_fields.length > 0) {
            setDupFields(response.similar_fields);
            setDupClientModalOpen(true);
            return false;
          } else {
            callback();
          }
          setLoading(false);
        });
      } else {
        callback();
      }
    } else {
      callback();
    }
  };

  const renderModalContent = (data) => {
    return (
      <div>
        <p>{T.translate("index.similar_record")}</p>
        <ul>
          {data.map((fields, index) => {
            let newFields = fields.split("_");
            newFields.splice(0, 1);
            return (
              <li key={index} style={{ textTransform: "capitalize" }}>
                {newFields.join(" ")}
              </li>
            );
          })}
        </ul>
        <p>{T.translate("index.checking_message")}</p>
      </div>
    );
  };

  const renderModalFooter = () => {
    return (
      <div>
        <div style={{ display: "flex", justifyContent: "flex-end" }}>
          <button
            style={{ margin: 5 }}
            className="btn btn-primary"
            onClick={() => (
              setDupClientModalOpen(false), handleSave()(nill, true)
            )}
          >
            {T.translate("index.continue")}
          </button>
        </div>
      </div>
    );
  };

  const handleCheckValue = (object) => {
    if (object.outside) {
      object.province_id = null;
      object.city_id = null;
      object.district_id = null;
      object.commune_id = null;
      object.village_id = null;
      object.street_number = "";
      object.current_address = "";
      object.address_type = "";
      object.house_number = "";
      object.locality = "";
    } else {
      object.outside_address = "";
    }
  };

  const handleSave = () => (callback, forceSave) => {
    forceSave = forceSave === undefined ? false : forceSave;
    if (callback("step") === "clientInfo") checkClientExist();
    if (handleValidation()) {
      handleCheckValue(refereeData);
      handleCheckValue(clientData);
      if (callback("step") === "additionalInfo") handleCheckValue(carerData);

      if (
        (familyMemberData.family_id === null ||
          familyMemberData.family_id === undefined) &&
        forceSave === false
      )
        setAttachFamilyModal(true);
      else {
        setOnSave(true);
        const action = clientData.id ? "PUT" : "POST";
        const message = clientData.id
          ? T.translate("index.successfully_updated")
          : T.translate("index.successfully_created");
        const url = clientData.id
          ? `/api/clients/${clientData.id}?referral_id=${clientData.referral_id}`
          : "/api/clients";

        let formData = new FormData();
        formData = objectToFormData(
          { ...clientData, ...clientProfile },
          {},
          formData,
          "client"
        );
        formData = objectToFormData(refereeData, {}, formData, "referee");
        formData = objectToFormData(carerData, {}, formData, "carer");
        formData = objectToFormData(
          familyMemberData,
          {},
          formData,
          "family_member"
        );
        formData = objectToFormData(
          clientQuantitativeFreeTextCasesData,
          [],
          formData,
          "client_quantitative_free_text_cases"
        );
        formData = objectToFormData(
          moSAVYOfficialsData,
          {},
          formData,
          "mosavy_officials"
        );
        formData = objectToFormData(
          riskAssessmentData,
          {},
          formData,
          "risk_assessment"
        );

        if (!_.isEmpty(customData)) {
          const customDataObj = {};
          customDataObj.form_builder_attachments_attributes =
            clientCustomData._attachments || {};
          customDataObj.properties = Object.entries(clientCustomData)
            .filter(([key, _]) => key !== "_attachments")
            .reduce((res, [key, value]) => ({ ...res, [key]: value }), {});

          if (!handleClientDataValidation(customDataObj)) return false;

          formData = objectToFormData(
            customDataObj,
            {},
            formData,
            "custom_data"
          );
        }

        $.ajax({
          url,
          type: action,
          data: formData,
          processData: false,
          contentType: false,
          beforeSend: () => {
            setLoading(true), setAttachFamilyModal(false);
          }
        })
          .done((response) => {
            document.location.href =
              `/clients/${response.slug}?notice=` + message;
          })
          .fail((error) => {
            setLoading(false);
            setOnSave(false);

            if (error.statusText == "Request Entity Too Large") {
              alert(
                "Your data is too large, try upload your attachments part by part."
              );
            } else {
              let errorMessage = "";
              const errorFields = JSON.parse(error.responseText);

              setErrorFields(Object.keys(errorFields));
              if (errorFields.kid_id) setErrorSteps([3]);

              for (const errorKey in errorFields) {
                errorMessage = `${errorKey
                  .toLowerCase()
                  .split("_")
                  .join(" ")
                  .toUpperCase()} ${errorFields[errorKey].join(" ")}`;
                toastr.error(errorMessage);
              }
            }
          });
      }
    }
  };

  const handleCancel = () => {
    const clientLocation = `/clients/${client.slug || ""}${
      window.location.search
    }`;
    confirmCancel(toastr, clientLocation);
  };

  const renderAddressSwitch = (
    objectData,
    objectKey,
    disabled,
    addresses = {}
  ) => {
    const country_name = current_organization.country;
    switch (country_name) {
      case "myanmar":
        return (
          <MyanmarAddress
            disabled={disabled}
            outside={objectData.outside || false}
            onChange={onChange}
            data={{
              addressTypes,
              currentStates,
              currentTownships,
              refereeTownships,
              carerTownships,
              objectKey,
              objectData,
              T
            }}
          />
        );
        break;
      case "thailand":
        return (
          <ThailandAddress
            disabled={disabled}
            outside={objectData.outside || false}
            onChange={onChange}
            data={{
              addressTypes,
              currentDistricts: districts,
              currentProvinces,
              subDistricts,
              refereeDistricts,
              refereeSubdistricts,
              carerDistricts,
              carerSubdistricts,
              objectKey,
              objectData,
              T
            }}
          />
        );
        break;
      case "lesotho":
        return (
          <LesothoAddress
            disabled={disabled}
            outside={objectData.outside || false}
            onChange={onChange}
            data={{ addressTypes, objectKey, objectData, T }}
          />
        );
        break;
      case "indonesia":
        if (objectKey == "referee")
          return (
            <IndonesianAddress
              disabled={disabled}
              outside={objectData.outside || false}
              onChange={onChange}
              data={{
                addressTypes,
                currentProvinces,
                currentCities: refereeCities,
                currentDistricts: refereeDistricts,
                subDistricts: refereeSubdistricts,
                objectKey,
                objectData,
                T
              }}
            />
          );
        else if (objectKey == "carer")
          return (
            <IndonesianAddress
              disabled={disabled}
              outside={objectData.outside || false}
              onChange={onChange}
              data={{
                addressTypes,
                currentProvinces,
                currentCities: carerCities,
                currentDistricts: carerDistricts,
                subDistricts: carerSubdistricts,
                objectKey,
                objectData,
                T
              }}
            />
          );
        else
          return (
            <IndonesianAddress
              disabled={disabled}
              outside={objectData.outside || false}
              onChange={onChange}
              data={{
                addressTypes,
                currentProvinces,
                currentCities: cities,
                currentDistricts: districts,
                subDistricts: subDistricts,
                objectKey,
                objectData,
                T
              }}
            />
          );

        break;
      case "nepal":
        if (objectKey == "referee") {
          return (
            <NepalAddress
              hintText={inlineHelpTranslation}
              disabled={disabled}
              outside={objectData.outside || false}
              onChange={onChange}
              current_organization={current_organization}
              data={{
                addressTypes,
                currentDistricts: addresses.districts || refereeDistricts,
                currentCommunes: addresses.communes || refereeCommunes,
                currentProvinces,
                objectKey,
                objectData,
                T
              }}
            />
          );
        } else if (objectKey == "carer") {
          return (
            <NepalAddress
              hintText={inlineHelpTranslation}
              disabled={disabled}
              outside={objectData.outside || false}
              onChange={onChange}
              current_organization={current_organization}
              data={{
                addressTypes,
                currentDistricts: carerDistricts,
                currentCommunes: carerCommunes,
                currentVillages: carerVillages,
                currentProvinces,
                objectKey,
                objectData,
                T
              }}
            />
          );
        } else {
          <NepalAddress
            hintText={inlineHelpTranslation}
            disabled={disabled}
            outside={objectData.outside || false}
            onChange={onChange}
            current_organization={current_organization}
            data={{
              addressTypes,
              currentDistricts: districts,
              currentCommunes: communes,
              currentVillages: villages,
              currentProvinces,
              objectKey,
              objectData,
              T
            }}
          />;
        }
        break;
      default:
        return (
          <Address
            hintText={inlineHelpTranslation}
            translation={translation}
            disabled={disabled}
            outside={objectData.outside || false}
            onChange={onChange}
            current_organization={current_organization}
            data={{
              addressTypes,
              currentDistricts: addresses.districts || [],
              currentCommunes: addresses.communes || [],
              currentVillages: addresses.villages || [],
              currentProvinces,
              objectKey,
              objectData,
              T
            }}
          />
        );
    }
  };

  return (
    <div
      className="containerClass"
      style={loading ? { minHeight: "100vh", height: "100vh" } : {}}
    >
      <Loading
        loading={loading}
        text={step <= 3 ? T.translate("index.wait") : "Saving..."}
      />

      <Modal
        className="p-md"
        title={T.translate("index.informing")}
        isOpen={dupClientModalOpen}
        type="warning"
        closeAction={() => setDupClientModalOpen(false)}
        content={renderModalContent(dupFields)}
        footer={renderModalFooter()}
      />

      <Modal
        title={T.translate("index.client_confirm")}
        isOpen={attachFamilyModal}
        type="success"
        closeAction={() => setAttachFamilyModal(false)}
        content={
          <CreateFamilyModal
            id="myModal"
            data={{ families, clientData, familyMemberData, T }}
            onChange={onChange}
            onSave={handleSave}
          />
        }
      />

      <div className="contentWrapper">
        <div className="leftComponent">
          <AdministrativeInfo
            data={adminTabData}
            onChange={onChange}
            fieldsVisibility={fieldsVisibility}
            translation={translation}
            hintText={inlineHelpTranslation}
          />
        </div>

        <div className="rightComponent">
          <div
            style={{
              display: params("step") === "clientInfo" ? "block" : "none"
            }}
          >
            <RefereeInfo
              current_organization={current_organization}
              data={refereeTabData}
              onChange={onChange}
              renderAddressSwitch={renderAddressSwitch}
              translation={translation}
              fieldsVisibility={fieldsVisibility}
              hintText={inlineHelpTranslation}
            />
          </div>

          <div
            style={{
              display: params("step") === "clientInfo" ? "block" : "none"
            }}
          >
            <ReferralInfo
              data={referralTabData}
              onChange={onChange}
              renderAddressSwitch={renderAddressSwitch}
              translation={translation}
              fieldsVisibility={fieldsVisibility}
              hintText={inlineHelpTranslation}
            />
          </div>

          <div
            style={{
              display: params("step") === "additionalInfo" ? "block" : "none"
            }}
          >
            <ReferralMoreInfo
              translation={translation}
              renderAddressSwitch={renderAddressSwitch}
              fieldsVisibility={fieldsVisibility}
              current_organization={current_organization}
              data={moreReferralTabData}
              onChangeMoSAVYOfficialsData={onChangeMoSAVYOfficialsData}
              onAddOfficial={onAddOfficial}
              onChangeOfficial={onChangeOfficial}
              onRemoveOfficial={onRemoveOfficial}
              onChange={onChange}
              hintText={inlineHelpTranslation}
            />
          </div>

          {isRiskAssessmentEnabled && (
            <div
              style={{
                display: params("step") === "riskInfo" ? "block" : "none"
              }}
            >
              <RiskAssessment
                data={riskAssessmentData}
                setRiskAssessmentData={setRiskAssessmentData}
                onChange={onChange}
                isError={isError}
                setIsError={setIsError}
                protectionConcerns={protectionConcerns}
                historyOfHarms={historyOfHarms}
                historyOfHighRiskBehaviours={historyOfHighRiskBehaviours}
                reasonForFamilySeparations={reasonForFamilySeparations}
                historyOfDisabilities={historyOfDisabilities}
              />
            </div>
          )}

          <div
            style={{
              display: params("step") === "customDataInfo" ? "block" : "none"
            }}
          >
            <ReferralVulnerability
              data={referralVulnerabilityTabData}
              current_organization={current_organization}
              translation={translation}
              fieldsVisibility={fieldsVisibility}
              onChange={onChange}
              hintText={inlineHelpTranslation}
            />
          </div>

          {fieldsVisibility.show_legal_doc == true && (
            <div
              style={{
                display: params("step") === "customDataInfo" ? "block" : "none"
              }}
            >
              <LegalDocument
                data={legalDocument}
                translation={translation}
                requiredFields={requiredFields}
                fieldsVisibility={fieldsVisibility}
                onChange={onChange}
                setClientData={setClientData}
              />
            </div>
          )}
        </div>
      </div>

      <div className="actionfooter">
        <div className="leftWrapper"></div>

        <div className="rightWrapper">
          <span className="btn btn-default" onClick={handleCancel}>
            {T.translate("index.cancel")}
          </span>
          <span
            id="save-btn-help-text"
            data-toggle="popover"
            role="button"
            data-html={true}
            data-placement="auto"
            data-trigger="hover"
            data-content={inlineHelpTranslation.clients.buttons.save}
            className="clientButton saveButton"
            onClick={() => handleSave()(params, true)}
          >
            {T.translate("index.save")}
          </span>
        </div>
      </div>
    </div>
  );
};

export default Forms;
