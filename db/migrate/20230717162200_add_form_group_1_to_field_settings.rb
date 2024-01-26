class AddFormGroup1ToFieldSettings < ActiveRecord::Migration
  def change
    add_column :field_settings, :form_group_1, :string
    add_column :field_settings, :form_group_2, :string
    add_column :field_settings, :heading, :string

    reversible do |dir|
      dir.up do
        reset_field_setting_group
        reset_client_form
        reset_family_form
        reset_case_management_tool
        reset_anti_trafficking
      end
    end
  end
end

def reset_field_setting_group
  groups = FieldSetting.pluck(:group).uniq
  groups.each do |group|
    FieldSetting.where(group: group).update_all(form_group_1: group)
  end

  FieldSetting.where(group: 'client').update_all(form_group_1: 'client_form')
  FieldSetting.where(group: 'carer').update_all(form_group_1: 'client_form')
  FieldSetting.where(group: 'referee').update_all(form_group_1: 'client_form')
  FieldSetting.where(group: 'school_information').update_all(form_group_1: 'client_form')

  FieldSetting.where(group: 'family').update_all(form_group_1: 'family_form')
  FieldSetting.where(group: 'family_member').update_all(form_group_1: 'family_form')

  FieldSetting.where(group: 'case_note').update_all(form_group_1: 'case_management_tools')
  FieldSetting.where(group: 'assessment').update_all(form_group_1: 'case_management_tools')
end

def reset_client_form
  referee_tab =  %w(received_by received_by_id initial_referral_date user_ids followed_up_by_id follow_up_date referee_called_before referee_address)
  client_info_tab = %w(referral_info given_name family_name local_given_name local_family_name gender birth_province client_phone phone_owner)
  client_more_info_tab = %w(carer_information name phone email school_name school_grade main_school_contact rated_for_id_poor)

  FieldSetting.where(form_group_1: 'client_form', name: referee_tab).update_all(form_group_2: 'referee_info_tab')
  FieldSetting.where(form_group_1: 'client_form', name: client_info_tab).update_all(form_group_2: 'client_info_tab')
  FieldSetting.where(form_group_1: 'client_form', name: client_more_info_tab).update_all(form_group_2: 'client_more_info_tab')
end

def reset_family_form
  basic_info_tab = %w(caregiver_information province_id district_id commune_id village_id street house dependable_income household_income contract_date gender)
  family_member_tab = %w(name gender guardian relation occupation adult_name)

  FieldSetting.where(group: 'family', name: basic_info_tab).update_all(form_group_2: 'basic_info_tab')
  FieldSetting.where(group: 'family_member', name: family_member_tab).update_all(form_group_2: 'family_member_tab')
end

def reset_case_management_tool
  FieldSetting.where(form_group_1: 'client_form', name: %w(complete_screening_assessment view_screening_assessment screening_interview_form)).update_all(form_group_1: 'case_management_tools', form_group_2: 'screening_form')
  FieldSetting.where(form_group_1: 'client_form', name: %w(assessment)).update_all(form_group_1: 'case_management_tools', form_group_2: 'assessment')
  FieldSetting.where(form_group_1: 'case_management_tools', name: %w(reason)).update_all(form_group_2: 'assessment')
  FieldSetting.where(name: 'government_forms').update_all(form_group_1: 'case_management_tools', form_group_2: 'cmt_government_form')
  FieldSetting.where(name: 'note', group: 'case_note').update_all(form_group_1: 'case_management_tools', form_group_2: 'case_note')
  FieldSetting.where(name: 'case_note', group: 'client').update_all(form_group_1: 'case_management_tools', form_group_2: 'case_note')
  FieldSetting.where(group: 'care_plan').update_all(form_group_1: 'case_management_tools', form_group_2: 'care_plan')
  FieldSetting.where(group: 'task').update_all(form_group_1: 'case_management_tools', form_group_2: 'task')
end

def reset_anti_trafficking
  FieldSetting.where(form_group_1: 'client_form', name: %w(national_id passport family_book birth_cert)).update_all(form_group_1: 'anti-trafficking', form_group_2: 'legal_documentations', heading: 'Identification Documents')

  FieldSetting.where(form_group_1: 'client_form', name: %w(ngo_partner mosavy dosavy msdhs)).update_all(form_group_1: 'anti-trafficking', form_group_2: 'legal_documentations', heading: 'Referral Documents')

  FieldSetting.where(form_group_1: 'client_form', name: %w(complain warrant verdict)).update_all(form_group_1: 'anti-trafficking', form_group_2: 'legal_documentations', heading: 'Legal Proceeding Documents')

  FieldSetting.where(form_group_1: 'client_form', name: %w(short_form_of_ocdm short_form_of_mosavy_dosavy detail_form_of_mosavy_dosavy short_form_of_judicial_police detail_form_of_judicial_police other_legal_doc)).update_all(form_group_1: 'anti-trafficking', form_group_2: 'legal_documentations', heading: 'Form for Identification of Victim of Human Trafficking')

  FieldSetting.where(group: 'stakeholder_contacts').update_all(form_group_1: 'anti-trafficking', form_group_2: 'stakeholder_contacts')
  FieldSetting.where(group: 'pickup_information').update_all(form_group_1: 'anti-trafficking', form_group_2: 'pickup_information')

  FieldSetting.where(form_group_1: 'client_form', name: %w(marital_status nationality ethnicity location_of_concern type_of_trafficking department national_id_number passport_number complete_screening_assessment view_screening_assessment education_background)).update_all(form_group_1: 'anti-trafficking', form_group_2: 'added_field_by_ratanak')
end

# ["add_new_service_delivery-service_delivery",
#  "address_type-client",
#  "adult_name-family_member",
#  "arrival_at-pickup_information",
#  "assessment-client",
#  "attachments-case_conference",
#  "attachments-internal_referral",
#  "attendants-case_conference",
#  "background-partner",
#  "birth_cert-client",
#  "birth_province-client",
#  "brsc_branch-client",
#  "caregiver_information-family",
#  "carer_information-carer",
#  "case_note-client",
#  "case_note_edit_limit-case_note",
#  "category-service_delivery",
#  "ccwc_name-stakeholder_contacts",
#  "ccwc_phone-stakeholder_contacts",
#  "chief_commune_name-stakeholder_contacts",
#  "chief_commune_phone-stakeholder_contacts",
#  "chief_village_name-stakeholder_contacts",
#  "chief_village_phone-stakeholder_contacts",
#  "client_engagement-case_conference",
#  "client_id-internal_referral",
#  "client_limitation-case_conference",
#  "client_name-internal_referral",
#  "client_phone-client",
#  "client_representing_problem-internal_referral",
#  "client_representing_problem_note-internal_referral",
#  "client_school_information-client_school_information",
#  "client_strength-case_conference",
#  "client_support-case_conference",
#  "commune_id-client",
#  "commune_id-family",
#  "complain-client",
#  "complete_screening_assessment-client",
#  "contract_date-family",
#  "current_address-client",
#  "current_household_type-client_current_address",
#  "current_island-client_current_address",
#  "current_po_box-client_current_address",
#  "current_resident_own_or_rent-client_current_address",
#  "current_settlement-client_current_address",
#  "current_street-client_current_address",
#  "department-client",
#  "dependable_income-family",
#  "detail_form_of_judicial_police-client",
#  "detail_form_of_mosavy_dosavy-client",
#  "disable_future_completion_date-case_note",
#  "district_id-client",
#  "district_id-family",
#  "done_by-service_delivery",
#  "dosavy-client",
#  "dosavy_name-stakeholder_contacts",
#  "dosavy_phone-stakeholder_contacts",
#  "education_background-school_information",
#  "email-carer",
#  "emergency_note-internal_referral",
#  "engagement-partner",
#  "ethnicity-client",
#  "family_book-client",
#  "family_name-client",
#  "family_type-family",
#  "flight_nb-client",
#  "follow_up_date-client",
#  "followed_up_by_id-client",
#  "form_indentification-client",
#  "gender-client",
#  "gender-family",
#  "gender-family_member",
#  "given_name-client",
#  "government_forms-client",
#  "guardian-family_member",
#  "house-family",
#  "house_number-client",
#  "household_income-family",
#  "household_type2-client_other_address",
#  "id-case_conference",
#  "id-service_delivery",
#  "id_number-client",
#  "indentification_doc-client",
#  "initial_referral_date-client",
#  "internal_referral-internal_referral",
#  "internal_referral_edit_duration-internal_referral",
#  "island2-client_other_address",
#  "labor_trafficking_legal_doc_option-client",
#  "legacy_brcs_id-client",
#  "legal_documents-client",
#  "legal_processing_doc-client",
#  "legal_representative_name-stakeholder_contacts",
#  "legal_team_name-stakeholder_contacts",
#  "legal_team_phone-stakeholder_contacts",
#  "letter_from_immigration_police-client",
#  "local_consent-client",
#  "local_family_name-client",
#  "local_given_name-client",
#  "local_resource-case_conference",
#  "location_of_concern-client",
#  "main_school_contact-school_information",
#  "manage-service_delivery",
#  "marital_status-client",
#  "meeting_date-case_conference",
#  "mosavy-client",
#  "mosavy_official-pickup_information",
#  "mosavy_official_name-pickup_information",
#  "mosavy_official_position-pickup_information",
#  "msdhs-client",
#  "name-carer",
#  "national_id-client",
#  "national_id_number-client",
#  "nationality-client",
#  "neighbor_name-stakeholder_contacts",
#  "neighbor_phone-stakeholder_contacts",
#  "ngo_partner-client",
#  "note-case_note",
#  "note-family_member",
#  "occupation-family_member",
#  "other_agency_name-stakeholder_contacts",
#  "other_agency_phone-stakeholder_contacts",
#  "other_legal_doc-client",
#  "other_legal_doc_option-client",
#  "other_phone_number-client",
#  "other_phone_whatsapp-client",
#  "other_representative_name-stakeholder_contacts",
#  "partner-partner",
#  "passport-client",
#  "passport_number-client",
#  "phone-carer",
#  "phone_owner-client",
#  "pickup_information-pickup_information",
#  "po_box2-client_other_address",
#  "police_interview-client",
#  "preferred_language-client",
#  "presented_id-client",
#  "presenting_problem-case_conference",
#  "program_stream_ids-internal_referral",
#  "province-partner",
#  "province-user",
#  "province_id-client",
#  "province_id-family",
#  "ratanak_achievement_program_staff_client_ids-pickup_information",
#  "rated_for_id_poor-client",
#  "reason-assessment",
#  "referee_address-referee",
#  "referral_date-internal_referral",
#  "referral_decision-internal_referral",
#  "referral_decision_note-internal_referral",
#  "referral_doc-client",
#  "referral_document-client",
#  "referral_info-client",
#  "referral_reason-internal_referral",
#  "referral_reason_note-internal_referral",
#  "relation-family_member",
#  "relevant_referral_information-client",
#  "resident_own_or_rent2-client_other_address",
#  "school_grade-school_information",
#  "school_name-school_information",
#  "screening_interview_form-client",
#  "service_delivery-service_delivery",
#  "service_provided-service_delivery",
#  "settlement2-client_other_address",
#  "sex_trafficking_legal_doc_option-client",
#  "short_form_of_judicial_police-client",
#  "short_form_of_mosavy_dosavy-client",
#  "short_form_of_ocdm-client",
#  "stakeholder_contacts-stakeholder_contacts",
#  "street-family",
#  "street2-client_other_address",
#  "street_number-client",
#  "task_completed_date-service_delivery",
#  "temp_travel_doc-client",
#  "travel_doc-client",
#  "type_of_trafficking-client",
#  "user_id-internal_referral",
#  "user_ids-client",
#  "verdict-client",
#  "view_screening_assessment-client",
#  "village_id-client",
#  "village_id-family",
#  "warrant-client",
#  "what3words-client",
#  "whatsapp-client"]
