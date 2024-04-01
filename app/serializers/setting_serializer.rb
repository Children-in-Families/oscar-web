class SettingSerializer < ActiveModel::Serializer
  attributes  :id, :custom_assessment_frequency, :assessment_frequency, :max_custom_assessment,
              :max_assessment, :enable_custom_assessment, :enable_default_assessment, :age,
              :custom_age, :default_assessment, :custom_assessment, :max_case_note,
              :case_note_frequency, :org_name, :province_id, :district_id, :commune_id,
              :delete_incomplete_after_period_unit, :use_screening_assessment, :screening_assessment_form_id,
              :delete_incomplete_after_period_value, :two_weeks_assessment_reminder,
              :never_delete_incomplete_assessment, :show_prev_assessment, :use_previous_care_plan,
              :sharing_data, :custom_id1_latin, :custom_id1_local, :custom_id2_latin, :custom_id2_local,
              :enable_hotline, :enable_client_form, :assessment_score_order, :disable_required_fields,
              :hide_family_case_management_tool, :hide_community, :case_conference_limit, :case_conference_frequency,
              :internal_referral_limit, :internal_referral_frequency, :case_note_edit_limit, :case_note_edit_frequency,
              :disabled_future_completion_date, :cbdmat_one_off, :cbdmat_ongoing, :enabled_internal_referral,
              :tracking_form_edit_limit, :tracking_form_edit_frequency, :disabled_add_service_received,
              :custom_field_limit, :custom_field_frequency, :test_client, :disabled_task_date_field,
              :required_case_note_note, :hide_case_note_note, :enabled_risk_assessment, :assessment_type_name,
              :level_of_risk_guidance, :organization_type, :selected_domain_ids, :custom_assessment_settings

  def custom_assessment_settings
    object.custom_assessment_settings.as_json(
      only: [
        :id, :custom_assessment_name, :max_custom_assessment, :custom_assessment_frequency,
        :custom_age, :setting_id, :enable_custom_assessment
      ]
    )
  end
end
