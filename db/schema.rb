# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20250211082558) do

  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'
  enable_extension 'hstore'
  enable_extension 'pgcrypto'
  enable_extension 'uuid-ossp'

  create_table 'able_screening_questions', force: :cascade do |t|
    t.string 'question'
    t.string 'mode'
    t.integer 'stage_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.boolean 'alert_manager'
    t.integer 'question_group_id'
  end

  add_index 'able_screening_questions', ['question_group_id'], name: 'index_able_screening_questions_on_question_group_id', using: :btree
  add_index 'able_screening_questions', ['stage_id'], name: 'index_able_screening_questions_on_stage_id', using: :btree

  create_table 'achievement_program_staff_clients', force: :cascade do |t|
    t.integer 'client_id'
    t.integer 'user_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_index 'achievement_program_staff_clients', ['client_id'], name: 'index_achievement_program_staff_clients_on_client_id', using: :btree
  add_index 'achievement_program_staff_clients', ['user_id'], name: 'index_achievement_program_staff_clients_on_user_id', using: :btree

  create_table 'action_results', force: :cascade do |t|
    t.text 'action', default: ''
    t.text 'result', default: ''
    t.integer 'government_form_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_index 'action_results', ['government_form_id'], name: 'index_action_results_on_government_form_id', using: :btree

  create_table 'admin_users', force: :cascade do |t|
    t.string 'email', default: '', null: false
    t.string 'encrypted_password', default: '', null: false
    t.string 'reset_password_token'
    t.datetime 'reset_password_sent_at'
    t.datetime 'remember_created_at'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'token'
    t.string 'first_name'
    t.string 'last_name'
    t.string 'provider', default: 'email', null: false
    t.string 'uid', default: '', null: false
    t.json 'tokens'
    t.string 'role', default: 'viewer'
  end

  add_index 'admin_users', ['email'], name: 'index_admin_users_on_email', unique: true, using: :btree
  add_index 'admin_users', ['reset_password_token'], name: 'index_admin_users_on_reset_password_token', unique: true, using: :btree

  create_table 'advanced_searches', force: :cascade do |t|
    t.string 'name'
    t.text 'description'
    t.jsonb 'queries'
    t.jsonb 'field_visible'
    t.string 'custom_forms'
    t.string 'program_streams'
    t.string 'enrollment_check', default: ''
    t.string 'tracking_check', default: ''
    t.string 'exit_form_check', default: ''
    t.string 'quantitative_check', default: ''
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.integer 'user_id'
    t.string 'hotline_check', default: ''
    t.string 'search_for', default: 'client'
  end

  add_index 'advanced_searches', ['user_id'], name: 'index_advanced_searches_on_user_id', using: :btree

  create_table 'agencies', force: :cascade do |t|
    t.string 'name', default: ''
    t.text 'description', default: ''
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer 'agencies_clients_count', default: 0
  end

  create_table 'agencies_clients', force: :cascade do |t|
    t.integer 'client_id'
    t.integer 'agency_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'agencies_clients', ['agency_id'], name: 'index_agencies_clients_on_agency_id', using: :btree
  add_index 'agencies_clients', ['client_id'], name: 'index_agencies_clients_on_client_id', using: :btree

  create_table 'agency_clients', force: :cascade do |t|
    t.integer 'agency_id'
    t.integer 'client_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'agency_clients', ['agency_id'], name: 'index_agency_clients_on_agency_id', using: :btree
  add_index 'agency_clients', ['client_id'], name: 'index_agency_clients_on_client_id', using: :btree

  create_table 'ahoy_messages', force: :cascade do |t|
    t.integer 'user_id'
    t.string 'user_type'
    t.text 'to'
    t.string 'mailer'
    t.text 'subject'
    t.datetime 'sent_at'
  end

  create_table 'ar_internal_metadata', primary_key: 'key', force: :cascade do |t|
    t.string 'value'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end

  create_table 'assessment_domains', force: :cascade do |t|
    t.text 'note', default: ''
    t.integer 'previous_score'
    t.integer 'score'
    t.text 'reason', default: ''
    t.integer 'assessment_id'
    t.integer 'domain_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.text 'goal', default: ''
    t.string 'attachments', default: [], array: true
    t.boolean 'goal_required', default: true
    t.boolean 'required_task_last', default: false
    t.integer 'care_plan_id'
  end

  add_index 'assessment_domains', ['assessment_id'], name: 'index_assessment_domains_on_assessment_id', using: :btree
  add_index 'assessment_domains', ['care_plan_id'], name: 'index_assessment_domains_on_care_plan_id', using: :btree
  add_index 'assessment_domains', ['domain_id'], name: 'index_assessment_domains_on_domain_id', using: :btree
  add_index 'assessment_domains', ['score'], name: 'index_assessment_domains_on_score', using: :btree

  create_table 'assessments', force: :cascade do |t|
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer 'client_id'
    t.boolean 'completed', default: false
    t.boolean 'default', default: true
    t.integer 'family_id'
    t.integer 'case_conference_id'
    t.date 'completed_date'
    t.integer 'custom_assessment_setting_id'
    t.string 'level_of_risk'
    t.text 'description'
    t.date 'assessment_date'
    t.boolean 'draft', default: false
    t.datetime 'last_auto_save_at'
  end

  add_index 'assessments', ['assessment_date'], name: 'index_assessments_on_assessment_date', using: :btree
  add_index 'assessments', ['case_conference_id'], name: 'index_assessments_on_case_conference_id', using: :btree
  add_index 'assessments', ['client_id'], name: 'index_assessments_on_client_id', using: :btree
  add_index 'assessments', ['completed_date'], name: 'index_assessments_on_completed_date', using: :btree
  add_index 'assessments', ['custom_assessment_setting_id'], name: 'index_assessments_on_custom_assessment_setting_id', using: :btree
  add_index 'assessments', ['default'], name: 'index_assessments_on_default', where: "(\"default\" = true)", using: :btree
  add_index 'assessments', ['default'], name: 'index_assessments_on_default_false', where: "(\"default\" = false)", using: :btree
  add_index 'assessments', ['family_id'], name: 'index_assessments_on_family_id', using: :btree
  add_index 'assessments', ['last_auto_save_at', 'draft'], name: 'index_assessments_on_last_auto_save_at_and_draft', using: :btree
  add_index 'assessments', ['level_of_risk'], name: 'index_assessments_on_level_of_risk', using: :btree

  create_table 'attachments', force: :cascade do |t|
    t.string 'image'
    t.integer 'able_screening_question_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'file', default: ''
    t.integer 'progress_note_id'
  end

  add_index 'attachments', ['able_screening_question_id'], name: 'index_attachments_on_able_screening_question_id', using: :btree
  add_index 'attachments', ['progress_note_id'], name: 'index_attachments_on_progress_note_id', using: :btree

  create_table 'billable_report_items', force: :cascade do |t|
    t.integer 'billable_report_id'
    t.integer 'version_id', null: false
    t.string 'billable_status', null: false
    t.datetime 'billable_at'
    t.datetime 'accepted_at'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'billable_type'
    t.integer 'billable_id'
  end

  add_index 'billable_report_items', ['billable_report_id'], name: 'index_billable_report_items_on_billable_report_id', using: :btree
  add_index 'billable_report_items', ['version_id'], name: 'index_billable_report_items_on_version_id', using: :btree

  create_table 'billable_reports', force: :cascade do |t|
    t.integer 'organization_id'
    t.integer 'year'
    t.integer 'month'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'organization_name'
    t.string 'organization_short_name'
  end

  add_index 'billable_reports', ['organization_id'], name: 'index_billable_reports_on_organization_id', using: :btree

  create_table 'calendars', force: :cascade do |t|
    t.string 'title'
    t.datetime 'start_date'
    t.datetime 'end_date'
    t.boolean 'sync_status', default: false
    t.integer 'user_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'google_event_id'
    t.integer 'task_id'
  end

  add_index 'calendars', ['google_event_id'], name: 'index_calendars_on_google_event_id', using: :btree
  add_index 'calendars', ['task_id'], name: 'index_calendars_on_task_id', using: :btree
  add_index 'calendars', ['user_id'], name: 'index_calendars_on_user_id', using: :btree

  create_table 'call_necessities', force: :cascade do |t|
    t.integer 'call_id'
    t.integer 'necessity_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_index 'call_necessities', ['call_id'], name: 'index_call_necessities_on_call_id', using: :btree
  add_index 'call_necessities', ['necessity_id'], name: 'index_call_necessities_on_necessity_id', using: :btree

  create_table 'call_protection_concerns', force: :cascade do |t|
    t.integer 'call_id'
    t.integer 'protection_concern_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_index 'call_protection_concerns', ['call_id'], name: 'index_call_protection_concerns_on_call_id', using: :btree
  add_index 'call_protection_concerns', ['protection_concern_id'], name: 'index_call_protection_concerns_on_protection_concern_id', using: :btree

  create_table 'calls', force: :cascade do |t|
    t.integer 'referee_id'
    t.string 'phone_call_id', default: ''
    t.integer 'receiving_staff_id'
    t.datetime 'start_datetime'
    t.string 'call_type', default: ''
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'information_provided', default: ''
    t.date 'date_of_call'
    t.boolean 'answered_call'
    t.boolean 'called_before'
    t.boolean 'requested_update', default: false
    t.boolean 'not_a_phone_call', default: false
    t.boolean 'childsafe_agent'
    t.string 'other_more_information', default: ''
    t.string 'brief_note_summary', default: ''
  end

  add_index 'calls', ['phone_call_id'], name: 'index_calls_on_phone_call_id', using: :btree
  add_index 'calls', ['receiving_staff_id'], name: 'index_calls_on_receiving_staff_id', using: :btree
  add_index 'calls', ['referee_id'], name: 'index_calls_on_referee_id', using: :btree

  create_table 'care_plans', force: :cascade do |t|
    t.integer 'assessment_id'
    t.integer 'client_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer 'family_id'
    t.boolean 'completed', default: false
    t.date 'care_plan_date'
  end

  add_index 'care_plans', ['assessment_id'], name: 'index_care_plans_on_assessment_id', using: :btree
  add_index 'care_plans', ['care_plan_date'], name: 'index_care_plans_on_care_plan_date', using: :btree
  add_index 'care_plans', ['client_id'], name: 'index_care_plans_on_client_id', using: :btree
  add_index 'care_plans', ['family_id'], name: 'index_care_plans_on_family_id', using: :btree

  create_table 'carers', force: :cascade do |t|
    t.string 'address_type', default: ''
    t.string 'current_address', default: ''
    t.string 'email', default: ''
    t.string 'gender', default: ''
    t.string 'house_number', default: ''
    t.string 'outside_address', default: ''
    t.string 'street_number', default: ''
    t.string 'client_relationship', default: ''
    t.boolean 'outside', default: false
    t.integer 'province_id'
    t.integer 'district_id'
    t.integer 'commune_id'
    t.integer 'village_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'name', default: ''
    t.string 'phone', default: ''
    t.boolean 'same_as_client', default: false
    t.string 'suburb', default: ''
    t.string 'description_house_landmark', default: ''
    t.string 'directions', default: ''
    t.string 'street_line1', default: ''
    t.string 'street_line2', default: ''
    t.string 'plot', default: ''
    t.string 'road', default: ''
    t.string 'postal_code', default: ''
    t.integer 'state_id'
    t.integer 'township_id'
    t.integer 'subdistrict_id'
    t.string 'locality'
    t.integer 'city_id'
  end

  add_index 'carers', ['city_id'], name: 'index_carers_on_city_id', using: :btree
  add_index 'carers', ['commune_id'], name: 'index_carers_on_commune_id', using: :btree
  add_index 'carers', ['district_id'], name: 'index_carers_on_district_id', using: :btree
  add_index 'carers', ['province_id'], name: 'index_carers_on_province_id', using: :btree
  add_index 'carers', ['state_id'], name: 'index_carers_on_state_id', using: :btree
  add_index 'carers', ['subdistrict_id'], name: 'index_carers_on_subdistrict_id', using: :btree
  add_index 'carers', ['township_id'], name: 'index_carers_on_township_id', using: :btree
  add_index 'carers', ['village_id'], name: 'index_carers_on_village_id', using: :btree

  create_table 'case_closures', force: :cascade do |t|
    t.string 'name'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'case_conference_addressed_issues', force: :cascade do |t|
    t.integer 'case_conference_domain_id'
    t.string 'title'
  end

  add_index 'case_conference_addressed_issues', ['case_conference_domain_id'], name: 'index_addressed_issues_on_case_conference_domain_id', using: :btree

  create_table 'case_conference_domains', force: :cascade do |t|
    t.integer 'domain_id'
    t.integer 'case_conference_id'
    t.text 'presenting_problem'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_index 'case_conference_domains', ['case_conference_id'], name: 'index_case_conference_domains_on_case_conference_id', using: :btree
  add_index 'case_conference_domains', ['domain_id'], name: 'index_case_conference_domains_on_domain_id', using: :btree

  create_table 'case_conference_users', force: :cascade do |t|
    t.integer 'user_id'
    t.integer 'case_conference_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_index 'case_conference_users', ['case_conference_id'], name: 'index_case_conference_users_on_case_conference_id', using: :btree
  add_index 'case_conference_users', ['user_id'], name: 'index_case_conference_users_on_user_id', using: :btree

  create_table 'case_conferences', force: :cascade do |t|
    t.datetime 'meeting_date'
    t.text 'client_strength'
    t.text 'client_limitation'
    t.text 'client_engagement'
    t.text 'local_resource'
    t.string 'attachments', default: [], array: true
    t.integer 'client_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_index 'case_conferences', ['client_id'], name: 'index_case_conferences_on_client_id', using: :btree
  add_index 'case_conferences', ['meeting_date'], name: 'index_case_conferences_on_meeting_date', using: :btree

  create_table 'case_contracts', force: :cascade do |t|
    t.date 'signed_on'
    t.integer 'case_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'case_contracts', ['case_id'], name: 'index_case_contracts_on_case_id', using: :btree

  create_table 'case_note_domain_groups', force: :cascade do |t|
    t.text 'note', default: ''
    t.integer 'case_note_id'
    t.integer 'domain_group_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string 'attachments', default: [], array: true
  end

  add_index 'case_note_domain_groups', ['case_note_id'], name: 'index_case_note_domain_groups_on_case_note_id', using: :btree
  add_index 'case_note_domain_groups', ['domain_group_id'], name: 'index_case_note_domain_groups_on_domain_group_id', using: :btree

  create_table 'case_notes', force: :cascade do |t|
    t.string 'attendee', default: ''
    t.datetime 'meeting_date'
    t.integer 'assessment_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer 'client_id'
    t.string 'interaction_type', default: ''
    t.boolean 'custom', default: false
    t.text 'note', default: ''
    t.integer 'custom_assessment_setting_id'
    t.string 'selected_domain_group_ids', default: [], array: true
    t.integer 'family_id'
    t.boolean 'draft', default: false, null: false
    t.datetime 'last_auto_save_at'
    t.string 'attachments', default: [], array: true
  end

  add_index 'case_notes', ['assessment_id'], name: 'index_case_notes_on_assessment_id', using: :btree
  add_index 'case_notes', ['client_id'], name: 'index_case_notes_on_client_id', using: :btree
  add_index 'case_notes', ['custom_assessment_setting_id'], name: 'index_case_notes_on_custom_assessment_setting_id', using: :btree
  add_index 'case_notes', ['family_id'], name: 'index_case_notes_on_family_id', using: :btree
  add_index 'case_notes', ['last_auto_save_at', 'draft'], name: 'index_case_notes_on_last_auto_save_at_and_draft', using: :btree

  create_table 'case_notes_custom_field_properties', force: :cascade do |t|
    t.integer 'case_note_id', null: false
    t.integer 'custom_field_id', null: false
    t.jsonb 'properties', default: {}
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.integer 'custom_formable_id'
    t.string 'custom_formable_type'
  end

  add_index 'case_notes_custom_field_properties', ['case_note_id'], name: 'index_case_notes_custom_field_properties_on_case_note_id', using: :btree
  add_index 'case_notes_custom_field_properties', ['custom_field_id'], name: 'index_custom_field_properties_on_case_notes_custom_field_id', using: :btree
  add_index 'case_notes_custom_field_properties', ['custom_formable_id', 'custom_formable_type'], name: 'index_case_notes_custom_field_properties_on_custom_formable', using: :btree

  create_table 'case_notes_custom_fields', force: :cascade do |t|
    t.datetime 'deleted_at'
    t.jsonb 'fields'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'case_worker_clients', force: :cascade do |t|
    t.integer 'user_id'
    t.integer 'client_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.datetime 'deleted_at'
  end

  add_index 'case_worker_clients', ['client_id'], name: 'index_case_worker_clients_on_client_id', using: :btree
  add_index 'case_worker_clients', ['deleted_at'], name: 'index_case_worker_clients_on_deleted_at', using: :btree
  add_index 'case_worker_clients', ['user_id'], name: 'index_case_worker_clients_on_user_id', using: :btree

  create_table 'case_worker_communities', force: :cascade do |t|
    t.integer 'user_id'
    t.integer 'community_id'
    t.datetime 'deleted_at'
  end

  add_index 'case_worker_communities', ['community_id', 'user_id'], name: 'index_case_worker_communities_on_community_id_and_user_id', using: :btree
  add_index 'case_worker_communities', ['community_id'], name: 'index_case_worker_communities_on_community_id', using: :btree
  add_index 'case_worker_communities', ['deleted_at'], name: 'index_case_worker_communities_on_deleted_at', using: :btree
  add_index 'case_worker_communities', ['user_id'], name: 'index_case_worker_communities_on_user_id', using: :btree

  create_table 'case_worker_families', force: :cascade do |t|
    t.integer 'user_id'
    t.integer 'family_id'
    t.datetime 'deleted_at'
  end

  add_index 'case_worker_families', ['deleted_at'], name: 'index_case_worker_families_on_deleted_at', using: :btree
  add_index 'case_worker_families', ['family_id', 'user_id'], name: 'index_case_worker_families_on_family_id_and_user_id', using: :btree
  add_index 'case_worker_families', ['family_id'], name: 'index_case_worker_families_on_family_id', using: :btree
  add_index 'case_worker_families', ['user_id'], name: 'index_case_worker_families_on_user_id', using: :btree

  create_table 'case_worker_tasks', force: :cascade do |t|
    t.integer 'user_id'
    t.integer 'task_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'case_worker_tasks', ['task_id'], name: 'index_case_worker_tasks_on_task_id', using: :btree
  add_index 'case_worker_tasks', ['user_id'], name: 'index_case_worker_tasks_on_user_id', using: :btree

  create_table 'cases', force: :cascade do |t|
    t.date 'start_date'
    t.string 'carer_names', default: ''
    t.string 'carer_address', default: ''
    t.string 'carer_phone_number', default: ''
    t.float 'support_amount', default: 0.0
    t.text 'support_note', default: ''
    t.text 'case_type', default: 'EC'
    t.boolean 'exited', default: false
    t.date 'exit_date'
    t.text 'exit_note', default: ''
    t.integer 'user_id'
    t.integer 'client_id'
    t.integer 'family_id'
    t.integer 'partner_id'
    t.integer 'province_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.boolean 'family_preservation', default: false
    t.string 'status', default: ''
    t.date 'placement_date'
    t.date 'initial_assessment_date'
    t.float 'case_length'
    t.date 'case_conference_date'
    t.float 'time_in_care'
    t.boolean 'exited_from_cif', default: false
    t.boolean 'current', default: true
    t.datetime 'deleted_at'
  end

  add_index 'cases', ['case_type'], name: 'index_cases_on_case_type', using: :btree
  add_index 'cases', ['client_id'], name: 'index_cases_on_client_id', using: :btree
  add_index 'cases', ['deleted_at'], name: 'index_cases_on_deleted_at', using: :btree
  add_index 'cases', ['exited'], name: 'index_cases_on_exited', using: :btree
  add_index 'cases', ['family_id'], name: 'index_cases_on_family_id', using: :btree
  add_index 'cases', ['partner_id'], name: 'index_cases_on_partner_id', using: :btree
  add_index 'cases', ['province_id'], name: 'index_cases_on_province_id', using: :btree
  add_index 'cases', ['user_id'], name: 'index_cases_on_user_id', using: :btree

  create_table 'changelog_types', force: :cascade do |t|
    t.integer 'changelog_id'
    t.string 'change_type', default: ''
    t.string 'description', default: ''
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'changelog_types', ['changelog_id'], name: 'index_changelog_types_on_changelog_id', using: :btree

  create_table 'changelogs', force: :cascade do |t|
    t.string 'change_version', default: ''
    t.string 'description', default: ''
    t.integer 'user_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'changelogs', ['user_id'], name: 'index_changelogs_on_user_id', using: :btree

  create_table 'children_plans', force: :cascade do |t|
    t.string 'name', default: ''
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'cities', force: :cascade do |t|
    t.string 'name'
    t.string 'code'
    t.integer 'province_id'
  end

  add_index 'cities', ['province_id'], name: 'index_cities_on_province_id', using: :btree

  create_table 'client_client_types', force: :cascade do |t|
    t.integer 'client_id'
    t.integer 'client_type_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'client_client_types', ['client_id'], name: 'index_client_client_types_on_client_id', using: :btree
  add_index 'client_client_types', ['client_type_id'], name: 'index_client_client_types_on_client_type_id', using: :btree

  create_table 'client_custom_data', force: :cascade do |t|
    t.integer 'client_id'
    t.jsonb 'properties'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.integer 'custom_data_id'
  end

  add_index 'client_custom_data', ['client_id'], name: 'index_client_custom_data_on_client_id', using: :btree

  create_table 'client_enrollment_trackings', force: :cascade do |t|
    t.jsonb 'properties', default: {}
    t.integer 'client_enrollment_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.integer 'tracking_id'
  end

  add_index 'client_enrollment_trackings', ['client_enrollment_id'], name: 'index_client_enrollment_trackings_on_client_enrollment_id', using: :btree
  add_index 'client_enrollment_trackings', ['tracking_id'], name: 'index_client_enrollment_trackings_on_tracking_id', using: :btree

  create_table 'client_enrollments', force: :cascade do |t|
    t.jsonb 'properties', default: {}
    t.string 'status', default: 'Active'
    t.integer 'client_id'
    t.integer 'program_stream_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.date 'enrollment_date'
    t.datetime 'deleted_at'
  end

  add_index 'client_enrollments', ['client_id'], name: 'index_client_enrollments_on_client_id', using: :btree
  add_index 'client_enrollments', ['deleted_at'], name: 'index_client_enrollments_on_deleted_at', using: :btree
  add_index 'client_enrollments', ['program_stream_id'], name: 'index_client_enrollments_on_program_stream_id', using: :btree

  create_table 'client_interviewees', force: :cascade do |t|
    t.integer 'client_id'
    t.integer 'interviewee_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'client_interviewees', ['client_id'], name: 'index_client_interviewees_on_client_id', using: :btree
  add_index 'client_interviewees', ['interviewee_id'], name: 'index_client_interviewees_on_interviewee_id', using: :btree

  create_table 'client_needs', force: :cascade do |t|
    t.integer 'rank'
    t.integer 'client_id'
    t.integer 'need_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'client_needs', ['client_id'], name: 'index_client_needs_on_client_id', using: :btree
  add_index 'client_needs', ['need_id'], name: 'index_client_needs_on_need_id', using: :btree

  create_table 'client_problems', force: :cascade do |t|
    t.integer 'rank'
    t.integer 'client_id'
    t.integer 'problem_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'client_problems', ['client_id'], name: 'index_client_problems_on_client_id', using: :btree
  add_index 'client_problems', ['problem_id'], name: 'index_client_problems_on_problem_id', using: :btree

  create_table 'client_quantitative_cases', force: :cascade do |t|
    t.integer 'quantitative_case_id'
    t.integer 'client_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string 'type', default: 'ClientQuantitativeCase'
    t.text 'content'
    t.integer 'quantitative_type_id'
  end

  add_index 'client_quantitative_cases', ['client_id'], name: 'index_client_quantitative_cases_on_client_id', using: :btree
  add_index 'client_quantitative_cases', ['quantitative_case_id'], name: 'index_client_quantitative_cases_on_quantitative_case_id', using: :btree
  add_index 'client_quantitative_cases', ['quantitative_type_id'], name: 'index_client_quantitative_cases_on_quantitative_type_id', using: :btree
  add_index 'client_quantitative_cases', ['type'], name: 'index_client_quantitative_cases_on_type', using: :btree

  create_table 'client_right_government_forms', force: :cascade do |t|
    t.integer 'government_form_id'
    t.integer 'client_right_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_index 'client_right_government_forms', ['client_right_id'], name: 'index_client_right_government_forms_on_client_right_id', using: :btree
  add_index 'client_right_government_forms', ['government_form_id'], name: 'index_client_right_government_forms_on_government_form_id', using: :btree

  create_table 'client_rights', force: :cascade do |t|
    t.string 'name', default: ''
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'client_type_government_forms', force: :cascade do |t|
    t.integer 'client_type_id'
    t.integer 'government_form_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'client_type_government_forms', ['client_type_id'], name: 'index_client_type_government_forms_on_client_type_id', using: :btree
  add_index 'client_type_government_forms', ['government_form_id'], name: 'index_client_type_government_forms_on_government_form_id', using: :btree

  create_table 'client_types', force: :cascade do |t|
    t.string 'name', default: ''
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  create_table 'clients', force: :cascade do |t|
    t.string 'code', default: ''
    t.string 'given_name', default: ''
    t.string 'family_name', default: ''
    t.string 'gender', default: ''
    t.date 'date_of_birth'
    t.string 'status', default: 'Referred'
    t.date 'initial_referral_date'
    t.string 'referral_phone', default: ''
    t.integer 'birth_province_id'
    t.integer 'received_by_id'
    t.integer 'followed_up_by_id'
    t.date 'follow_up_date'
    t.string 'current_address', default: ''
    t.string 'school_name', default: ''
    t.string 'school_grade', default: ''
    t.boolean 'has_been_in_orphanage'
    t.boolean 'able', default: false
    t.boolean 'has_been_in_government_care'
    t.text 'relevant_referral_information', default: ''
    t.string 'archive_state', default: ''
    t.text 'rejected_note', default: ''
    t.integer 'province_id'
    t.integer 'referral_source_id'
    t.integer 'user_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.boolean 'completed', default: false
    t.text 'reason_for_referral', default: ''
    t.boolean 'is_receiving_additional_benefits', default: false
    t.text 'background', default: ''
    t.integer 'grade'
    t.string 'slug'
    t.string 'able_state', default: ''
    t.integer 'donor_id'
    t.string 'local_given_name', default: ''
    t.string 'local_family_name', default: ''
    t.string 'kid_id', default: ''
    t.string 'house_number', default: ''
    t.string 'street_number', default: ''
    t.string 'old_village', default: ''
    t.string 'old_commune', default: ''
    t.string 'archive_district', default: ''
    t.string 'live_with', default: ''
    t.integer 'id_poor'
    t.integer 'rice_support', default: 0
    t.text 'exit_note', default: ''
    t.date 'exit_date'
    t.date 'accepted_date'
    t.string 'gov_city', default: ''
    t.string 'gov_commune', default: ''
    t.string 'gov_district', default: ''
    t.date 'gov_date'
    t.string 'gov_village_code', default: ''
    t.string 'gov_client_code', default: ''
    t.string 'gov_interview_village', default: ''
    t.string 'gov_interview_commune', default: ''
    t.string 'gov_interview_district', default: ''
    t.string 'gov_interview_city', default: ''
    t.string 'gov_caseworker_name', default: ''
    t.string 'gov_caseworker_phone', default: ''
    t.string 'gov_carer_name', default: ''
    t.string 'gov_carer_relationship', default: ''
    t.string 'gov_carer_home', default: ''
    t.string 'gov_carer_street', default: ''
    t.string 'gov_carer_village', default: ''
    t.string 'gov_carer_commune', default: ''
    t.string 'gov_carer_district', default: ''
    t.string 'gov_carer_city', default: ''
    t.string 'gov_carer_phone', default: ''
    t.string 'gov_information_source', default: ''
    t.text 'gov_referral_reason', default: ''
    t.text 'gov_guardian_comment', default: ''
    t.text 'gov_caseworker_comment', default: ''
    t.integer 'district_id'
    t.string 'telephone_number', default: ''
    t.string 'name_of_referee', default: ''
    t.string 'main_school_contact', default: ''
    t.string 'rated_for_id_poor', default: ''
    t.string 'what3words', default: ''
    t.string 'exit_reasons', default: [], array: true
    t.string 'exit_circumstance', default: ''
    t.string 'other_info_of_exit', default: ''
    t.string 'suburb', default: ''
    t.string 'description_house_landmark', default: ''
    t.string 'directions', default: ''
    t.string 'street_line1', default: ''
    t.string 'street_line2', default: ''
    t.string 'plot', default: ''
    t.string 'road', default: ''
    t.string 'postal_code', default: ''
    t.integer 'subdistrict_id'
    t.integer 'township_id'
    t.integer 'state_id'
    t.string 'country_origin', default: ''
    t.integer 'commune_id'
    t.integer 'village_id'
    t.string 'profile'
    t.integer 'referral_source_category_id'
    t.string 'archived_slug'
    t.integer 'assessments_count', default: 0, null: false
    t.integer 'current_family_id'
    t.boolean 'outside', default: false
    t.string 'outside_address', default: ''
    t.string 'address_type', default: ''
    t.string 'client_phone', default: ''
    t.string 'phone_owner', default: ''
    t.string 'client_email', default: ''
    t.string 'referee_relationship', default: ''
    t.integer 'referee_id'
    t.integer 'carer_id'
    t.string 'nickname', default: ''
    t.string 'relation_to_referee', default: ''
    t.boolean 'concern_is_outside', default: false
    t.string 'concern_outside_address', default: ''
    t.integer 'concern_province_id'
    t.integer 'concern_district_id'
    t.integer 'concern_commune_id'
    t.integer 'concern_village_id'
    t.string 'concern_street', default: ''
    t.string 'concern_house', default: ''
    t.string 'concern_address', default: ''
    t.string 'concern_address_type', default: ''
    t.string 'concern_phone', default: ''
    t.string 'concern_phone_owner', default: ''
    t.string 'concern_email', default: ''
    t.string 'concern_email_owner', default: ''
    t.string 'concern_location', default: ''
    t.boolean 'concern_same_as_client', default: false
    t.string 'location_description', default: ''
    t.string 'phone_counselling_summary', default: ''
    t.string 'presented_id'
    t.string 'id_number'
    t.string 'other_phone_number'
    t.string 'brsc_branch'
    t.string 'current_island'
    t.string 'current_street'
    t.string 'current_po_box'
    t.string 'current_city'
    t.string 'current_settlement'
    t.string 'current_resident_own_or_rent'
    t.string 'current_household_type'
    t.string 'island2'
    t.string 'street2'
    t.string 'po_box2'
    t.string 'city2'
    t.string 'settlement2'
    t.string 'resident_own_or_rent2'
    t.string 'household_type2'
    t.string 'legacy_brcs_id'
    t.boolean 'whatsapp', default: false
    t.string 'global_id'
    t.string 'external_id'
    t.string 'external_id_display'
    t.string 'mosvy_number'
    t.string 'external_case_worker_name'
    t.string 'external_case_worker_id'
    t.boolean 'other_phone_whatsapp', default: false
    t.string 'preferred_language', default: 'English'
    t.boolean 'national_id', default: false, null: false
    t.boolean 'birth_cert', default: false, null: false
    t.boolean 'family_book', default: false, null: false
    t.boolean 'passport', default: false, null: false
    t.boolean 'travel_doc', default: false, null: false
    t.boolean 'referral_doc', default: false, null: false
    t.boolean 'local_consent', default: false, null: false
    t.boolean 'police_interview', default: false, null: false
    t.boolean 'other_legal_doc', default: false, null: false
    t.string 'national_id_files', default: [], array: true
    t.string 'birth_cert_files', default: [], array: true
    t.string 'family_book_files', default: [], array: true
    t.string 'passport_files', default: [], array: true
    t.string 'travel_doc_files', default: [], array: true
    t.string 'referral_doc_files', default: [], array: true
    t.string 'local_consent_files', default: [], array: true
    t.string 'police_interview_files', default: [], array: true
    t.string 'other_legal_doc_files', default: [], array: true
    t.boolean 'referred_external', default: false
    t.string 'marital_status'
    t.string 'nationality'
    t.string 'ethnicity'
    t.string 'location_of_concern'
    t.string 'type_of_trafficking'
    t.text 'education_background'
    t.string 'department'
    t.string 'neighbor_name'
    t.string 'neighbor_phone'
    t.string 'dosavy_name'
    t.string 'dosavy_phone'
    t.string 'chief_commune_name'
    t.string 'chief_commune_phone'
    t.string 'chief_village_name'
    t.string 'chief_village_phone'
    t.string 'ccwc_name'
    t.string 'ccwc_phone'
    t.string 'legal_team_name'
    t.string 'legal_representative_name'
    t.string 'legal_team_phone'
    t.string 'other_agency_name'
    t.string 'other_representative_name'
    t.string 'other_agency_phone'
    t.string 'national_id_number'
    t.string 'passport_number'
    t.string 'locality'
    t.string 'ngo_partner_files', default: [], array: true
    t.string 'mosavy_files', default: [], array: true
    t.string 'dosavy_files', default: [], array: true
    t.string 'msdhs_files', default: [], array: true
    t.string 'complain_files', default: [], array: true
    t.string 'warrant_files', default: [], array: true
    t.string 'verdict_files', default: [], array: true
    t.string 'referral_doc_option'
    t.string 'short_form_of_ocdm_option'
    t.string 'short_form_of_ocdm_files', default: [], array: true
    t.string 'short_form_of_mosavy_dosavy_option'
    t.string 'short_form_of_mosavy_dosavy_files', default: [], array: true
    t.string 'detail_form_of_mosavy_dosavy_option'
    t.string 'detail_form_of_mosavy_dosavy_files', default: [], array: true
    t.string 'short_form_of_judicial_police_option'
    t.string 'short_form_of_judicial_police_files', default: [], array: true
    t.boolean 'screening_interview_form', default: false
    t.string 'detail_form_of_judicial_police_option'
    t.string 'detail_form_of_judicial_police_files', default: [], array: true
    t.string 'screening_interview_form_option'
    t.string 'screening_interview_form_files', default: [], array: true
    t.boolean 'ngo_partner', default: false
    t.boolean 'mosavy', default: false
    t.boolean 'dosavy', default: false
    t.boolean 'msdhs', default: false
    t.boolean 'complain', default: false
    t.boolean 'warrant', default: false
    t.boolean 'verdict', default: false
    t.boolean 'short_form_of_ocdm', default: false
    t.boolean 'short_form_of_mosavy_dosavy', default: false
    t.boolean 'detail_form_of_mosavy_dosavy', default: false
    t.boolean 'short_form_of_judicial_police', default: false
    t.boolean 'letter_from_immigration_police', default: false
    t.string 'letter_from_immigration_police_files', default: [], array: true
    t.boolean 'for_testing', default: false
    t.datetime 'arrival_at'
    t.string 'flight_nb'
    t.string 'from_referral_id'
    t.date 'synced_date'
    t.integer 'referral_count', default: 0
    t.datetime 'deleted_at'
    t.integer 'archived_by_id'
    t.integer 'city_id'
    t.boolean 'has_disability', default: false
    t.string 'disability_specification'
  end

  add_index 'clients', ['birth_province_id'], name: 'index_clients_on_birth_province_id', using: :btree
  add_index 'clients', ['carer_id'], name: 'index_clients_on_carer_id', using: :btree
  add_index 'clients', ['city_id'], name: 'index_clients_on_city_id', using: :btree
  add_index 'clients', ['commune_id'], name: 'index_clients_on_commune_id', using: :btree
  add_index 'clients', ['concern_commune_id'], name: 'index_clients_on_concern_commune_id', using: :btree
  add_index 'clients', ['concern_district_id'], name: 'index_clients_on_concern_district_id', using: :btree
  add_index 'clients', ['concern_province_id'], name: 'index_clients_on_concern_province_id', using: :btree
  add_index 'clients', ['concern_village_id'], name: 'index_clients_on_concern_village_id', using: :btree
  add_index 'clients', ['current_family_id'], name: 'index_clients_on_current_family_id', using: :btree
  add_index 'clients', ['deleted_at'], name: 'index_clients_on_deleted_at', using: :btree
  add_index 'clients', ['district_id'], name: 'index_clients_on_district_id', using: :btree
  add_index 'clients', ['donor_id'], name: 'index_clients_on_donor_id', using: :btree
  add_index 'clients', ['external_case_worker_id'], name: 'index_clients_on_external_case_worker_id', using: :btree
  add_index 'clients', ['external_id'], name: 'index_clients_on_external_id', using: :btree
  add_index 'clients', ['followed_up_by_id'], name: 'index_clients_on_followed_up_by_id', using: :btree
  add_index 'clients', ['global_id'], name: 'index_clients_on_global_id', using: :btree
  add_index 'clients', ['kid_id'], name: 'index_clients_on_kid_id', using: :btree
  add_index 'clients', ['legacy_brcs_id'], name: 'index_clients_on_legacy_brcs_id', using: :btree
  add_index 'clients', ['mosvy_number'], name: 'index_clients_on_mosvy_number', using: :btree
  add_index 'clients', ['national_id'], name: 'index_clients_on_national_id', using: :btree
  add_index 'clients', ['presented_id'], name: 'index_clients_on_presented_id', using: :btree
  add_index 'clients', ['province_id'], name: 'index_clients_on_province_id', using: :btree
  add_index 'clients', ['received_by_id'], name: 'index_clients_on_received_by_id', using: :btree
  add_index 'clients', ['referee_id'], name: 'index_clients_on_referee_id', using: :btree
  add_index 'clients', ['referral_source_category_id'], name: 'index_clients_on_referral_source_category_id', using: :btree
  add_index 'clients', ['referral_source_id'], name: 'index_clients_on_referral_source_id', using: :btree
  add_index 'clients', ['slug'], name: 'index_clients_on_slug', unique: true, using: :btree
  add_index 'clients', ['state_id'], name: 'index_clients_on_state_id', using: :btree
  add_index 'clients', ['subdistrict_id'], name: 'index_clients_on_subdistrict_id', using: :btree
  add_index 'clients', ['synced_date'], name: 'index_clients_on_synced_date', using: :btree
  add_index 'clients', ['township_id'], name: 'index_clients_on_township_id', using: :btree
  add_index 'clients', ['user_id'], name: 'index_clients_on_user_id', using: :btree
  add_index 'clients', ['village_id'], name: 'index_clients_on_village_id', using: :btree

  create_table 'clients_quantitative_cases', force: :cascade do |t|
    t.integer 'client_id'
    t.integer 'quantitative_case_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'clients_quantitative_cases', ['client_id'], name: 'index_clients_quantitative_cases_on_client_id', using: :btree
  add_index 'clients_quantitative_cases', ['quantitative_case_id'], name: 'index_clients_quantitative_cases_on_quantitative_case_id', using: :btree

  create_table 'communes', force: :cascade do |t|
    t.string 'code', default: ''
    t.string 'name_kh', default: ''
    t.string 'name_en', default: ''
    t.integer 'district_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string 'district_type'
  end

  add_index 'communes', ['district_id'], name: 'index_communes_on_district_id', using: :btree

  create_table 'communities', force: :cascade do |t|
    t.integer 'received_by_id'
    t.date 'initial_referral_date'
    t.integer 'referral_source_id'
    t.integer 'referral_source_category_id'
    t.string 'name', default: ''
    t.string 'name_en'
    t.date 'formed_date'
    t.integer 'province_id'
    t.integer 'district_id'
    t.integer 'commune_id'
    t.integer 'village_id'
    t.string 'representative_name'
    t.string 'gender'
    t.string 'role'
    t.string 'phone_number'
    t.text 'relevant_information'
    t.string 'documents', default: [], array: true
    t.datetime 'deleted_at'
    t.string 'status', default: 'accepted', null: false
    t.integer 'user_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer 'city_id'
    t.integer 'subdistrict_id'
  end

  add_index 'communities', ['city_id'], name: 'index_communities_on_city_id', using: :btree
  add_index 'communities', ['commune_id'], name: 'index_communities_on_commune_id', using: :btree
  add_index 'communities', ['district_id'], name: 'index_communities_on_district_id', using: :btree
  add_index 'communities', ['province_id'], name: 'index_communities_on_province_id', using: :btree
  add_index 'communities', ['received_by_id'], name: 'index_communities_on_received_by_id', using: :btree
  add_index 'communities', ['referral_source_category_id'], name: 'index_communities_on_referral_source_category_id', using: :btree
  add_index 'communities', ['referral_source_id'], name: 'index_communities_on_referral_source_id', using: :btree
  add_index 'communities', ['subdistrict_id'], name: 'index_communities_on_subdistrict_id', using: :btree
  add_index 'communities', ['user_id'], name: 'index_communities_on_user_id', using: :btree
  add_index 'communities', ['village_id'], name: 'index_communities_on_village_id', using: :btree

  create_table 'community_donors', force: :cascade do |t|
    t.integer 'donor_id'
    t.integer 'community_id'
  end

  add_index 'community_donors', ['community_id'], name: 'index_community_donors_on_community_id', using: :btree
  add_index 'community_donors', ['donor_id'], name: 'index_community_donors_on_donor_id', using: :btree

  create_table 'community_members', force: :cascade do |t|
    t.string 'name', default: ''
    t.integer 'community_id'
    t.integer 'family_id'
    t.string 'gender'
    t.string 'role'
    t.integer 'adule_male_count'
    t.integer 'adule_female_count'
    t.integer 'kid_male_count'
    t.integer 'kid_female_count'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'community_members', ['community_id'], name: 'index_community_members_on_community_id', using: :btree
  add_index 'community_members', ['family_id'], name: 'index_community_members_on_family_id', using: :btree

  create_table 'community_quantitative_cases', force: :cascade do |t|
    t.integer 'quantitative_case_id'
    t.integer 'community_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string 'type', default: 'CommunityQuantitativeCase'
    t.text 'content'
    t.integer 'quantitative_type_id'
  end

  add_index 'community_quantitative_cases', ['community_id', 'quantitative_case_id'], name: 'index_on_community_id_and_quantitative_case_id', using: :btree
  add_index 'community_quantitative_cases', ['community_id'], name: 'index_community_quantitative_cases_on_community_id', using: :btree
  add_index 'community_quantitative_cases', ['quantitative_case_id'], name: 'index_community_quantitative_cases_on_quantitative_case_id', using: :btree
  add_index 'community_quantitative_cases', ['quantitative_type_id'], name: 'index_community_quantitative_cases_on_quantitative_type_id', using: :btree
  add_index 'community_quantitative_cases', ['type'], name: 'index_community_quantitative_cases_on_type', using: :btree

  create_table 'custom_assessment_settings', force: :cascade do |t|
    t.string 'custom_assessment_name', default: 'Custom Assessment'
    t.integer 'max_custom_assessment', default: 6
    t.string 'custom_assessment_frequency', default: 'month'
    t.integer 'custom_age', default: 18
    t.integer 'setting_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.boolean 'enable_custom_assessment', default: false
  end

  add_index 'custom_assessment_settings', ['setting_id'], name: 'index_custom_assessment_settings_on_setting_id', using: :btree

  create_table 'custom_data', force: :cascade do |t|
    t.jsonb 'fields', default: {}
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'custom_field_permissions', force: :cascade do |t|
    t.integer 'user_id'
    t.integer 'custom_field_id'
    t.boolean 'readable', default: true
    t.boolean 'editable', default: true
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_index 'custom_field_permissions', ['custom_field_id', 'user_id'], name: 'index_custom_field_permissions_on_custom_field_id_and_user_id', using: :btree
  add_index 'custom_field_permissions', ['custom_field_id'], name: 'index_custom_field_permissions_on_custom_field_id', using: :btree
  add_index 'custom_field_permissions', ['user_id'], name: 'index_custom_field_permissions_on_user_id', using: :btree

  create_table 'custom_field_properties', force: :cascade do |t|
    t.jsonb 'properties', default: {}
    t.string 'custom_formable_type'
    t.integer 'custom_formable_id'
    t.integer 'custom_field_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.jsonb 'attachments'
    t.integer 'user_id'
  end

  add_index 'custom_field_properties', ['custom_field_id'], name: 'index_custom_field_properties_on_custom_field_id', using: :btree
  add_index 'custom_field_properties', ['custom_formable_id', 'custom_formable_type'], name: 'index_on_custom_formable_id_and_custom_formable_type', using: :btree
  add_index 'custom_field_properties', ['custom_formable_id'], name: 'index_custom_field_properties_on_custom_formable_id', using: :btree
  add_index 'custom_field_properties', ['user_id'], name: 'index_custom_field_properties_on_user_id', using: :btree

  create_table 'custom_fields', force: :cascade do |t|
    t.string 'entity_type', default: ''
    t.text 'properties', default: ''
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'form_title', default: ''
    t.string 'frequency', default: ''
    t.integer 'time_of_frequency', default: 0
    t.string 'ngo_name', default: ''
    t.jsonb 'fields'
    t.boolean 'hidden', default: false
    t.string 'allowed_edit_until'
  end

  add_index 'custom_fields', ['form_title'], name: 'index_custom_fields_on_form_title', using: :btree

  create_table 'departments', force: :cascade do |t|
    t.string 'name', default: ''
    t.text 'description', default: ''
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer 'users_count', default: 0
  end

  create_table 'developmental_marker_screening_assessments', force: :cascade do |t|
    t.integer 'developmental_marker_id'
    t.integer 'screening_assessment_id'
    t.boolean 'question_1', default: true
    t.boolean 'question_2', default: true
    t.boolean 'question_3', default: true
    t.boolean 'question_4', default: true
  end

  add_index 'developmental_marker_screening_assessments', ['developmental_marker_id'], name: 'index_marker_screening_assessments_on_marker_id', using: :btree
  add_index 'developmental_marker_screening_assessments', ['screening_assessment_id'], name: 'index_marker_screening_assessments_on_screening_assessment_id', using: :btree

  create_table 'developmental_markers', force: :cascade do |t|
    t.string 'name'
    t.string 'name_local'
    t.string 'short_description'
    t.string 'short_description_local'
    t.string 'question_1'
    t.string 'question_1_field'
    t.string 'question_1_illustation'
    t.string 'question_1_local'
    t.string 'question_2'
    t.string 'question_2_field'
    t.string 'question_2_illustation'
    t.string 'question_2_local'
    t.string 'question_3'
    t.string 'question_3_field'
    t.string 'question_3_illustation'
    t.string 'question_3_local'
    t.string 'question_4'
    t.string 'question_4_field'
    t.string 'question_4_illustation'
    t.string 'question_4_local'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_index 'developmental_markers', ['name'], name: 'index_developmental_markers_on_name', using: :btree

  create_table 'districts', force: :cascade do |t|
    t.string 'name'
    t.integer 'province_id'
    t.string 'code', default: ''
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer 'city_id'
  end

  add_index 'districts', ['city_id'], name: 'index_districts_on_city_id', using: :btree
  add_index 'districts', ['province_id'], name: 'index_districts_on_province_id', using: :btree

  create_table 'domain_groups', force: :cascade do |t|
    t.string 'name', default: ''
    t.text 'description', default: ''
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer 'domains_count', default: 0
  end

  create_table 'domain_program_streams', force: :cascade do |t|
    t.integer 'program_stream_id'
    t.integer 'domain_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.datetime 'deleted_at'
  end

  add_index 'domain_program_streams', ['deleted_at'], name: 'index_domain_program_streams_on_deleted_at', using: :btree
  add_index 'domain_program_streams', ['domain_id'], name: 'index_domain_program_streams_on_domain_id', using: :btree
  add_index 'domain_program_streams', ['program_stream_id'], name: 'index_domain_program_streams_on_program_stream_id', using: :btree

  create_table 'domains', force: :cascade do |t|
    t.string 'name', default: ''
    t.string 'identity', default: ''
    t.text 'description', default: ''
    t.integer 'domain_group_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer 'tasks_count', default: 0
    t.string 'score_1_color', default: 'danger'
    t.string 'score_2_color', default: 'warning'
    t.string 'score_3_color', default: 'info'
    t.string 'score_4_color', default: 'primary'
    t.text 'score_1_definition', default: ''
    t.text 'score_2_definition', default: ''
    t.text 'score_3_definition', default: ''
    t.text 'score_4_definition', default: ''
    t.boolean 'custom_domain', default: false
    t.text 'local_description', default: ''
    t.text 'score_1_local_definition', default: ''
    t.text 'score_2_local_definition', default: ''
    t.text 'score_3_local_definition', default: ''
    t.text 'score_4_local_definition', default: ''
    t.integer 'custom_assessment_setting_id'
    t.string 'score_5_color', default: ''
    t.string 'score_6_color', default: ''
    t.string 'score_7_color', default: ''
    t.string 'score_8_color', default: ''
    t.string 'score_9_color', default: ''
    t.string 'score_10_color', default: ''
    t.text 'score_5_definition', default: ''
    t.text 'score_6_definition', default: ''
    t.text 'score_7_definition', default: ''
    t.text 'score_8_definition', default: ''
    t.text 'score_9_definition', default: ''
    t.text 'score_10_definition', default: ''
    t.text 'score_5_local_definition', default: ''
    t.text 'score_6_local_definition', default: ''
    t.text 'score_7_local_definition', default: ''
    t.text 'score_8_local_definition', default: ''
    t.text 'score_9_local_definition', default: ''
    t.text 'score_10_local_definition', default: ''
    t.string 'domain_type'
  end

  add_index 'domains', ['custom_assessment_setting_id'], name: 'index_domains_on_custom_assessment_setting_id', using: :btree
  add_index 'domains', ['domain_group_id'], name: 'index_domains_on_domain_group_id', using: :btree
  add_index 'domains', ['domain_type'], name: 'index_domains_on_domain_type', using: :btree
  add_index 'domains', ['name', 'identity', 'custom_assessment_setting_id', 'domain_type'], name: 'index_domains_on_name_identity_custom_setting_domain_type', unique: true, using: :btree

  create_table 'donor_families', force: :cascade do |t|
    t.integer 'donor_id'
    t.integer 'family_id'
  end

  add_index 'donor_families', ['donor_id'], name: 'index_donor_families_on_donor_id', using: :btree
  add_index 'donor_families', ['family_id'], name: 'index_donor_families_on_family_id', using: :btree

  create_table 'donor_organizations', force: :cascade do |t|
    t.integer 'donor_id'
    t.integer 'organization_id'
  end

  add_index 'donor_organizations', ['donor_id'], name: 'index_donor_organizations_on_donor_id', using: :btree
  add_index 'donor_organizations', ['organization_id'], name: 'index_donor_organizations_on_organization_id', using: :btree

  create_table 'donors', force: :cascade do |t|
    t.string 'name', default: ''
    t.text 'description', default: ''
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'code', default: ''
    t.string 'global_id', limit: 32, default: ''
  end

  add_index 'donors', ['global_id'], name: 'index_donors_on_global_id', using: :btree

  create_table 'enrollment_trackings', force: :cascade do |t|
    t.integer 'enrollment_id'
    t.integer 'tracking_id'
    t.jsonb 'properties', default: {}
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_index 'enrollment_trackings', ['enrollment_id'], name: 'index_enrollment_trackings_on_enrollment_id', using: :btree
  add_index 'enrollment_trackings', ['tracking_id'], name: 'index_enrollment_trackings_on_tracking_id', using: :btree

  create_table 'enrollments', force: :cascade do |t|
    t.jsonb 'properties', default: {}
    t.string 'status', default: 'Active'
    t.date 'enrollment_date'
    t.datetime 'deleted_at'
    t.string 'programmable_type'
    t.integer 'programmable_id'
    t.integer 'program_stream_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_index 'enrollments', ['deleted_at'], name: 'index_enrollments_on_deleted_at', using: :btree
  add_index 'enrollments', ['program_stream_id'], name: 'index_enrollments_on_program_stream_id', using: :btree
  add_index 'enrollments', ['programmable_id', 'programmable_type'], name: 'index_enrollments_on_programmable_id_and_programmable_type', using: :btree
  add_index 'enrollments', ['programmable_id'], name: 'index_enrollments_on_programmable_id', using: :btree

  create_table 'enter_ngo_users', force: :cascade do |t|
    t.integer 'user_id'
    t.integer 'enter_ngo_id'
  end

  add_index 'enter_ngo_users', ['enter_ngo_id'], name: 'index_enter_ngo_users_on_enter_ngo_id', using: :btree
  add_index 'enter_ngo_users', ['user_id'], name: 'index_enter_ngo_users_on_user_id', using: :btree

  create_table 'enter_ngos', force: :cascade do |t|
    t.date 'accepted_date'
    t.integer 'client_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.datetime 'deleted_at'
    t.integer 'acceptable_id'
    t.string 'acceptable_type'
    t.datetime 'follow_up_date'
    t.datetime 'initial_referral_date'
    t.integer 'received_by_id'
    t.integer 'followed_up_by_id'
  end

  add_index 'enter_ngos', ['acceptable_id', 'acceptable_type'], name: 'index_enter_ngos_on_acceptable_id_and_acceptable_type', using: :btree
  add_index 'enter_ngos', ['acceptable_id'], name: 'index_enter_ngos_on_acceptable_id', using: :btree
  add_index 'enter_ngos', ['client_id'], name: 'index_enter_ngos_on_client_id', using: :btree
  add_index 'enter_ngos', ['deleted_at'], name: 'index_enter_ngos_on_deleted_at', using: :btree
  add_index 'enter_ngos', ['follow_up_date'], name: 'index_enter_ngos_on_follow_up_date', using: :btree
  add_index 'enter_ngos', ['followed_up_by_id'], name: 'index_enter_ngos_on_followed_up_by_id', using: :btree
  add_index 'enter_ngos', ['initial_referral_date'], name: 'index_enter_ngos_on_initial_referral_date', using: :btree
  add_index 'enter_ngos', ['received_by_id'], name: 'index_enter_ngos_on_received_by_id', using: :btree

  create_table 'exit_ngos', force: :cascade do |t|
    t.integer 'client_id'
    t.string 'exit_circumstance', default: ''
    t.string 'other_info_of_exit', default: ''
    t.string 'exit_reasons', default: [], array: true
    t.text 'exit_note', default: ''
    t.date 'exit_date'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.datetime 'deleted_at'
    t.integer 'rejectable_id'
    t.string 'rejectable_type'
  end

  add_index 'exit_ngos', ['client_id'], name: 'index_exit_ngos_on_client_id', using: :btree
  add_index 'exit_ngos', ['deleted_at'], name: 'index_exit_ngos_on_deleted_at', using: :btree
  add_index 'exit_ngos', ['rejectable_id', 'rejectable_type'], name: 'index_exit_ngos_on_rejectable_id_and_rejectable_type', using: :btree
  add_index 'exit_ngos', ['rejectable_id'], name: 'index_exit_ngos_on_rejectable_id', using: :btree

  create_table 'external_system_global_identities', force: :cascade do |t|
    t.integer 'external_system_id'
    t.string 'global_id'
    t.string 'external_id'
    t.string 'client_slug'
    t.string 'organization_name'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_index 'external_system_global_identities', ['external_id'], name: 'index_external_system_global_identities_on_external_id', using: :btree
  add_index 'external_system_global_identities', ['external_system_id'], name: 'index_external_system_global_identities_on_external_system_id', using: :btree
  add_index 'external_system_global_identities', ['global_id'], name: 'index_external_system_global_identities_on_global_id', using: :btree

  create_table 'external_systems', force: :cascade do |t|
    t.string 'name'
    t.string 'url'
    t.string 'token'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_index 'external_systems', ['name'], name: 'index_external_systems_on_name', using: :btree

  create_table 'families', force: :cascade do |t|
    t.string 'code'
    t.string 'name', default: ''
    t.string 'address', default: ''
    t.text 'caregiver_information', default: ''
    t.integer 'significant_family_member_count', default: 1
    t.float 'household_income', default: 0.0
    t.boolean 'dependable_income', default: false
    t.integer 'female_children_count', default: 0
    t.integer 'male_children_count', default: 0
    t.integer 'female_adult_count', default: 0
    t.integer 'male_adult_count', default: 0
    t.string 'family_type', default: 'kinship'
    t.date 'contract_date'
    t.integer 'province_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer 'cases_count', default: 0
    t.string 'case_history', default: ''
    t.integer 'children', default: [], array: true
    t.string 'status', default: ''
    t.integer 'district_id'
    t.string 'old_commune', default: ''
    t.string 'old_village', default: ''
    t.string 'house', default: ''
    t.string 'street', default: ''
    t.integer 'commune_id'
    t.integer 'village_id'
    t.integer 'user_id'
    t.datetime 'deleted_at'
    t.integer 'received_by_id'
    t.integer 'followed_up_by_id'
    t.date 'initial_referral_date'
    t.date 'follow_up_date'
    t.integer 'referral_source_category_id'
    t.integer 'referral_source_id'
    t.string 'referee_contact'
    t.string 'name_en'
    t.string 'phone_number'
    t.string 'id_poor'
    t.text 'relevant_information'
    t.string 'referee_phone_number'
    t.string 'slug', default: ''
    t.string 'documents', default: [], array: true
    t.integer 'assessments_count', default: 0, null: false
    t.integer 'care_plans_count', default: 0, null: false
    t.integer 'city_id'
    t.integer 'subdistrict_id'
    t.string 'road'
    t.string 'plot'
    t.string 'postal_code'
  end

  add_index 'families', ['assessments_count'], name: 'index_families_on_assessments_count', using: :btree
  add_index 'families', ['care_plans_count'], name: 'index_families_on_care_plans_count', using: :btree
  add_index 'families', ['city_id'], name: 'index_families_on_city_id', using: :btree
  add_index 'families', ['commune_id'], name: 'index_families_on_commune_id', using: :btree
  add_index 'families', ['deleted_at'], name: 'index_families_on_deleted_at', using: :btree
  add_index 'families', ['district_id'], name: 'index_families_on_district_id', using: :btree
  add_index 'families', ['followed_up_by_id'], name: 'index_families_on_followed_up_by_id', using: :btree
  add_index 'families', ['province_id'], name: 'index_families_on_province_id', using: :btree
  add_index 'families', ['received_by_id'], name: 'index_families_on_received_by_id', using: :btree
  add_index 'families', ['referral_source_category_id'], name: 'index_families_on_referral_source_category_id', using: :btree
  add_index 'families', ['referral_source_id'], name: 'index_families_on_referral_source_id', using: :btree
  add_index 'families', ['subdistrict_id'], name: 'index_families_on_subdistrict_id', using: :btree
  add_index 'families', ['user_id'], name: 'index_families_on_user_id', using: :btree
  add_index 'families', ['village_id'], name: 'index_families_on_village_id', using: :btree

  create_table 'family_members', force: :cascade do |t|
    t.string 'adult_name', default: ''
    t.date 'date_of_birth'
    t.string 'occupation', default: ''
    t.string 'relation', default: ''
    t.integer 'family_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.boolean 'guardian', default: false
    t.string 'gender'
    t.text 'note'
    t.integer 'client_id'
    t.decimal 'monthly_income', precision: 10, scale: 2
  end

  add_index 'family_members', ['client_id'], name: 'index_family_members_on_client_id', using: :btree
  add_index 'family_members', ['family_id'], name: 'index_family_members_on_family_id', using: :btree

  create_table 'family_plans', force: :cascade do |t|
    t.string 'name', default: ''
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.integer 'priority'
  end

  create_table 'family_quantitative_cases', force: :cascade do |t|
    t.integer 'quantitative_case_id'
    t.integer 'family_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string 'type', default: 'FamilyQuantitativeCase'
    t.text 'content'
    t.integer 'quantitative_type_id'
  end

  add_index 'family_quantitative_cases', ['family_id', 'quantitative_case_id'], name: 'index_on_family_id_and_quantitative_case_id', using: :btree
  add_index 'family_quantitative_cases', ['family_id'], name: 'index_family_quantitative_cases_on_family_id', using: :btree
  add_index 'family_quantitative_cases', ['quantitative_case_id'], name: 'index_family_quantitative_cases_on_quantitative_case_id', using: :btree
  add_index 'family_quantitative_cases', ['quantitative_type_id'], name: 'index_family_quantitative_cases_on_quantitative_type_id', using: :btree
  add_index 'family_quantitative_cases', ['type'], name: 'index_family_quantitative_cases_on_type', using: :btree

  create_table 'family_referrals', force: :cascade do |t|
    t.string 'slug', default: ''
    t.date 'date_of_referral'
    t.string 'referred_to', default: ''
    t.string 'referred_from', default: ''
    t.text 'referral_reason', default: ''
    t.string 'name_of_referee', default: ''
    t.string 'referral_phone', default: ''
    t.string 'name_of_family', default: ''
    t.string 'ngo_name', default: ''
    t.integer 'referee_id'
    t.boolean 'saved', default: false
    t.string 'consent_form', default: [], array: true
    t.integer 'family_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'referral_status', limit: 15, default: 'Referred'
    t.integer 'referred_from_uid'
  end

  add_index 'family_referrals', ['family_id'], name: 'index_family_referrals_on_family_id', using: :btree
  add_index 'family_referrals', ['referee_id'], name: 'index_family_referrals_on_referee_id', using: :btree
  add_index 'family_referrals', ['referred_from_uid'], name: 'index_family_referrals_on_referred_from_uid', using: :btree

  create_table 'field_setting_translations', force: :cascade do |t|
    t.integer 'field_setting_id', null: false
    t.string 'locale', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'label'
  end

  add_index 'field_setting_translations', ['field_setting_id'], name: 'index_field_setting_translations_on_field_setting_id', using: :btree
  add_index 'field_setting_translations', ['locale'], name: 'index_field_setting_translations_on_locale', using: :btree

  create_table 'field_settings', force: :cascade do |t|
    t.string 'name', null: false
    t.string 'group', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'type', default: 'field', null: false
    t.boolean 'visible', default: true, null: false
    t.string 'current_label'
    t.boolean 'required', default: false
    t.string 'klass_name'
    t.string 'for_instances'
    t.boolean 'label_only', default: false
    t.boolean 'can_override_required', default: false
    t.string 'form_group_1'
    t.string 'form_group_2'
    t.string 'heading'
  end

  add_index 'field_settings', ['name', 'group'], name: 'index_field_settings_on_name_and_group', using: :btree
  add_index 'field_settings', ['name'], name: 'index_field_settings_on_name', using: :btree

  create_table 'form_builder_attachments', force: :cascade do |t|
    t.string 'name', default: ''
    t.jsonb 'file', default: []
    t.string 'form_buildable_type'
    t.integer 'form_buildable_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_index 'form_builder_attachments', ['form_buildable_id', 'form_buildable_type'], name: 'index_on_form_buildable_id_and_form_buildable_type', using: :btree
  add_index 'form_builder_attachments', ['form_buildable_id'], name: 'index_form_builder_attachments_on_form_buildable_id', using: :btree
  add_index 'form_builder_attachments', ['name'], name: 'index_form_builder_attachments_on_name', using: :btree

  create_table 'friendly_id_slugs', force: :cascade do |t|
    t.string 'slug', null: false
    t.integer 'sluggable_id', null: false
    t.string 'sluggable_type', limit: 50
    t.string 'scope'
    t.datetime 'created_at'
  end

  add_index 'friendly_id_slugs', ['slug', 'sluggable_type', 'scope'], name: 'index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope', unique: true, using: :btree
  add_index 'friendly_id_slugs', ['slug', 'sluggable_type'], name: 'index_friendly_id_slugs_on_slug_and_sluggable_type', using: :btree
  add_index 'friendly_id_slugs', ['sluggable_id'], name: 'index_friendly_id_slugs_on_sluggable_id', using: :btree
  add_index 'friendly_id_slugs', ['sluggable_type'], name: 'index_friendly_id_slugs_on_sluggable_type', using: :btree

  create_table 'global_identities', id: false, force: :cascade do |t|
    t.string 'ulid'
  end

  add_index 'global_identities', ['ulid'], name: 'index_global_identities_on_ulid', unique: true, using: :btree

  create_table 'global_identity_organizations', force: :cascade do |t|
    t.string 'global_id'
    t.integer 'organization_id'
    t.integer 'client_id'
  end

  add_index 'global_identity_organizations', ['client_id'], name: 'index_global_identity_organizations_on_client_id', using: :btree
  add_index 'global_identity_organizations', ['global_id'], name: 'index_global_identity_organizations_on_global_id', using: :btree
  add_index 'global_identity_organizations', ['organization_id'], name: 'index_global_identity_organizations_on_organization_id', using: :btree

  create_table 'global_identity_tmp', force: :cascade do |t|
    t.binary 'ulid'
    t.string 'ngo_name'
    t.integer 'client_id'
  end

  create_table 'global_services', id: false, force: :cascade do |t|
    t.uuid 'uuid'
  end

  add_index 'global_services', ['uuid'], name: 'index_global_services_on_uuid', unique: true, using: :btree

  create_table 'goals', force: :cascade do |t|
    t.text 'description', default: ''
    t.integer 'assessment_domain_id'
    t.integer 'domain_id'
    t.integer 'client_id'
    t.integer 'assessment_id'
    t.integer 'care_plan_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer 'family_id'
  end

  add_index 'goals', ['assessment_domain_id'], name: 'index_goals_on_assessment_domain_id', using: :btree
  add_index 'goals', ['assessment_id'], name: 'index_goals_on_assessment_id', using: :btree
  add_index 'goals', ['care_plan_id'], name: 'index_goals_on_care_plan_id', using: :btree
  add_index 'goals', ['client_id'], name: 'index_goals_on_client_id', using: :btree
  add_index 'goals', ['domain_id'], name: 'index_goals_on_domain_id', using: :btree
  add_index 'goals', ['family_id'], name: 'index_goals_on_family_id', using: :btree

  create_table 'government_form_children_plans', force: :cascade do |t|
    t.text 'goal', default: ''
    t.text 'action', default: ''
    t.text 'who', default: ''
    t.integer 'government_form_id'
    t.integer 'children_plan_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.integer 'score'
    t.text 'comment', default: ''
    t.date 'completion_date'
  end

  add_index 'government_form_children_plans', ['children_plan_id', 'government_form_id'], name: 'index_on_children_plan_id_and_government_form_id', using: :btree
  add_index 'government_form_children_plans', ['children_plan_id'], name: 'index_government_form_children_plans_on_children_plan_id', using: :btree
  add_index 'government_form_children_plans', ['government_form_id'], name: 'index_government_form_children_plans_on_government_form_id', using: :btree

  create_table 'government_form_family_plans', force: :cascade do |t|
    t.text 'goal', default: ''
    t.text 'action', default: ''
    t.text 'result', default: ''
    t.integer 'government_form_id'
    t.integer 'family_plan_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.integer 'score'
    t.text 'comment', default: ''
  end

  add_index 'government_form_family_plans', ['family_plan_id', 'government_form_id'], name: 'index_on_family_plan_id_and_government_form_id', using: :btree
  add_index 'government_form_family_plans', ['family_plan_id'], name: 'index_government_form_family_plans_on_family_plan_id', using: :btree
  add_index 'government_form_family_plans', ['government_form_id'], name: 'index_government_form_family_plans_on_government_form_id', using: :btree

  create_table 'government_form_interviewees', force: :cascade do |t|
    t.integer 'government_form_id'
    t.integer 'interviewee_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'government_form_interviewees', ['government_form_id'], name: 'index_government_form_interviewees_on_government_form_id', using: :btree
  add_index 'government_form_interviewees', ['interviewee_id'], name: 'index_government_form_interviewees_on_interviewee_id', using: :btree

  create_table 'government_form_needs', force: :cascade do |t|
    t.integer 'rank'
    t.integer 'need_id'
    t.integer 'government_form_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'government_form_needs', ['government_form_id'], name: 'index_government_form_needs_on_government_form_id', using: :btree
  add_index 'government_form_needs', ['need_id'], name: 'index_government_form_needs_on_need_id', using: :btree

  create_table 'government_form_problems', force: :cascade do |t|
    t.integer 'rank'
    t.integer 'problem_id'
    t.integer 'government_form_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'government_form_problems', ['government_form_id'], name: 'index_government_form_problems_on_government_form_id', using: :btree
  add_index 'government_form_problems', ['problem_id'], name: 'index_government_form_problems_on_problem_id', using: :btree

  create_table 'government_form_service_types', force: :cascade do |t|
    t.integer 'government_form_id'
    t.integer 'service_type_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_index 'government_form_service_types', ['government_form_id'], name: 'index_government_form_service_types_on_government_form_id', using: :btree
  add_index 'government_form_service_types', ['service_type_id'], name: 'index_government_form_service_types_on_service_type_id', using: :btree

  create_table 'government_forms', force: :cascade do |t|
    t.string 'name', default: ''
    t.date 'date'
    t.string 'client_code', default: ''
    t.integer 'interview_district_id'
    t.integer 'interview_province_id'
    t.integer 'case_worker_id'
    t.string 'case_worker_phone', default: ''
    t.integer 'client_id'
    t.string 'primary_carer_relationship', default: ''
    t.string 'primary_carer_house', default: ''
    t.string 'primary_carer_street', default: ''
    t.integer 'primary_carer_district_id'
    t.integer 'primary_carer_province_id'
    t.text 'source_info', default: ''
    t.text 'summary_info_of_referral', default: ''
    t.text 'guardian_comment', default: ''
    t.text 'case_worker_comment', default: ''
    t.string 'other_interviewee', default: ''
    t.string 'other_client_type', default: ''
    t.string 'other_need', default: ''
    t.string 'other_problem', default: ''
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer 'province_id'
    t.integer 'district_id'
    t.integer 'commune_id'
    t.integer 'village_id'
    t.string 'caseworker_assumption', default: ''
    t.text 'assumption_description', default: ''
    t.date 'assumption_date'
    t.string 'contact_type', default: ''
    t.string 'client_decision', default: ''
    t.string 'other_service_type', default: ''
    t.date 'gov_placement_date'
    t.string 'care_type', default: ''
    t.string 'primary_carer', default: ''
    t.string 'secondary_carer', default: ''
    t.string 'carer_contact_info', default: ''
    t.integer 'assessment_province_id'
    t.integer 'assessment_district_id'
    t.string 'new_carer', default: ''
    t.string 'new_carer_gender', default: ''
    t.date 'new_carer_date_of_birth'
    t.string 'new_carer_relationship', default: ''
    t.integer 'interview_commune_id'
    t.integer 'interview_village_id'
    t.integer 'assessment_commune_id'
    t.integer 'primary_carer_commune_id'
    t.integer 'primary_carer_village_id'
    t.text 'recent_issues_and_progress', default: ''
    t.string 'other_case_closure'
    t.text 'brief_case_history'
    t.integer 'case_closure_id'
  end

  add_index 'government_forms', ['assessment_commune_id'], name: 'index_government_forms_on_assessment_commune_id', using: :btree
  add_index 'government_forms', ['assessment_district_id'], name: 'index_government_forms_on_assessment_district_id', using: :btree
  add_index 'government_forms', ['assessment_province_id'], name: 'index_government_forms_on_assessment_province_id', using: :btree
  add_index 'government_forms', ['case_closure_id'], name: 'index_government_forms_on_case_closure_id', using: :btree
  add_index 'government_forms', ['case_worker_id'], name: 'index_government_forms_on_case_worker_id', using: :btree
  add_index 'government_forms', ['client_id'], name: 'index_government_forms_on_client_id', using: :btree
  add_index 'government_forms', ['commune_id'], name: 'index_government_forms_on_commune_id', using: :btree
  add_index 'government_forms', ['district_id'], name: 'index_government_forms_on_district_id', using: :btree
  add_index 'government_forms', ['interview_commune_id'], name: 'index_government_forms_on_interview_commune_id', using: :btree
  add_index 'government_forms', ['interview_district_id'], name: 'index_government_forms_on_interview_district_id', using: :btree
  add_index 'government_forms', ['interview_province_id'], name: 'index_government_forms_on_interview_province_id', using: :btree
  add_index 'government_forms', ['interview_village_id'], name: 'index_government_forms_on_interview_village_id', using: :btree
  add_index 'government_forms', ['primary_carer_commune_id'], name: 'index_government_forms_on_primary_carer_commune_id', using: :btree
  add_index 'government_forms', ['primary_carer_district_id'], name: 'index_government_forms_on_primary_carer_district_id', using: :btree
  add_index 'government_forms', ['primary_carer_province_id'], name: 'index_government_forms_on_primary_carer_province_id', using: :btree
  add_index 'government_forms', ['primary_carer_village_id'], name: 'index_government_forms_on_primary_carer_village_id', using: :btree
  add_index 'government_forms', ['province_id'], name: 'index_government_forms_on_province_id', using: :btree
  add_index 'government_forms', ['village_id'], name: 'index_government_forms_on_village_id', using: :btree

  create_table 'government_reports', force: :cascade do |t|
    t.string 'code', default: ''
    t.string 'initial_capital', default: ''
    t.string 'initial_city', default: ''
    t.string 'initial_commune', default: ''
    t.date 'initial_date'
    t.string 'client_code', default: ''
    t.string 'commune', default: ''
    t.string 'city', default: ''
    t.string 'capital', default: ''
    t.string 'organisation_name', default: ''
    t.string 'organisation_phone_number', default: ''
    t.string 'client_name', default: ''
    t.date 'client_date_of_birth'
    t.string 'client_gender', default: ''
    t.string 'found_client_at', default: ''
    t.string 'found_client_village', default: ''
    t.string 'education', default: ''
    t.string 'carer_name', default: ''
    t.string 'client_contact', default: ''
    t.string 'carer_house_number', default: ''
    t.string 'carer_street_number', default: ''
    t.string 'carer_village', default: ''
    t.string 'carer_commune', default: ''
    t.string 'carer_city', default: ''
    t.string 'carer_capital', default: ''
    t.string 'carer_phone_number', default: ''
    t.date 'case_information_date'
    t.string 'referral_name', default: ''
    t.string 'referral_position', default: ''
    t.boolean 'anonymous', default: false
    t.text 'anonymous_description', default: ''
    t.boolean 'client_living_with_guardian', default: false
    t.text 'present_physical_health', default: ''
    t.text 'physical_health_need', default: ''
    t.text 'physical_health_plan', default: ''
    t.text 'present_supplies', default: ''
    t.text 'supplies_need', default: ''
    t.text 'supplies_plan', default: ''
    t.text 'present_education', default: ''
    t.text 'education_need', default: ''
    t.text 'education_plan', default: ''
    t.text 'present_family_communication', default: ''
    t.text 'family_communication_need', default: ''
    t.text 'family_communication_plan', default: ''
    t.text 'present_society_communication', default: ''
    t.text 'society_communication_need', default: ''
    t.text 'society_communication_plan', default: ''
    t.text 'present_emotional_health', default: ''
    t.text 'emotional_health_need', default: ''
    t.text 'emotional_health_plan', default: ''
    t.boolean 'mission_obtainable', default: false
    t.boolean 'first_mission', default: false
    t.boolean 'second_mission', default: false
    t.boolean 'third_mission', default: false
    t.boolean 'fourth_mission', default: false
    t.date 'done_date'
    t.date 'agreed_date'
    t.integer 'client_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'government_reports', ['client_id'], name: 'index_government_reports_on_client_id', using: :btree

  create_table 'hotlines', force: :cascade do |t|
    t.integer 'client_id'
    t.integer 'call_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'hotlines', ['call_id'], name: 'index_hotlines_on_call_id', using: :btree
  add_index 'hotlines', ['client_id'], name: 'index_hotlines_on_client_id', using: :btree

  create_table 'internal_referral_program_streams', force: :cascade do |t|
    t.integer 'internal_referral_id'
    t.integer 'program_stream_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_index 'internal_referral_program_streams', ['internal_referral_id'], name: 'index_internal_referral_program_streams_on_internal_referral_id', using: :btree
  add_index 'internal_referral_program_streams', ['program_stream_id'], name: 'index_internal_referral_program_streams_on_program_stream_id', using: :btree

  create_table 'internal_referrals', force: :cascade do |t|
    t.datetime 'referral_date'
    t.integer 'client_id'
    t.integer 'user_id'
    t.text 'client_representing_problem'
    t.text 'emergency_note'
    t.text 'referral_reason'
    t.text 'crisis_management'
    t.string 'attachments', default: [], array: true
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'referral_decision'
  end

  add_index 'internal_referrals', ['client_id'], name: 'index_internal_referrals_on_client_id', using: :btree
  add_index 'internal_referrals', ['referral_date'], name: 'index_internal_referrals_on_referral_date', using: :btree
  add_index 'internal_referrals', ['user_id'], name: 'index_internal_referrals_on_user_id', using: :btree

  create_table 'interventions', force: :cascade do |t|
    t.string 'action', default: ''
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  create_table 'interviewees', force: :cascade do |t|
    t.string 'name', default: ''
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  create_table 'leave_programs', force: :cascade do |t|
    t.jsonb 'properties', default: {}
    t.integer 'client_enrollment_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.integer 'program_stream_id'
    t.date 'exit_date'
    t.datetime 'deleted_at'
    t.integer 'enrollment_id'
  end

  add_index 'leave_programs', ['client_enrollment_id'], name: 'index_leave_programs_on_client_enrollment_id', using: :btree
  add_index 'leave_programs', ['deleted_at'], name: 'index_leave_programs_on_deleted_at', using: :btree
  add_index 'leave_programs', ['enrollment_id'], name: 'index_leave_programs_on_enrollment_id', using: :btree
  add_index 'leave_programs', ['program_stream_id'], name: 'index_leave_programs_on_program_stream_id', using: :btree

  create_table 'locations', force: :cascade do |t|
    t.string 'name', default: ''
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer 'order_option', default: 0
  end

  create_table 'materials', force: :cascade do |t|
    t.string 'status', default: ''
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  create_table 'mo_savy_officials', force: :cascade do |t|
    t.string 'name'
    t.string 'position'
    t.integer 'client_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'necessities', force: :cascade do |t|
    t.string 'content', default: ''
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'needs', force: :cascade do |t|
    t.string 'name', default: ''
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  create_table 'notifications', force: :cascade do |t|
    t.integer 'notifiable_id'
    t.string 'notifiable_type'
    t.string 'key', null: false
    t.datetime 'seen_at'
    t.integer 'user_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_index 'notifications', ['notifiable_type', 'notifiable_id'], name: 'index_notifications_on_notifiable_type_and_notifiable_id', using: :btree
  add_index 'notifications', ['user_id'], name: 'index_notifications_on_user_id', using: :btree

  create_table 'oauth_access_grants', force: :cascade do |t|
    t.integer 'resource_owner_id', null: false
    t.integer 'application_id', null: false
    t.string 'token', null: false
    t.integer 'expires_in', null: false
    t.text 'redirect_uri', null: false
    t.datetime 'created_at', null: false
    t.datetime 'revoked_at'
    t.string 'scopes'
  end

  add_index 'oauth_access_grants', ['application_id'], name: 'index_oauth_access_grants_on_application_id', using: :btree
  add_index 'oauth_access_grants', ['resource_owner_id'], name: 'index_oauth_access_grants_on_resource_owner_id', using: :btree
  add_index 'oauth_access_grants', ['token'], name: 'index_oauth_access_grants_on_token', unique: true, using: :btree

  create_table 'oauth_access_tokens', force: :cascade do |t|
    t.integer 'resource_owner_id'
    t.integer 'application_id'
    t.string 'token', null: false
    t.string 'refresh_token'
    t.integer 'expires_in'
    t.datetime 'revoked_at'
    t.datetime 'created_at', null: false
    t.string 'scopes'
    t.string 'previous_refresh_token', default: '', null: false
  end

  add_index 'oauth_access_tokens', ['application_id'], name: 'index_oauth_access_tokens_on_application_id', using: :btree
  add_index 'oauth_access_tokens', ['refresh_token'], name: 'index_oauth_access_tokens_on_refresh_token', unique: true, using: :btree
  add_index 'oauth_access_tokens', ['resource_owner_id'], name: 'index_oauth_access_tokens_on_resource_owner_id', using: :btree
  add_index 'oauth_access_tokens', ['token'], name: 'index_oauth_access_tokens_on_token', unique: true, using: :btree

  create_table 'oauth_applications', force: :cascade do |t|
    t.string 'name', null: false
    t.string 'uid', null: false
    t.string 'secret', null: false
    t.text 'redirect_uri', null: false
    t.string 'scopes', default: '', null: false
    t.boolean 'confidential', default: true, null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_index 'oauth_applications', ['uid'], name: 'index_oauth_applications_on_uid', unique: true, using: :btree

  create_table 'organization_types', force: :cascade do |t|
    t.string 'name'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'organizations', force: :cascade do |t|
    t.string 'full_name'
    t.string 'short_name'
    t.string 'logo'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.boolean 'fcf_ngo', default: false
    t.string 'country', default: ''
    t.boolean 'aht', default: false
    t.boolean 'integrated', default: false
    t.string 'supported_languages', default: ['km', 'en', 'my'], array: true
    t.integer 'clients_count', default: 0
    t.integer 'active_client', default: 0
    t.integer 'accepted_client', default: 0
    t.boolean 'demo', default: false
    t.string 'referral_source_category_name'
    t.string 'ngo_type'
    t.integer 'referred_count', default: 0
    t.integer 'exited_client', default: 0
    t.datetime 'deleted_at'
    t.string 'onboarding_status', default: 'pending'
    t.integer 'users_count', default: 0
    t.date 'last_integrated_date'
    t.integer 'parent_id'
  end

  add_index 'organizations', ['deleted_at'], name: 'index_organizations_on_deleted_at', using: :btree
  add_index 'organizations', ['full_name'], name: 'index_organizations_on_full_name', using: :btree
  add_index 'organizations', ['short_name'], name: 'index_organizations_on_short_name', using: :btree

  create_table 'partners', force: :cascade do |t|
    t.string 'name', default: ''
    t.string 'address', default: ''
    t.date 'start_date'
    t.string 'contact_person_name', default: ''
    t.string 'contact_person_email', default: ''
    t.string 'contact_person_mobile', default: ''
    t.string 'archive_organization_type', default: ''
    t.string 'affiliation', default: ''
    t.string 'engagement', default: ''
    t.text 'background', default: ''
    t.integer 'province_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer 'cases_count', default: 0
    t.integer 'organization_type_id'
  end

  add_index 'partners', ['organization_type_id'], name: 'index_partners_on_organization_type_id', using: :btree
  add_index 'partners', ['province_id'], name: 'index_partners_on_province_id', using: :btree

  create_table 'permissions', force: :cascade do |t|
    t.integer 'user_id'
    t.boolean 'case_notes_readable', default: true
    t.boolean 'case_notes_editable', default: true
    t.boolean 'assessments_editable', default: true
    t.boolean 'assessments_readable', default: true
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_index 'permissions', ['user_id'], name: 'index_permissions_on_user_id', using: :btree

  create_table 'problems', force: :cascade do |t|
    t.string 'name', default: ''
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  create_table 'program_stream_permissions', force: :cascade do |t|
    t.integer 'user_id'
    t.integer 'program_stream_id'
    t.boolean 'readable', default: true
    t.boolean 'editable', default: true
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.datetime 'deleted_at'
  end

  add_index 'program_stream_permissions', ['deleted_at'], name: 'index_program_stream_permissions_on_deleted_at', using: :btree
  add_index 'program_stream_permissions', ['program_stream_id'], name: 'index_program_stream_permissions_on_program_stream_id', using: :btree
  add_index 'program_stream_permissions', ['user_id'], name: 'index_program_stream_permissions_on_user_id', using: :btree

  create_table 'program_stream_services', force: :cascade do |t|
    t.datetime 'deleted_at'
    t.integer 'program_stream_id'
    t.integer 'service_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_index 'program_stream_services', ['deleted_at'], name: 'index_program_stream_services_on_deleted_at', using: :btree
  add_index 'program_stream_services', ['program_stream_id'], name: 'index_program_stream_services_on_program_stream_id', using: :btree
  add_index 'program_stream_services', ['service_id'], name: 'index_program_stream_services_on_service_id', using: :btree

  create_table 'program_stream_users', force: :cascade do |t|
    t.integer 'user_id'
    t.integer 'program_stream_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_index 'program_stream_users', ['program_stream_id'], name: 'index_program_stream_users_on_program_stream_id', using: :btree
  add_index 'program_stream_users', ['user_id'], name: 'index_program_stream_users_on_user_id', using: :btree

  create_table 'program_streams', force: :cascade do |t|
    t.string 'name'
    t.text 'description'
    t.jsonb 'rules', default: {}
    t.jsonb 'enrollment', default: {}
    t.jsonb 'exit_program', default: {}
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.integer 'quantity'
    t.string 'ngo_name', default: ''
    t.boolean 'completed', default: false
    t.integer 'program_exclusive', default: [], array: true
    t.integer 'mutual_dependence', default: [], array: true
    t.boolean 'tracking_required', default: false
    t.datetime 'archived_at'
    t.string 'entity_type', default: ''
  end

  add_index 'program_streams', ['archived_at'], name: 'index_program_streams_on_archived_at', using: :btree
  add_index 'program_streams', ['name'], name: 'index_program_streams_on_name', using: :btree

  create_table 'progress_note_types', force: :cascade do |t|
    t.string 'note_type', default: ''
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  create_table 'progress_notes', force: :cascade do |t|
    t.date 'date'
    t.string 'other_location', default: ''
    t.text 'response', default: ''
    t.text 'additional_note', default: ''
    t.integer 'client_id'
    t.integer 'progress_note_type_id'
    t.integer 'location_id'
    t.integer 'material_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer 'user_id'
  end

  add_index 'progress_notes', ['client_id'], name: 'index_progress_notes_on_client_id', using: :btree
  add_index 'progress_notes', ['location_id'], name: 'index_progress_notes_on_location_id', using: :btree
  add_index 'progress_notes', ['material_id'], name: 'index_progress_notes_on_material_id', using: :btree
  add_index 'progress_notes', ['progress_note_type_id'], name: 'index_progress_notes_on_progress_note_type_id', using: :btree
  add_index 'progress_notes', ['user_id'], name: 'index_progress_notes_on_user_id', using: :btree

  create_table 'protection_concerns', force: :cascade do |t|
    t.string 'content', default: ''
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'provinces', force: :cascade do |t|
    t.string 'name', default: ''
    t.text 'description', default: ''
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer 'cases_count', default: 0
    t.integer 'clients_count', default: 0
    t.integer 'families_count', default: 0
    t.integer 'partners_count', default: 0
    t.integer 'users_count', default: 0, null: false
    t.string 'country'
    t.string 'code', limit: 7
  end

  create_table 'quantitative_cases', force: :cascade do |t|
    t.string 'value', default: ''
    t.integer 'quantitative_type_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'quantitative_cases', ['quantitative_type_id'], name: 'index_quantitative_cases_on_quantitative_type_id', using: :btree

  create_table 'quantitative_type_permissions', force: :cascade do |t|
    t.integer 'user_id'
    t.integer 'quantitative_type_id'
    t.boolean 'readable', default: true
    t.boolean 'editable', default: true
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_index 'quantitative_type_permissions', ['quantitative_type_id'], name: 'index_quantitative_type_permissions_on_quantitative_type_id', using: :btree
  add_index 'quantitative_type_permissions', ['user_id'], name: 'index_quantitative_type_permissions_on_user_id', using: :btree

  create_table 'quantitative_types', force: :cascade do |t|
    t.string 'name', default: ''
    t.text 'description', default: ''
    t.integer 'quantitative_cases_count', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.boolean 'multiple', default: true
    t.string 'visible_on', default: "---\n- client\n"
    t.boolean 'is_required', default: false
    t.string 'hint'
    t.string 'field_type', default: 'select_option'
  end

  create_table 'quarterly_reports', force: :cascade do |t|
    t.date 'visit_date'
    t.integer 'code', limit: 8
    t.integer 'case_id'
    t.text 'general_health_or_appearance', default: ''
    t.text 'child_school_attendance_or_progress', default: ''
    t.text 'general_appearance_of_home', default: ''
    t.text 'observations_of_drug_alchohol_abuse', default: ''
    t.text 'describe_if_yes', default: ''
    t.text 'describe_the_family_current_situation', default: ''
    t.text 'has_the_situation_changed_from_the_previous_visit', default: ''
    t.text 'how_did_i_encourage_the_client', default: ''
    t.text 'what_future_teachings_or_trainings_could_help_the_client', default: ''
    t.text 'what_is_my_plan_for_the_next_visit_to_the_client', default: ''
    t.boolean 'money_and_supplies_being_used_appropriately', default: false
    t.text 'how_are_they_being_misused', default: ''
    t.integer 'staff_id'
    t.text 'spiritual_developments_with_the_child_or_family', default: ''
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_index 'quarterly_reports', ['case_id'], name: 'index_quarterly_reports_on_case_id', using: :btree
  add_index 'quarterly_reports', ['staff_id'], name: 'index_quarterly_reports_on_staff_id', using: :btree

  create_table 'question_groups', force: :cascade do |t|
    t.string 'name'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'referees', force: :cascade do |t|
    t.string 'address_type', default: ''
    t.string 'current_address', default: ''
    t.string 'email', default: ''
    t.string 'gender', default: ''
    t.string 'house_number', default: ''
    t.string 'outside_address', default: ''
    t.string 'street_number', default: ''
    t.boolean 'outside', default: false
    t.boolean 'anonymous', default: false
    t.integer 'province_id'
    t.integer 'district_id'
    t.integer 'commune_id'
    t.integer 'village_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'name', default: ''
    t.string 'phone', default: ''
    t.boolean 'adult'
    t.string 'suburb', default: ''
    t.string 'description_house_landmark', default: ''
    t.string 'directions', default: ''
    t.string 'street_line1', default: ''
    t.string 'street_line2', default: ''
    t.string 'plot', default: ''
    t.string 'road', default: ''
    t.string 'postal_code', default: ''
    t.integer 'state_id'
    t.integer 'township_id'
    t.integer 'subdistrict_id'
    t.string 'locality'
    t.integer 'city_id'
  end

  add_index 'referees', ['city_id'], name: 'index_referees_on_city_id', using: :btree
  add_index 'referees', ['commune_id'], name: 'index_referees_on_commune_id', using: :btree
  add_index 'referees', ['district_id'], name: 'index_referees_on_district_id', using: :btree
  add_index 'referees', ['province_id'], name: 'index_referees_on_province_id', using: :btree
  add_index 'referees', ['state_id'], name: 'index_referees_on_state_id', using: :btree
  add_index 'referees', ['subdistrict_id'], name: 'index_referees_on_subdistrict_id', using: :btree
  add_index 'referees', ['township_id'], name: 'index_referees_on_township_id', using: :btree
  add_index 'referees', ['village_id'], name: 'index_referees_on_village_id', using: :btree

  create_table 'referral_sources', force: :cascade do |t|
    t.string 'name', default: ''
    t.text 'description', default: ''
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer 'clients_count', default: 0
    t.string 'name_en', default: ''
    t.string 'ancestry'
  end

  add_index 'referral_sources', ['ancestry'], name: 'index_referral_sources_on_ancestry', using: :btree
  add_index 'referral_sources', ['name'], name: 'index_referral_sources_on_name', using: :btree
  add_index 'referral_sources', ['name_en'], name: 'index_referral_sources_on_name_en', using: :btree

  create_table 'referrals', force: :cascade do |t|
    t.string 'slug', default: ''
    t.date 'date_of_referral'
    t.string 'referred_to', default: ''
    t.string 'referred_from', default: ''
    t.text 'referral_reason', default: ''
    t.string 'name_of_referee', default: ''
    t.string 'referral_phone', default: ''
    t.integer 'referee_id'
    t.string 'client_name', default: ''
    t.string 'consent_form', default: [], array: true
    t.boolean 'saved', default: false
    t.integer 'client_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'ngo_name', default: ''
    t.string 'client_global_id'
    t.string 'external_id'
    t.string 'external_id_display'
    t.string 'mosvy_number'
    t.string 'external_case_worker_name'
    t.string 'external_case_worker_id'
    t.string 'client_gender', default: ''
    t.date 'client_date_of_birth'
    t.string 'village_code', default: ''
    t.string 'referee_email'
    t.string 'level_of_risk'
    t.string 'referral_status', default: 'Referred'
    t.datetime 'deleted_at'
    t.integer 'referred_from_uid'
  end

  add_index 'referrals', ['client_global_id'], name: 'index_referrals_on_client_global_id', using: :btree
  add_index 'referrals', ['client_id'], name: 'index_referrals_on_client_id', using: :btree
  add_index 'referrals', ['deleted_at'], name: 'index_referrals_on_deleted_at', using: :btree
  add_index 'referrals', ['external_case_worker_id'], name: 'index_referrals_on_external_case_worker_id', using: :btree
  add_index 'referrals', ['external_id'], name: 'index_referrals_on_external_id', using: :btree
  add_index 'referrals', ['mosvy_number'], name: 'index_referrals_on_mosvy_number', using: :btree
  add_index 'referrals', ['referee_id'], name: 'index_referrals_on_referee_id', using: :btree
  add_index 'referrals', ['referred_from_uid'], name: 'index_referrals_on_referred_from_uid', using: :btree

  create_table 'referrals_services', id: false, force: :cascade do |t|
    t.integer 'referral_id'
    t.integer 'service_id'
  end

  add_index 'referrals_services', ['referral_id', 'service_id'], name: 'index_referrals_services_on_referral_id_and_service_id', using: :btree
  add_index 'referrals_services', ['referral_id'], name: 'index_referrals_services_on_referral_id', using: :btree
  add_index 'referrals_services', ['service_id'], name: 'index_referrals_services_on_service_id', using: :btree

  create_table 'release_notes', force: :cascade do |t|
    t.text 'content', null: false
    t.integer 'created_by_id'
    t.integer 'published_by_id'
    t.boolean 'published', default: false
    t.datetime 'published_at'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.text 'attachments', default: [], array: true
  end

  add_index 'release_notes', ['created_by_id'], name: 'index_release_notes_on_created_by_id', using: :btree
  add_index 'release_notes', ['published_by_id'], name: 'index_release_notes_on_published_by_id', using: :btree

  create_table 'risk_assessments', force: :cascade do |t|
    t.date 'assessment_date'
    t.string 'protection_concern', default: [], array: true
    t.string 'level_of_risk'
    t.string 'other_protection_concern_specification'
    t.text 'client_perspective'
    t.boolean 'has_known_chronic_disease', default: false
    t.boolean 'has_disability', default: false
    t.boolean 'has_hiv_or_aid', default: false
    t.string 'known_chronic_disease_specification'
    t.string 'disability_specification'
    t.string 'hiv_or_aid_specification'
    t.text 'relevant_referral_information'
    t.integer 'history_of_disability_id'
    t.integer 'history_of_harm_id'
    t.integer 'history_of_high_risk_behaviour_id'
    t.integer 'history_of_family_separation_id'
    t.integer 'client_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_index 'risk_assessments', ['assessment_date'], name: 'index_risk_assessments_on_assessment_date', using: :btree
  add_index 'risk_assessments', ['client_id'], name: 'index_risk_assessments_on_client_id', unique: true, using: :btree
  add_index 'risk_assessments', ['history_of_disability_id'], name: 'index_risk_assessments_on_history_of_disability_id', using: :btree
  add_index 'risk_assessments', ['history_of_family_separation_id'], name: 'index_risk_assessments_on_history_of_family_separation_id', using: :btree
  add_index 'risk_assessments', ['history_of_harm_id'], name: 'index_risk_assessments_on_history_of_harm_id', using: :btree
  add_index 'risk_assessments', ['history_of_high_risk_behaviour_id'], name: 'index_risk_assessments_on_history_of_high_risk_behaviour_id', using: :btree

  create_table 'screening_assessments', force: :cascade do |t|
    t.datetime 'screening_assessment_date'
    t.string 'client_age'
    t.string 'visitor'
    t.string 'client_milestone_age'
    t.string 'attachments', default: [], array: true
    t.text 'note'
    t.boolean 'smile_back_during_interaction'
    t.boolean 'follow_object_passed_midline'
    t.boolean 'turn_head_to_sound'
    t.boolean 'head_up_45_degree'
    t.integer 'client_id'
    t.string 'screening_type', default: 'multiple'
  end

  add_index 'screening_assessments', ['client_id'], name: 'index_screening_assessments_on_client_id', using: :btree
  add_index 'screening_assessments', ['screening_assessment_date'], name: 'index_screening_assessments_on_screening_assessment_date', using: :btree
  add_index 'screening_assessments', ['screening_type'], name: 'index_screening_assessments_on_screening_type', using: :btree

  create_table 'service_deliveries', force: :cascade do |t|
    t.string 'name'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.integer 'parent_id'
  end

  add_index 'service_deliveries', ['parent_id'], name: 'index_service_deliveries_on_parent_id', using: :btree

  create_table 'service_delivery_tasks', force: :cascade do |t|
    t.integer 'task_id'
    t.integer 'service_delivery_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_index 'service_delivery_tasks', ['service_delivery_id'], name: 'index_service_delivery_tasks_on_service_delivery_id', using: :btree
  add_index 'service_delivery_tasks', ['task_id'], name: 'index_service_delivery_tasks_on_task_id', using: :btree

  create_table 'service_types', force: :cascade do |t|
    t.string 'name', default: ''
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'services', force: :cascade do |t|
    t.string 'name'
    t.integer 'parent_id'
    t.datetime 'deleted_at'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.uuid 'uuid'
  end

  add_index 'services', ['deleted_at'], name: 'index_services_on_deleted_at', using: :btree
  add_index 'services', ['name'], name: 'index_services_on_name', using: :btree
  add_index 'services', ['parent_id'], name: 'index_services_on_parent_id', using: :btree
  add_index 'services', ['uuid'], name: 'index_services_on_uuid', using: :btree

  create_table 'settings', force: :cascade do |t|
    t.string 'assessment_frequency', default: 'month'
    t.integer 'min_assessment'
    t.integer 'max_assessment', default: 6
    t.string 'country_name', default: ''
    t.integer 'max_case_note'
    t.string 'case_note_frequency'
    t.string 'client_default_columns', default: [], array: true
    t.string 'family_default_columns', default: [], array: true
    t.string 'partner_default_columns', default: [], array: true
    t.string 'user_default_columns', default: [], array: true
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string 'org_name', default: ''
    t.string 'old_commune', default: ''
    t.integer 'province_id'
    t.integer 'district_id'
    t.integer 'age', default: 18
    t.integer 'commune_id'
    t.string 'custom_assessment', default: 'Custom Assessment'
    t.boolean 'enable_custom_assessment', default: false
    t.boolean 'enable_default_assessment', default: true
    t.integer 'max_custom_assessment', default: 6
    t.string 'custom_assessment_frequency', default: 'month'
    t.integer 'custom_age', default: 18
    t.string 'default_assessment', default: 'CSI Assessment'
    t.boolean 'sharing_data', default: false
    t.string 'custom_id1_latin', default: ''
    t.string 'custom_id1_local', default: ''
    t.string 'custom_id2_latin', default: ''
    t.string 'custom_id2_local', default: ''
    t.boolean 'enable_hotline', default: false
    t.boolean 'enable_client_form', default: true
    t.string 'assessment_score_order', default: 'random_order', null: false
    t.boolean 'disable_required_fields', default: false, null: false
    t.boolean 'never_delete_incomplete_assessment', default: false, null: false
    t.integer 'delete_incomplete_after_period_value', default: 7
    t.string 'delete_incomplete_after_period_unit', default: 'days'
    t.boolean 'use_screening_assessment', default: false
    t.integer 'screening_assessment_form_id'
    t.boolean 'show_prev_assessment', default: false
    t.boolean 'two_weeks_assessment_reminder', default: false
    t.boolean 'hide_family_case_management_tool', default: true, null: false
    t.boolean 'hide_community', default: true, null: false
    t.string 'community_default_columns', default: [], array: true
    t.integer 'case_conference_limit', default: 0
    t.string 'case_conference_frequency', default: 'week'
    t.boolean 'use_previous_care_plan'
    t.integer 'internal_referral_limit', default: 0
    t.string 'internal_referral_frequency', default: 'week'
    t.integer 'custom_field_limit', default: 0
    t.string 'custom_field_frequency', default: 'week'
    t.boolean 'disabled_future_completion_date', default: false
    t.integer 'case_note_edit_limit', default: 0
    t.string 'case_note_edit_frequency', default: 'week'
    t.boolean 'disabled_add_service_received', default: false
    t.boolean 'test_client', default: false
    t.boolean 'disabled_task_date_field', default: true
    t.integer 'tracking_form_edit_limit', default: 0
    t.string 'tracking_form_edit_frequency', default: 'week'
    t.boolean 'required_case_note_note', default: true
    t.boolean 'hide_case_note_note', default: false
    t.boolean 'cbdmat_one_off', default: false
    t.boolean 'cbdmat_ongoing', default: false
    t.boolean 'enabled_risk_assessment', default: false
    t.string 'assessment_type_name', default: 'csi'
    t.integer 'selected_domain_ids', default: [], array: true
    t.text 'level_of_risk_guidance'
    t.boolean 'enabled_header_count', default: false
    t.boolean 'finance_dashboard', default: false, null: false
    t.integer 'city_id'
    t.boolean 'enabled_internal_referral', default: false
  end

  add_index 'settings', ['city_id'], name: 'index_settings_on_city_id', using: :btree
  add_index 'settings', ['commune_id'], name: 'index_settings_on_commune_id', using: :btree
  add_index 'settings', ['district_id'], name: 'index_settings_on_district_id', using: :btree
  add_index 'settings', ['province_id'], name: 'index_settings_on_province_id', using: :btree
  add_index 'settings', ['screening_assessment_form_id'], name: 'index_settings_on_screening_assessment_form_id', using: :btree

  create_table 'shared_clients', force: :cascade do |t|
    t.string 'slug', default: ''
    t.string 'given_name', default: ''
    t.string 'family_name', default: ''
    t.string 'local_given_name', default: ''
    t.string 'local_family_name', default: ''
    t.string 'gender', default: ''
    t.date 'date_of_birth'
    t.string 'live_with', default: ''
    t.string 'telephone_number', default: ''
    t.integer 'birth_province_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'country_origin', default: ''
    t.string 'duplicate_checker'
    t.string 'archived_slug'
    t.string 'global_id'
    t.string 'external_id'
    t.string 'external_id_display'
    t.string 'mosvy_number'
    t.string 'external_case_worker_name'
    t.string 'external_case_worker_id'
    t.string 'ngo_name'
    t.datetime 'client_created_at'
    t.boolean 'duplicate', default: false
    t.jsonb 'duplicate_with', default: {}
    t.integer 'resolved_duplication_by'
    t.datetime 'resolved_duplication_at'
  end

  add_index 'shared_clients', ['archived_slug'], name: 'index_shared_clients_on_archived_slug', using: :btree
  add_index 'shared_clients', ['birth_province_id'], name: 'index_shared_clients_on_birth_province_id', using: :btree
  add_index 'shared_clients', ['duplicate_checker'], name: 'index_shared_clients_on_duplicate_checker', using: :btree
  add_index 'shared_clients', ['external_case_worker_id'], name: 'index_shared_clients_on_external_case_worker_id', using: :btree
  add_index 'shared_clients', ['external_id'], name: 'index_shared_clients_on_external_id', using: :btree
  add_index 'shared_clients', ['global_id'], name: 'index_shared_clients_on_global_id', using: :btree
  add_index 'shared_clients', ['mosvy_number'], name: 'index_shared_clients_on_mosvy_number', using: :btree
  add_index 'shared_clients', ['resolved_duplication_at'], name: 'index_shared_clients_on_resolved_duplication_at', using: :btree
  add_index 'shared_clients', ['resolved_duplication_by'], name: 'index_shared_clients_on_resolved_duplication_by', using: :btree
  add_index 'shared_clients', ['slug'], name: 'index_shared_clients_on_slug', unique: true, using: :btree

  create_table 'sponsors', force: :cascade do |t|
    t.integer 'client_id'
    t.integer 'donor_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'sponsors', ['client_id'], name: 'index_sponsors_on_client_id', using: :btree
  add_index 'sponsors', ['donor_id'], name: 'index_sponsors_on_donor_id', using: :btree

  create_table 'stages', force: :cascade do |t|
    t.float 'from_age'
    t.float 'to_age'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'states', force: :cascade do |t|
    t.string 'name'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'subdistricts', force: :cascade do |t|
    t.string 'name'
    t.integer 'district_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_index 'subdistricts', ['district_id'], name: 'index_subdistricts_on_district_id', using: :btree

  create_table 'surveys', force: :cascade do |t|
    t.integer 'client_id'
    t.integer 'user_id'
    t.integer 'listening_score'
    t.integer 'problem_solving_score'
    t.integer 'getting_in_touch_score'
    t.integer 'trust_score'
    t.integer 'difficulty_help_score'
    t.integer 'support_score'
    t.integer 'family_need_score'
    t.integer 'care_score'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'surveys', ['client_id'], name: 'index_surveys_on_client_id', using: :btree
  add_index 'surveys', ['user_id'], name: 'index_surveys_on_user_id', using: :btree

  create_table 'task_progress_notes', force: :cascade do |t|
    t.text 'progress_note'
    t.integer 'task_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_index 'task_progress_notes', ['task_id'], name: 'index_task_progress_notes_on_task_id', using: :btree

  create_table 'tasks', force: :cascade do |t|
    t.string 'name', default: ''
    t.date 'expected_date'
    t.datetime 'remind_at'
    t.boolean 'completed', default: false
    t.integer 'user_id'
    t.integer 'case_note_domain_group_id'
    t.integer 'domain_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer 'client_id'
    t.string 'relation', default: ''
    t.string 'case_note_id', default: ''
    t.integer 'taskable_id'
    t.string 'taskable_type'
    t.datetime 'deleted_at'
    t.integer 'goal_id'
    t.integer 'family_id'
    t.datetime 'completion_date'
    t.string 'domain_group_identity'
    t.integer 'completed_by_id'
    t.integer 'previous_id'
  end

  add_index 'tasks', ['case_note_domain_group_id'], name: 'index_tasks_on_case_note_domain_group_id', using: :btree
  add_index 'tasks', ['case_note_id'], name: 'index_tasks_on_case_note_id', using: :btree
  add_index 'tasks', ['client_id'], name: 'index_tasks_on_client_id', using: :btree
  add_index 'tasks', ['completed_by_id'], name: 'index_tasks_on_completed_by_id', using: :btree
  add_index 'tasks', ['deleted_at'], name: 'index_tasks_on_deleted_at', using: :btree
  add_index 'tasks', ['domain_group_identity'], name: 'index_tasks_on_domain_group_identity', using: :btree
  add_index 'tasks', ['domain_id'], name: 'index_tasks_on_domain_id', using: :btree
  add_index 'tasks', ['family_id'], name: 'index_tasks_on_family_id', using: :btree
  add_index 'tasks', ['goal_id'], name: 'index_tasks_on_goal_id', using: :btree
  add_index 'tasks', ['previous_id'], name: 'index_tasks_on_previous_id', using: :btree
  add_index 'tasks', ['taskable_type', 'taskable_id'], name: 'index_tasks_on_taskable_type_and_taskable_id', using: :btree
  add_index 'tasks', ['user_id'], name: 'index_tasks_on_user_id', using: :btree

  create_table 'thredded_categories', force: :cascade do |t|
    t.integer 'messageboard_id', null: false
    t.string 'name', limit: 191, null: false
    t.string 'description', limit: 255
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'slug', limit: 191, null: false
  end

  add_index 'thredded_categories', ['messageboard_id', 'slug'], name: 'index_thredded_categories_on_messageboard_id_and_slug', unique: true, using: :btree
  add_index 'thredded_categories', ['messageboard_id'], name: 'index_thredded_categories_on_messageboard_id', using: :btree

  create_table 'thredded_messageboard_groups', force: :cascade do |t|
    t.string 'name'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'thredded_messageboards', force: :cascade do |t|
    t.string 'name', limit: 255, null: false
    t.string 'slug', limit: 191
    t.text 'description'
    t.integer 'topics_count', default: 0
    t.integer 'posts_count', default: 0
    t.boolean 'closed', default: false, null: false
    t.integer 'last_topic_id'
    t.integer 'messageboard_group_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_index 'thredded_messageboards', ['closed'], name: 'index_thredded_messageboards_on_closed', using: :btree
  add_index 'thredded_messageboards', ['last_topic_id'], name: 'index_thredded_messageboards_on_last_topic_id', using: :btree
  add_index 'thredded_messageboards', ['messageboard_group_id'], name: 'index_thredded_messageboards_on_messageboard_group_id', using: :btree
  add_index 'thredded_messageboards', ['slug'], name: 'index_thredded_messageboards_on_slug', using: :btree

  create_table 'thredded_post_moderation_records', force: :cascade do |t|
    t.integer 'post_id'
    t.integer 'messageboard_id'
    t.text 'post_content'
    t.integer 'post_user_id'
    t.text 'post_user_name'
    t.integer 'moderator_id'
    t.integer 'moderation_state', null: false
    t.integer 'previous_moderation_state', null: false
    t.datetime 'created_at', null: false
  end

  add_index 'thredded_post_moderation_records', ['messageboard_id', 'created_at'], name: 'index_thredded_moderation_records_for_display', order: { 'created_at' => :desc }, using: :btree
  add_index 'thredded_post_moderation_records', ['moderator_id'], name: 'index_thredded_post_moderation_records_on_moderator_id', using: :btree
  add_index 'thredded_post_moderation_records', ['post_id'], name: 'index_thredded_post_moderation_records_on_post_id', using: :btree
  add_index 'thredded_post_moderation_records', ['post_user_id'], name: 'index_thredded_post_moderation_records_on_post_user_id', using: :btree

  create_table 'thredded_post_notifications', force: :cascade do |t|
    t.string 'email', limit: 191, null: false
    t.integer 'post_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'post_type', limit: 191
  end

  add_index 'thredded_post_notifications', ['post_id', 'post_type'], name: 'index_thredded_post_notifications_on_post', using: :btree

  create_table 'thredded_posts', force: :cascade do |t|
    t.integer 'user_id'
    t.text 'content'
    t.string 'ip', limit: 255
    t.string 'source', limit: 255, default: 'web'
    t.integer 'postable_id', null: false
    t.integer 'messageboard_id', null: false
    t.integer 'moderation_state', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_index 'thredded_posts', ['messageboard_id'], name: 'index_thredded_posts_on_messageboard_id', using: :btree
  add_index 'thredded_posts', ['moderation_state', 'updated_at'], name: 'index_thredded_posts_for_display', using: :btree
  add_index 'thredded_posts', ['postable_id'], name: 'index_thredded_posts_on_postable_id_and_postable_type', using: :btree
  add_index 'thredded_posts', ['user_id'], name: 'index_thredded_posts_on_user_id', using: :btree

  create_table 'thredded_private_posts', force: :cascade do |t|
    t.integer 'user_id'
    t.text 'content'
    t.integer 'postable_id', null: false
    t.string 'ip', limit: 255
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_index 'thredded_private_posts', ['postable_id'], name: 'index_thredded_private_posts_on_postable_id', using: :btree
  add_index 'thredded_private_posts', ['user_id'], name: 'index_thredded_private_posts_on_user_id', using: :btree

  create_table 'thredded_private_topics', force: :cascade do |t|
    t.integer 'user_id'
    t.integer 'last_user_id'
    t.string 'title', limit: 255, null: false
    t.string 'slug', limit: 191, null: false
    t.integer 'posts_count', default: 0
    t.string 'hash_id', limit: 191, null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_index 'thredded_private_topics', ['hash_id'], name: 'index_thredded_private_topics_on_hash_id', using: :btree
  add_index 'thredded_private_topics', ['last_user_id'], name: 'index_thredded_private_topics_on_last_user_id', using: :btree
  add_index 'thredded_private_topics', ['slug'], name: 'index_thredded_private_topics_on_slug', using: :btree
  add_index 'thredded_private_topics', ['user_id'], name: 'index_thredded_private_topics_on_user_id', using: :btree

  create_table 'thredded_private_users', force: :cascade do |t|
    t.integer 'private_topic_id'
    t.integer 'user_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_index 'thredded_private_users', ['private_topic_id'], name: 'index_thredded_private_users_on_private_topic_id', using: :btree
  add_index 'thredded_private_users', ['user_id'], name: 'index_thredded_private_users_on_user_id', using: :btree

  create_table 'thredded_topic_categories', force: :cascade do |t|
    t.integer 'topic_id', null: false
    t.integer 'category_id', null: false
  end

  add_index 'thredded_topic_categories', ['category_id'], name: 'index_thredded_topic_categories_on_category_id', using: :btree
  add_index 'thredded_topic_categories', ['topic_id'], name: 'index_thredded_topic_categories_on_topic_id', using: :btree

  create_table 'thredded_topics', force: :cascade do |t|
    t.integer 'user_id'
    t.integer 'last_user_id'
    t.string 'title', limit: 255, null: false
    t.string 'slug', limit: 191, null: false
    t.integer 'messageboard_id', null: false
    t.integer 'posts_count', default: 0, null: false
    t.boolean 'sticky', default: false, null: false
    t.boolean 'locked', default: false, null: false
    t.string 'hash_id', limit: 191, null: false
    t.string 'type', limit: 191
    t.integer 'moderation_state', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_index 'thredded_topics', ['hash_id'], name: 'index_thredded_topics_on_hash_id', using: :btree
  add_index 'thredded_topics', ['last_user_id'], name: 'index_thredded_topics_on_last_user_id', using: :btree
  add_index 'thredded_topics', ['messageboard_id', 'slug'], name: 'index_thredded_topics_on_messageboard_id_and_slug', unique: true, using: :btree
  add_index 'thredded_topics', ['messageboard_id'], name: 'index_thredded_topics_on_messageboard_id', using: :btree
  add_index 'thredded_topics', ['moderation_state', 'sticky', 'updated_at'], name: 'index_thredded_topics_for_display', order: { 'sticky' => :desc, 'updated_at' => :desc }, using: :btree
  add_index 'thredded_topics', ['user_id'], name: 'index_thredded_topics_on_user_id', using: :btree

  create_table 'thredded_user_details', force: :cascade do |t|
    t.integer 'user_id', null: false
    t.datetime 'latest_activity_at'
    t.integer 'posts_count', default: 0
    t.integer 'topics_count', default: 0
    t.datetime 'last_seen_at'
    t.integer 'moderation_state', default: 1, null: false
    t.datetime 'moderation_state_changed_at'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_index 'thredded_user_details', ['latest_activity_at'], name: 'index_thredded_user_details_on_latest_activity_at', using: :btree
  add_index 'thredded_user_details', ['moderation_state', 'moderation_state_changed_at'], name: 'index_thredded_user_details_for_moderations', order: { 'moderation_state_changed_at' => :desc }, using: :btree
  add_index 'thredded_user_details', ['user_id'], name: 'index_thredded_user_details_on_user_id', using: :btree

  create_table 'thredded_user_messageboard_preferences', force: :cascade do |t|
    t.integer 'user_id', null: false
    t.integer 'messageboard_id', null: false
    t.boolean 'notify_on_mention', default: true, null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_index 'thredded_user_messageboard_preferences', ['messageboard_id'], name: 'index_thredded_user_messageboard_preferences_on_messageboard_id', using: :btree
  add_index 'thredded_user_messageboard_preferences', ['user_id', 'messageboard_id'], name: 'thredded_user_messageboard_preferences_user_id_messageboard_id', unique: true, using: :btree

  create_table 'thredded_user_preferences', force: :cascade do |t|
    t.integer 'user_id', null: false
    t.boolean 'notify_on_mention', default: true, null: false
    t.boolean 'notify_on_message', default: true, null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_index 'thredded_user_preferences', ['user_id'], name: 'index_thredded_user_preferences_on_user_id', using: :btree

  create_table 'thredded_user_private_topic_read_states', force: :cascade do |t|
    t.integer 'user_id', null: false
    t.integer 'postable_id', null: false
    t.integer 'page', default: 1, null: false
    t.datetime 'read_at', null: false
  end

  add_index 'thredded_user_private_topic_read_states', ['postable_id'], name: 'index_thredded_user_private_topic_read_states_on_postable_id', using: :btree
  add_index 'thredded_user_private_topic_read_states', ['user_id', 'postable_id'], name: 'thredded_user_private_topic_read_states_user_postable', unique: true, using: :btree

  create_table 'thredded_user_topic_follows', force: :cascade do |t|
    t.integer 'user_id', null: false
    t.integer 'topic_id', null: false
    t.datetime 'created_at', null: false
    t.integer 'reason', limit: 2
  end

  add_index 'thredded_user_topic_follows', ['topic_id'], name: 'index_thredded_user_topic_follows_on_topic_id', using: :btree
  add_index 'thredded_user_topic_follows', ['user_id', 'topic_id'], name: 'thredded_user_topic_follows_user_topic', unique: true, using: :btree

  create_table 'thredded_user_topic_read_states', force: :cascade do |t|
    t.integer 'user_id', null: false
    t.integer 'postable_id', null: false
    t.integer 'page', default: 1, null: false
    t.datetime 'read_at', null: false
  end

  add_index 'thredded_user_topic_read_states', ['postable_id'], name: 'index_thredded_user_topic_read_states_on_postable_id', using: :btree
  add_index 'thredded_user_topic_read_states', ['user_id', 'postable_id'], name: 'thredded_user_topic_read_states_user_postable', unique: true, using: :btree

  create_table 'townships', force: :cascade do |t|
    t.string 'name'
    t.integer 'state_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_index 'townships', ['state_id'], name: 'index_townships_on_state_id', using: :btree

  create_table 'trackings', force: :cascade do |t|
    t.string 'name', default: ''
    t.jsonb 'fields', default: {}
    t.string 'frequency', default: ''
    t.integer 'time_of_frequency'
    t.integer 'program_stream_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.datetime 'deleted_at'
    t.boolean 'hidden', default: false
    t.string 'allowed_edit_until'
  end

  add_index 'trackings', ['deleted_at'], name: 'index_trackings_on_deleted_at', using: :btree
  add_index 'trackings', ['name', 'program_stream_id'], name: 'index_trackings_on_name_and_program_stream_id', unique: true, using: :btree
  add_index 'trackings', ['program_stream_id'], name: 'index_trackings_on_program_stream_id', using: :btree

  create_table 'usage_reports', force: :cascade do |t|
    t.integer 'organization_id'
    t.integer 'month'
    t.integer 'year'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.jsonb 'added_cases', default: {}
    t.jsonb 'synced_cases', default: {}
    t.jsonb 'cross_referral_cases', default: {}
    t.jsonb 'cross_referral_to_primero_cases', default: {}
    t.jsonb 'cross_referral_from_primero_cases', default: {}
    t.string 'organization_name'
    t.string 'organization_short_name'
    t.jsonb 'vulnerability', default: {}
  end

  add_index 'usage_reports', ['organization_id'], name: 'index_usage_reports_on_organization_id', using: :btree

  create_table 'users', force: :cascade do |t|
    t.string 'first_name', default: ''
    t.string 'last_name', default: ''
    t.string 'roles', default: 'case worker'
    t.date 'start_date'
    t.string 'job_title', default: ''
    t.string 'mobile', default: ''
    t.date 'date_of_birth'
    t.boolean 'archived', default: false
    t.integer 'province_id'
    t.integer 'department_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string 'email', default: '', null: false
    t.string 'encrypted_password', default: '', null: false
    t.string 'reset_password_token'
    t.datetime 'reset_password_sent_at'
    t.datetime 'remember_created_at'
    t.integer 'sign_in_count', default: 0, null: false
    t.datetime 'current_sign_in_at'
    t.datetime 'last_sign_in_at'
    t.inet 'current_sign_in_ip'
    t.inet 'last_sign_in_ip'
    t.integer 'clients_count', default: 0
    t.integer 'cases_count', default: 0
    t.integer 'tasks_count', default: 0
    t.string 'provider', default: 'email', null: false
    t.string 'uid', default: '', null: false
    t.json 'tokens'
    t.boolean 'admin', default: false
    t.integer 'changelogs_count', default: 0
    t.integer 'organization_id'
    t.boolean 'disable', default: false
    t.datetime 'expires_at'
    t.boolean 'task_notify', default: true
    t.integer 'manager_id'
    t.boolean 'calendar_integration', default: false
    t.integer 'pin_number'
    t.integer 'manager_ids', default: [], array: true
    t.boolean 'program_warning', default: false
    t.boolean 'staff_performance_notification', default: true
    t.string 'pin_code', default: ''
    t.boolean 'domain_warning', default: false
    t.boolean 'referral_notification', default: false
    t.string 'gender', default: ''
    t.boolean 'enable_gov_log_in', default: false
    t.boolean 'enable_research_log_in', default: false
    t.datetime 'deleted_at'
    t.datetime 'activated_at'
    t.datetime 'deactivated_at'
    t.string 'preferred_language', default: 'en'
    t.string 'organization_name'
    t.string 'profile'
  end

  add_index 'users', ['deleted_at'], name: 'index_users_on_deleted_at', using: :btree
  add_index 'users', ['department_id'], name: 'index_users_on_department_id', using: :btree
  add_index 'users', ['email'], name: 'index_users_on_email', unique: true, using: :btree
  add_index 'users', ['manager_id'], name: 'index_users_on_manager_id', using: :btree
  add_index 'users', ['organization_id'], name: 'index_users_on_organization_id', using: :btree
  add_index 'users', ['province_id'], name: 'index_users_on_province_id', using: :btree
  add_index 'users', ['reset_password_token'], name: 'index_users_on_reset_password_token', unique: true, using: :btree

  create_table 'version_associations', force: :cascade do |t|
    t.integer 'version_id'
    t.string 'foreign_key_name', null: false
    t.integer 'foreign_key_id'
  end

  add_index 'version_associations', ['foreign_key_id'], name: 'index_version_associations_on_foreign_key_id', using: :btree
  add_index 'version_associations', ['foreign_key_name', 'foreign_key_id'], name: 'index_version_associations_on_foreign_key', using: :btree
  add_index 'version_associations', ['version_id'], name: 'index_version_associations_on_version_id', using: :btree

  create_table 'versions', force: :cascade do |t|
    t.string 'item_type', null: false
    t.integer 'item_id', null: false
    t.string 'event', null: false
    t.string 'whodunnit'
    t.text 'old_object'
    t.datetime 'created_at'
    t.text 'old_object_changes'
    t.integer 'transaction_id'
    t.integer 'billable_report_id'
    t.string 'billable_status'
    t.datetime 'accepted_at'
    t.datetime 'billable_at'
    t.jsonb 'object'
    t.jsonb 'object_changes'
  end

  add_index 'versions', ['item_type', 'item_id'], name: 'index_versions_on_item_type_and_item_id', using: :btree
  add_index 'versions', ['transaction_id'], name: 'index_versions_on_transaction_id', using: :btree

  create_table 'villages', force: :cascade do |t|
    t.string 'code', default: ''
    t.string 'name_kh', default: ''
    t.string 'name_en', default: ''
    t.integer 'commune_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'villages', ['commune_id'], name: 'index_villages_on_commune_id', using: :btree

  create_table 'visit_clients', force: :cascade do |t|
    t.integer 'user_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.time 'deleted_at'
  end

  add_index 'visit_clients', ['user_id'], name: 'index_visit_clients_on_user_id', using: :btree

  create_table 'visits', force: :cascade do |t|
    t.integer 'user_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.time 'deleted_at'
  end

  add_index 'visits', ['user_id'], name: 'index_visits_on_user_id', using: :btree

  add_foreign_key 'able_screening_questions', 'question_groups'
  add_foreign_key 'able_screening_questions', 'stages'
  add_foreign_key 'achievement_program_staff_clients', 'clients'
  add_foreign_key 'achievement_program_staff_clients', 'users'
  add_foreign_key 'action_results', 'government_forms'
  add_foreign_key 'advanced_searches', 'users'
  add_foreign_key 'assessment_domains', 'care_plans'
  add_foreign_key 'assessments', 'clients', on_delete: :nullify
  add_foreign_key 'attachments', 'able_screening_questions'
  add_foreign_key 'attachments', 'progress_notes'
  add_foreign_key 'billable_report_items', 'billable_reports'
  add_foreign_key 'calendars', 'users'
  add_foreign_key 'call_necessities', 'calls'
  add_foreign_key 'call_necessities', 'necessities'
  add_foreign_key 'call_protection_concerns', 'calls'
  add_foreign_key 'call_protection_concerns', 'protection_concerns'
  add_foreign_key 'calls', 'referees'
  add_foreign_key 'care_plans', 'assessments'
  add_foreign_key 'care_plans', 'clients', on_delete: :nullify
  add_foreign_key 'carers', 'communes'
  add_foreign_key 'carers', 'districts'
  add_foreign_key 'carers', 'provinces'
  add_foreign_key 'carers', 'states'
  add_foreign_key 'carers', 'subdistricts'
  add_foreign_key 'carers', 'townships'
  add_foreign_key 'carers', 'villages'
  add_foreign_key 'case_conference_domains', 'case_conferences'
  add_foreign_key 'case_conference_domains', 'domains'
  add_foreign_key 'case_conference_users', 'case_conferences'
  add_foreign_key 'case_conference_users', 'users'
  add_foreign_key 'case_conferences', 'clients'
  add_foreign_key 'case_contracts', 'cases'
  add_foreign_key 'case_notes', 'clients', on_delete: :cascade
  add_foreign_key 'case_worker_communities', 'communities'
  add_foreign_key 'case_worker_communities', 'users'
  add_foreign_key 'case_worker_families', 'families'
  add_foreign_key 'case_worker_families', 'users'
  add_foreign_key 'case_worker_tasks', 'tasks'
  add_foreign_key 'case_worker_tasks', 'users'
  add_foreign_key 'changelog_types', 'changelogs'
  add_foreign_key 'changelogs', 'users'
  add_foreign_key 'cities', 'provinces'
  add_foreign_key 'client_client_types', 'client_types'
  add_foreign_key 'client_client_types', 'clients'
  add_foreign_key 'client_custom_data', 'clients'
  add_foreign_key 'client_custom_data', 'custom_data', column: 'custom_data_id'
  add_foreign_key 'client_enrollment_trackings', 'client_enrollments'
  add_foreign_key 'client_interviewees', 'clients'
  add_foreign_key 'client_interviewees', 'interviewees'
  add_foreign_key 'client_needs', 'clients'
  add_foreign_key 'client_needs', 'needs'
  add_foreign_key 'client_problems', 'clients'
  add_foreign_key 'client_problems', 'problems'
  add_foreign_key 'client_right_government_forms', 'client_rights'
  add_foreign_key 'client_right_government_forms', 'government_forms'
  add_foreign_key 'client_type_government_forms', 'client_types'
  add_foreign_key 'client_type_government_forms', 'government_forms'
  add_foreign_key 'clients', 'communes'
  add_foreign_key 'clients', 'districts'
  add_foreign_key 'clients', 'donors'
  add_foreign_key 'clients', 'states'
  add_foreign_key 'clients', 'subdistricts'
  add_foreign_key 'clients', 'townships'
  add_foreign_key 'clients', 'villages'
  add_foreign_key 'communes', 'districts'
  add_foreign_key 'communities', 'communes'
  add_foreign_key 'communities', 'districts'
  add_foreign_key 'communities', 'provinces'
  add_foreign_key 'communities', 'referral_sources'
  add_foreign_key 'communities', 'users'
  add_foreign_key 'communities', 'villages'
  add_foreign_key 'community_donors', 'communities'
  add_foreign_key 'community_donors', 'donors'
  add_foreign_key 'community_members', 'communities'
  add_foreign_key 'community_members', 'families'
  add_foreign_key 'community_quantitative_cases', 'communities'
  add_foreign_key 'community_quantitative_cases', 'quantitative_cases'
  add_foreign_key 'custom_field_permissions', 'custom_fields'
  add_foreign_key 'custom_field_permissions', 'users'
  add_foreign_key 'custom_field_properties', 'custom_fields'
  add_foreign_key 'districts', 'provinces'
  add_foreign_key 'domains', 'domain_groups'
  add_foreign_key 'donor_families', 'donors'
  add_foreign_key 'donor_families', 'families'
  add_foreign_key 'donor_organizations', 'donors'
  add_foreign_key 'donor_organizations', 'organizations'
  add_foreign_key 'enrollment_trackings', 'enrollments'
  add_foreign_key 'enrollment_trackings', 'trackings'
  add_foreign_key 'enrollments', 'program_streams'
  add_foreign_key 'enter_ngo_users', 'enter_ngos'
  add_foreign_key 'enter_ngo_users', 'users'
  add_foreign_key 'external_system_global_identities', 'external_systems'
  add_foreign_key 'external_system_global_identities', 'global_identities', column: 'global_id', primary_key: 'ulid'
  add_foreign_key 'families', 'communes'
  add_foreign_key 'families', 'districts'
  add_foreign_key 'families', 'users'
  add_foreign_key 'families', 'users', column: 'followed_up_by_id'
  add_foreign_key 'families', 'users', column: 'received_by_id'
  add_foreign_key 'families', 'villages'
  add_foreign_key 'family_members', 'clients'
  add_foreign_key 'family_members', 'families'
  add_foreign_key 'family_quantitative_cases', 'families'
  add_foreign_key 'family_quantitative_cases', 'quantitative_cases'
  add_foreign_key 'family_referrals', 'families'
  add_foreign_key 'global_identity_organizations', 'organizations'
  add_foreign_key 'goals', 'assessment_domains'
  add_foreign_key 'goals', 'assessments'
  add_foreign_key 'goals', 'care_plans'
  add_foreign_key 'goals', 'clients', on_delete: :nullify
  add_foreign_key 'goals', 'domains'
  add_foreign_key 'government_form_children_plans', 'children_plans'
  add_foreign_key 'government_form_children_plans', 'government_forms'
  add_foreign_key 'government_form_family_plans', 'family_plans'
  add_foreign_key 'government_form_family_plans', 'government_forms'
  add_foreign_key 'government_form_interviewees', 'government_forms'
  add_foreign_key 'government_form_interviewees', 'interviewees'
  add_foreign_key 'government_form_needs', 'government_forms'
  add_foreign_key 'government_form_needs', 'needs'
  add_foreign_key 'government_form_problems', 'government_forms'
  add_foreign_key 'government_form_problems', 'problems'
  add_foreign_key 'government_form_service_types', 'government_forms'
  add_foreign_key 'government_form_service_types', 'service_types'
  add_foreign_key 'government_forms', 'clients'
  add_foreign_key 'government_forms', 'communes'
  add_foreign_key 'government_forms', 'districts'
  add_foreign_key 'government_forms', 'provinces'
  add_foreign_key 'government_forms', 'villages'
  add_foreign_key 'hotlines', 'calls'
  add_foreign_key 'hotlines', 'clients'
  add_foreign_key 'internal_referral_program_streams', 'internal_referrals'
  add_foreign_key 'internal_referral_program_streams', 'program_streams'
  add_foreign_key 'leave_programs', 'client_enrollments'
  add_foreign_key 'leave_programs', 'enrollments'
  add_foreign_key 'notifications', 'users'
  add_foreign_key 'oauth_access_grants', 'oauth_applications', column: 'application_id'
  add_foreign_key 'oauth_access_tokens', 'oauth_applications', column: 'application_id'
  add_foreign_key 'partners', 'organization_types'
  add_foreign_key 'program_stream_permissions', 'program_streams'
  add_foreign_key 'program_stream_permissions', 'users'
  add_foreign_key 'program_stream_services', 'program_streams'
  add_foreign_key 'program_stream_services', 'services'
  add_foreign_key 'progress_notes', 'clients'
  add_foreign_key 'progress_notes', 'locations'
  add_foreign_key 'progress_notes', 'materials'
  add_foreign_key 'progress_notes', 'progress_note_types'
  add_foreign_key 'progress_notes', 'users'
  add_foreign_key 'quantitative_type_permissions', 'quantitative_types'
  add_foreign_key 'quantitative_type_permissions', 'users'
  add_foreign_key 'quarterly_reports', 'cases'
  add_foreign_key 'referees', 'communes'
  add_foreign_key 'referees', 'districts'
  add_foreign_key 'referees', 'provinces'
  add_foreign_key 'referees', 'states'
  add_foreign_key 'referees', 'subdistricts'
  add_foreign_key 'referees', 'townships'
  add_foreign_key 'referees', 'villages'
  add_foreign_key 'referrals', 'clients'
  add_foreign_key 'risk_assessments', 'clients'
  add_foreign_key 'service_delivery_tasks', 'service_deliveries'
  add_foreign_key 'service_delivery_tasks', 'tasks'
  add_foreign_key 'services', 'global_services', column: 'uuid', primary_key: 'uuid'
  add_foreign_key 'settings', 'communes'
  add_foreign_key 'settings', 'districts'
  add_foreign_key 'settings', 'provinces'
  add_foreign_key 'sponsors', 'clients', on_delete: :nullify
  add_foreign_key 'sponsors', 'donors'
  add_foreign_key 'subdistricts', 'districts'
  add_foreign_key 'surveys', 'clients'
  add_foreign_key 'tasks', 'clients', on_delete: :nullify
  add_foreign_key 'tasks', 'goals'
  add_foreign_key 'townships', 'states'
  add_foreign_key 'trackings', 'program_streams'
  add_foreign_key 'users', 'organizations'
  add_foreign_key 'villages', 'communes'
  add_foreign_key 'visit_clients', 'users'
  add_foreign_key 'visits', 'users'
end
