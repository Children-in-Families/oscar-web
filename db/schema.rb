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

ActiveRecord::Schema.define(version: 2020_12_14_014711) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "able_screening_questions", id: :serial, force: :cascade do |t|
    t.string "question"
    t.string "mode"
    t.integer "stage_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "alert_manager"
    t.integer "question_group_id"
    t.index ["question_group_id"], name: "index_able_screening_questions_on_question_group_id"
    t.index ["question_group_id"], name: "index_able_screening_questions_on_question_group_id"
    t.index ["stage_id"], name: "index_able_screening_questions_on_stage_id"
    t.index ["stage_id"], name: "index_able_screening_questions_on_stage_id"
  end

  create_table "able_screening_questions", id: :serial, force: :cascade do |t|
    t.string "question"
    t.string "mode"
    t.integer "stage_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "alert_manager"
    t.integer "question_group_id"
    t.index ["question_group_id"], name: "index_able_screening_questions_on_question_group_id"
    t.index ["question_group_id"], name: "index_able_screening_questions_on_question_group_id"
    t.index ["stage_id"], name: "index_able_screening_questions_on_stage_id"
    t.index ["stage_id"], name: "index_able_screening_questions_on_stage_id"
  end

  create_table "action_results", id: :serial, force: :cascade do |t|
    t.text "action", default: ""
    t.text "result", default: ""
    t.integer "government_form_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["government_form_id"], name: "index_action_results_on_government_form_id"
    t.index ["government_form_id"], name: "index_action_results_on_government_form_id"
  end

  create_table "action_results", id: :serial, force: :cascade do |t|
    t.text "action", default: ""
    t.text "result", default: ""
    t.integer "government_form_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["government_form_id"], name: "index_action_results_on_government_form_id"
    t.index ["government_form_id"], name: "index_action_results_on_government_form_id"
  end

  create_table "admin_users", id: :integer, default: nil, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "token"
    t.string "first_name"
    t.string "last_name"
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.json "tokens"
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_admin_users_on_uid_and_provider", unique: true
    t.index ["uid", "provider"], name: "index_admin_users_on_uid_and_provider", unique: true
  end

  create_table "admin_users", id: :integer, default: nil, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "token"
    t.string "first_name"
    t.string "last_name"
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.json "tokens"
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_admin_users_on_uid_and_provider", unique: true
    t.index ["uid", "provider"], name: "index_admin_users_on_uid_and_provider", unique: true
  end

  create_table "advanced_searches", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.jsonb "queries"
    t.jsonb "field_visible"
    t.string "custom_forms"
    t.string "program_streams"
    t.string "enrollment_check", default: ""
    t.string "tracking_check", default: ""
    t.string "exit_form_check", default: ""
    t.string "quantitative_check", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.string "hotline_check", default: ""
    t.index ["user_id"], name: "index_advanced_searches_on_user_id"
    t.index ["user_id"], name: "index_advanced_searches_on_user_id"
  end

  create_table "advanced_searches", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.jsonb "queries"
    t.jsonb "field_visible"
    t.string "custom_forms"
    t.string "program_streams"
    t.string "enrollment_check", default: ""
    t.string "tracking_check", default: ""
    t.string "exit_form_check", default: ""
    t.string "quantitative_check", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.string "hotline_check", default: ""
    t.index ["user_id"], name: "index_advanced_searches_on_user_id"
    t.index ["user_id"], name: "index_advanced_searches_on_user_id"
  end

  create_table "agencies", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.text "description", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "agencies_clients_count", default: 0
  end

  create_table "agencies", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.text "description", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "agencies_clients_count", default: 0
  end

  create_table "agencies_clients", id: :serial, force: :cascade do |t|
    t.integer "client_id"
    t.integer "agency_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "agencies_clients", id: :serial, force: :cascade do |t|
    t.integer "client_id"
    t.integer "agency_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "agency_clients", id: :serial, force: :cascade do |t|
    t.integer "agency_id"
    t.integer "client_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "agency_clients", id: :serial, force: :cascade do |t|
    t.integer "agency_id"
    t.integer "client_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "assessment_domains", id: :serial, force: :cascade do |t|
    t.text "note", default: ""
    t.integer "previous_score"
    t.integer "score"
    t.text "reason", default: ""
    t.integer "assessment_id"
    t.integer "domain_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "goal", default: ""
    t.string "attachments", default: [], array: true
    t.boolean "goal_required", default: true
    t.boolean "required_task_last", default: false
    t.index ["score"], name: "index_assessment_domains_on_score"
    t.index ["score"], name: "index_assessment_domains_on_score"
  end

  create_table "assessment_domains", id: :serial, force: :cascade do |t|
    t.text "note", default: ""
    t.integer "previous_score"
    t.integer "score"
    t.text "reason", default: ""
    t.integer "assessment_id"
    t.integer "domain_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "goal", default: ""
    t.string "attachments", default: [], array: true
    t.boolean "goal_required", default: true
    t.boolean "required_task_last", default: false
    t.index ["score"], name: "index_assessment_domains_on_score"
    t.index ["score"], name: "index_assessment_domains_on_score"
  end

  create_table "assessments", id: :serial, force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "client_id"
    t.boolean "completed", default: false
    t.boolean "default", default: true
    t.index ["client_id"], name: "index_assessments_on_client_id"
    t.index ["client_id"], name: "index_assessments_on_client_id"
  end

  create_table "assessments", id: :serial, force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "client_id"
    t.boolean "completed", default: false
    t.boolean "default", default: true
    t.index ["client_id"], name: "index_assessments_on_client_id"
    t.index ["client_id"], name: "index_assessments_on_client_id"
  end

  create_table "attachments", id: :serial, force: :cascade do |t|
    t.string "image"
    t.integer "able_screening_question_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "file", default: ""
    t.integer "progress_note_id"
    t.index ["able_screening_question_id"], name: "index_attachments_on_able_screening_question_id"
    t.index ["able_screening_question_id"], name: "index_attachments_on_able_screening_question_id"
    t.index ["progress_note_id"], name: "index_attachments_on_progress_note_id"
    t.index ["progress_note_id"], name: "index_attachments_on_progress_note_id"
  end

  create_table "attachments", id: :serial, force: :cascade do |t|
    t.string "image"
    t.integer "able_screening_question_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "file", default: ""
    t.integer "progress_note_id"
    t.index ["able_screening_question_id"], name: "index_attachments_on_able_screening_question_id"
    t.index ["able_screening_question_id"], name: "index_attachments_on_able_screening_question_id"
    t.index ["progress_note_id"], name: "index_attachments_on_progress_note_id"
    t.index ["progress_note_id"], name: "index_attachments_on_progress_note_id"
  end

  create_table "calendars", id: :serial, force: :cascade do |t|
    t.string "title"
    t.datetime "start_date"
    t.datetime "end_date"
    t.boolean "sync_status", default: false
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_calendars_on_user_id"
    t.index ["user_id"], name: "index_calendars_on_user_id"
  end

  create_table "calendars", id: :serial, force: :cascade do |t|
    t.string "title"
    t.datetime "start_date"
    t.datetime "end_date"
    t.boolean "sync_status", default: false
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_calendars_on_user_id"
    t.index ["user_id"], name: "index_calendars_on_user_id"
  end

  create_table "call_necessities", id: :serial, force: :cascade do |t|
    t.integer "call_id"
    t.integer "necessity_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["call_id"], name: "index_call_necessities_on_call_id"
    t.index ["call_id"], name: "index_call_necessities_on_call_id"
    t.index ["necessity_id"], name: "index_call_necessities_on_necessity_id"
    t.index ["necessity_id"], name: "index_call_necessities_on_necessity_id"
  end

  create_table "call_necessities", id: :serial, force: :cascade do |t|
    t.integer "call_id"
    t.integer "necessity_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["call_id"], name: "index_call_necessities_on_call_id"
    t.index ["call_id"], name: "index_call_necessities_on_call_id"
    t.index ["necessity_id"], name: "index_call_necessities_on_necessity_id"
    t.index ["necessity_id"], name: "index_call_necessities_on_necessity_id"
  end

  create_table "call_protection_concerns", id: :serial, force: :cascade do |t|
    t.integer "call_id"
    t.integer "protection_concern_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["call_id"], name: "index_call_protection_concerns_on_call_id"
    t.index ["call_id"], name: "index_call_protection_concerns_on_call_id"
    t.index ["protection_concern_id"], name: "index_call_protection_concerns_on_protection_concern_id"
    t.index ["protection_concern_id"], name: "index_call_protection_concerns_on_protection_concern_id"
  end

  create_table "call_protection_concerns", id: :serial, force: :cascade do |t|
    t.integer "call_id"
    t.integer "protection_concern_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["call_id"], name: "index_call_protection_concerns_on_call_id"
    t.index ["call_id"], name: "index_call_protection_concerns_on_call_id"
    t.index ["protection_concern_id"], name: "index_call_protection_concerns_on_protection_concern_id"
    t.index ["protection_concern_id"], name: "index_call_protection_concerns_on_protection_concern_id"
  end

  create_table "calls", id: :serial, force: :cascade do |t|
    t.integer "referee_id"
    t.string "phone_call_id", default: ""
    t.integer "receiving_staff_id"
    t.datetime "start_datetime"
    t.string "call_type", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "information_provided", default: ""
    t.date "date_of_call"
    t.boolean "answered_call"
    t.boolean "called_before"
    t.boolean "requested_update", default: false
    t.boolean "not_a_phone_call", default: false
    t.boolean "childsafe_agent"
    t.string "other_more_information", default: ""
    t.string "brief_note_summary", default: ""
    t.index ["referee_id"], name: "index_calls_on_referee_id"
    t.index ["referee_id"], name: "index_calls_on_referee_id"
  end

  create_table "calls", id: :serial, force: :cascade do |t|
    t.integer "referee_id"
    t.string "phone_call_id", default: ""
    t.integer "receiving_staff_id"
    t.datetime "start_datetime"
    t.string "call_type", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "information_provided", default: ""
    t.date "date_of_call"
    t.boolean "answered_call"
    t.boolean "called_before"
    t.boolean "requested_update", default: false
    t.boolean "not_a_phone_call", default: false
    t.boolean "childsafe_agent"
    t.string "other_more_information", default: ""
    t.string "brief_note_summary", default: ""
    t.index ["referee_id"], name: "index_calls_on_referee_id"
    t.index ["referee_id"], name: "index_calls_on_referee_id"
  end

  create_table "carers", id: :serial, force: :cascade do |t|
    t.string "address_type", default: ""
    t.string "current_address", default: ""
    t.string "email", default: ""
    t.string "gender", default: ""
    t.string "house_number", default: ""
    t.string "outside_address", default: ""
    t.string "street_number", default: ""
    t.string "client_relationship", default: ""
    t.boolean "outside", default: false
    t.integer "province_id"
    t.integer "district_id"
    t.integer "commune_id"
    t.integer "village_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", default: ""
    t.string "phone", default: ""
    t.boolean "same_as_client", default: false
    t.string "suburb", default: ""
    t.string "description_house_landmark", default: ""
    t.string "directions", default: ""
    t.string "street_line1", default: ""
    t.string "street_line2", default: ""
    t.string "plot", default: ""
    t.string "road", default: ""
    t.string "postal_code", default: ""
    t.integer "state_id"
    t.integer "township_id"
    t.integer "subdistrict_id"
    t.string "locality"
    t.index ["commune_id"], name: "index_carers_on_commune_id"
    t.index ["commune_id"], name: "index_carers_on_commune_id"
    t.index ["district_id"], name: "index_carers_on_district_id"
    t.index ["district_id"], name: "index_carers_on_district_id"
    t.index ["province_id"], name: "index_carers_on_province_id"
    t.index ["province_id"], name: "index_carers_on_province_id"
    t.index ["state_id"], name: "index_carers_on_state_id"
    t.index ["state_id"], name: "index_carers_on_state_id"
    t.index ["subdistrict_id"], name: "index_carers_on_subdistrict_id"
    t.index ["subdistrict_id"], name: "index_carers_on_subdistrict_id"
    t.index ["township_id"], name: "index_carers_on_township_id"
    t.index ["township_id"], name: "index_carers_on_township_id"
    t.index ["village_id"], name: "index_carers_on_village_id"
    t.index ["village_id"], name: "index_carers_on_village_id"
  end

  create_table "carers", id: :serial, force: :cascade do |t|
    t.string "address_type", default: ""
    t.string "current_address", default: ""
    t.string "email", default: ""
    t.string "gender", default: ""
    t.string "house_number", default: ""
    t.string "outside_address", default: ""
    t.string "street_number", default: ""
    t.string "client_relationship", default: ""
    t.boolean "outside", default: false
    t.integer "province_id"
    t.integer "district_id"
    t.integer "commune_id"
    t.integer "village_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", default: ""
    t.string "phone", default: ""
    t.boolean "same_as_client", default: false
    t.string "suburb", default: ""
    t.string "description_house_landmark", default: ""
    t.string "directions", default: ""
    t.string "street_line1", default: ""
    t.string "street_line2", default: ""
    t.string "plot", default: ""
    t.string "road", default: ""
    t.string "postal_code", default: ""
    t.integer "state_id"
    t.integer "township_id"
    t.integer "subdistrict_id"
    t.string "locality"
    t.index ["commune_id"], name: "index_carers_on_commune_id"
    t.index ["commune_id"], name: "index_carers_on_commune_id"
    t.index ["district_id"], name: "index_carers_on_district_id"
    t.index ["district_id"], name: "index_carers_on_district_id"
    t.index ["province_id"], name: "index_carers_on_province_id"
    t.index ["province_id"], name: "index_carers_on_province_id"
    t.index ["state_id"], name: "index_carers_on_state_id"
    t.index ["state_id"], name: "index_carers_on_state_id"
    t.index ["subdistrict_id"], name: "index_carers_on_subdistrict_id"
    t.index ["subdistrict_id"], name: "index_carers_on_subdistrict_id"
    t.index ["township_id"], name: "index_carers_on_township_id"
    t.index ["township_id"], name: "index_carers_on_township_id"
    t.index ["village_id"], name: "index_carers_on_village_id"
    t.index ["village_id"], name: "index_carers_on_village_id"
  end

  create_table "case_closures", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "case_closures", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "case_contracts", id: :serial, force: :cascade do |t|
    t.date "signed_on"
    t.integer "case_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["case_id"], name: "index_case_contracts_on_case_id"
    t.index ["case_id"], name: "index_case_contracts_on_case_id"
  end

  create_table "case_contracts", id: :serial, force: :cascade do |t|
    t.date "signed_on"
    t.integer "case_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["case_id"], name: "index_case_contracts_on_case_id"
    t.index ["case_id"], name: "index_case_contracts_on_case_id"
  end

  create_table "case_note_domain_groups", id: :serial, force: :cascade do |t|
    t.text "note", default: ""
    t.integer "case_note_id"
    t.integer "domain_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "attachments", default: [], array: true
  end

  create_table "case_note_domain_groups", id: :serial, force: :cascade do |t|
    t.text "note", default: ""
    t.integer "case_note_id"
    t.integer "domain_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "attachments", default: [], array: true
  end

  create_table "case_notes", id: :serial, force: :cascade do |t|
    t.string "attendee", default: ""
    t.datetime "meeting_date"
    t.integer "assessment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "client_id"
    t.string "interaction_type", default: ""
    t.boolean "custom", default: false
    t.text "note", default: ""
    t.integer "custom_assessment_setting_id"
    t.string "selected_domain_group_ids", default: [], array: true
    t.index ["client_id"], name: "index_case_notes_on_client_id"
    t.index ["client_id"], name: "index_case_notes_on_client_id"
    t.index ["custom_assessment_setting_id"], name: "index_case_notes_on_custom_assessment_setting_id"
    t.index ["custom_assessment_setting_id"], name: "index_case_notes_on_custom_assessment_setting_id"
  end

  create_table "case_notes", id: :serial, force: :cascade do |t|
    t.string "attendee", default: ""
    t.datetime "meeting_date"
    t.integer "assessment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "client_id"
    t.string "interaction_type", default: ""
    t.boolean "custom", default: false
    t.text "note", default: ""
    t.integer "custom_assessment_setting_id"
    t.string "selected_domain_group_ids", default: [], array: true
    t.index ["client_id"], name: "index_case_notes_on_client_id"
    t.index ["client_id"], name: "index_case_notes_on_client_id"
    t.index ["custom_assessment_setting_id"], name: "index_case_notes_on_custom_assessment_setting_id"
    t.index ["custom_assessment_setting_id"], name: "index_case_notes_on_custom_assessment_setting_id"
  end

  create_table "case_worker_clients", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "client_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["client_id"], name: "index_case_worker_clients_on_client_id"
    t.index ["client_id"], name: "index_case_worker_clients_on_client_id"
    t.index ["user_id"], name: "index_case_worker_clients_on_user_id"
    t.index ["user_id"], name: "index_case_worker_clients_on_user_id"
  end

  create_table "case_worker_clients", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "client_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["client_id"], name: "index_case_worker_clients_on_client_id"
    t.index ["client_id"], name: "index_case_worker_clients_on_client_id"
    t.index ["user_id"], name: "index_case_worker_clients_on_user_id"
    t.index ["user_id"], name: "index_case_worker_clients_on_user_id"
  end

  create_table "case_worker_tasks", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "task_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["task_id"], name: "index_case_worker_tasks_on_task_id"
    t.index ["task_id"], name: "index_case_worker_tasks_on_task_id"
    t.index ["user_id"], name: "index_case_worker_tasks_on_user_id"
    t.index ["user_id"], name: "index_case_worker_tasks_on_user_id"
  end

  create_table "case_worker_tasks", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "task_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["task_id"], name: "index_case_worker_tasks_on_task_id"
    t.index ["task_id"], name: "index_case_worker_tasks_on_task_id"
    t.index ["user_id"], name: "index_case_worker_tasks_on_user_id"
    t.index ["user_id"], name: "index_case_worker_tasks_on_user_id"
  end

  create_table "cases", id: :serial, force: :cascade do |t|
    t.date "start_date"
    t.string "carer_names", default: ""
    t.string "carer_address", default: ""
    t.string "carer_phone_number", default: ""
    t.float "support_amount", default: 0.0
    t.text "support_note", default: ""
    t.text "case_type", default: "EC"
    t.boolean "exited", default: false
    t.date "exit_date"
    t.text "exit_note", default: ""
    t.integer "user_id"
    t.integer "client_id"
    t.integer "family_id"
    t.integer "partner_id"
    t.integer "province_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "family_preservation", default: false
    t.string "status", default: ""
    t.date "placement_date"
    t.date "initial_assessment_date"
    t.float "case_length"
    t.date "case_conference_date"
    t.float "time_in_care"
    t.boolean "exited_from_cif", default: false
    t.boolean "current", default: true
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_cases_on_deleted_at"
    t.index ["deleted_at"], name: "index_cases_on_deleted_at"
  end

  create_table "cases", id: :serial, force: :cascade do |t|
    t.date "start_date"
    t.string "carer_names", default: ""
    t.string "carer_address", default: ""
    t.string "carer_phone_number", default: ""
    t.float "support_amount", default: 0.0
    t.text "support_note", default: ""
    t.text "case_type", default: "EC"
    t.boolean "exited", default: false
    t.date "exit_date"
    t.text "exit_note", default: ""
    t.integer "user_id"
    t.integer "client_id"
    t.integer "family_id"
    t.integer "partner_id"
    t.integer "province_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "family_preservation", default: false
    t.string "status", default: ""
    t.date "placement_date"
    t.date "initial_assessment_date"
    t.float "case_length"
    t.date "case_conference_date"
    t.float "time_in_care"
    t.boolean "exited_from_cif", default: false
    t.boolean "current", default: true
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_cases_on_deleted_at"
    t.index ["deleted_at"], name: "index_cases_on_deleted_at"
  end

  create_table "changelog_types", id: :serial, force: :cascade do |t|
    t.integer "changelog_id"
    t.string "change_type", default: ""
    t.string "description", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["changelog_id"], name: "index_changelog_types_on_changelog_id"
    t.index ["changelog_id"], name: "index_changelog_types_on_changelog_id"
  end

  create_table "changelog_types", id: :serial, force: :cascade do |t|
    t.integer "changelog_id"
    t.string "change_type", default: ""
    t.string "description", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["changelog_id"], name: "index_changelog_types_on_changelog_id"
    t.index ["changelog_id"], name: "index_changelog_types_on_changelog_id"
  end

  create_table "changelogs", id: :serial, force: :cascade do |t|
    t.string "change_version", default: ""
    t.string "description", default: ""
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "index_changelogs_on_user_id"
    t.index ["user_id"], name: "index_changelogs_on_user_id"
  end

  create_table "changelogs", id: :serial, force: :cascade do |t|
    t.string "change_version", default: ""
    t.string "description", default: ""
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "index_changelogs_on_user_id"
    t.index ["user_id"], name: "index_changelogs_on_user_id"
  end

  create_table "children_plans", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "children_plans", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "client_client_types", id: :serial, force: :cascade do |t|
    t.integer "client_id"
    t.integer "client_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["client_id"], name: "index_client_client_types_on_client_id"
    t.index ["client_id"], name: "index_client_client_types_on_client_id"
    t.index ["client_type_id"], name: "index_client_client_types_on_client_type_id"
    t.index ["client_type_id"], name: "index_client_client_types_on_client_type_id"
  end

  create_table "client_client_types", id: :serial, force: :cascade do |t|
    t.integer "client_id"
    t.integer "client_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["client_id"], name: "index_client_client_types_on_client_id"
    t.index ["client_id"], name: "index_client_client_types_on_client_id"
    t.index ["client_type_id"], name: "index_client_client_types_on_client_type_id"
    t.index ["client_type_id"], name: "index_client_client_types_on_client_type_id"
  end

  create_table "client_enrollment_trackings", id: :serial, force: :cascade do |t|
    t.jsonb "properties", default: {}
    t.integer "client_enrollment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "tracking_id"
    t.index ["client_enrollment_id"], name: "index_client_enrollment_trackings_on_client_enrollment_id"
    t.index ["client_enrollment_id"], name: "index_client_enrollment_trackings_on_client_enrollment_id"
  end

  create_table "client_enrollment_trackings", id: :serial, force: :cascade do |t|
    t.jsonb "properties", default: {}
    t.integer "client_enrollment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "tracking_id"
    t.index ["client_enrollment_id"], name: "index_client_enrollment_trackings_on_client_enrollment_id"
    t.index ["client_enrollment_id"], name: "index_client_enrollment_trackings_on_client_enrollment_id"
  end

  create_table "client_enrollments", id: :serial, force: :cascade do |t|
    t.jsonb "properties", default: {}
    t.string "status", default: "Active"
    t.integer "client_id"
    t.integer "program_stream_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "enrollment_date"
    t.datetime "deleted_at"
    t.index ["client_id"], name: "index_client_enrollments_on_client_id"
    t.index ["client_id"], name: "index_client_enrollments_on_client_id"
    t.index ["deleted_at"], name: "index_client_enrollments_on_deleted_at"
    t.index ["deleted_at"], name: "index_client_enrollments_on_deleted_at"
    t.index ["program_stream_id"], name: "index_client_enrollments_on_program_stream_id"
    t.index ["program_stream_id"], name: "index_client_enrollments_on_program_stream_id"
  end

  create_table "client_enrollments", id: :serial, force: :cascade do |t|
    t.jsonb "properties", default: {}
    t.string "status", default: "Active"
    t.integer "client_id"
    t.integer "program_stream_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "enrollment_date"
    t.datetime "deleted_at"
    t.index ["client_id"], name: "index_client_enrollments_on_client_id"
    t.index ["client_id"], name: "index_client_enrollments_on_client_id"
    t.index ["deleted_at"], name: "index_client_enrollments_on_deleted_at"
    t.index ["deleted_at"], name: "index_client_enrollments_on_deleted_at"
    t.index ["program_stream_id"], name: "index_client_enrollments_on_program_stream_id"
    t.index ["program_stream_id"], name: "index_client_enrollments_on_program_stream_id"
  end

  create_table "client_interviewees", id: :serial, force: :cascade do |t|
    t.integer "client_id"
    t.integer "interviewee_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["client_id"], name: "index_client_interviewees_on_client_id"
    t.index ["client_id"], name: "index_client_interviewees_on_client_id"
    t.index ["interviewee_id"], name: "index_client_interviewees_on_interviewee_id"
    t.index ["interviewee_id"], name: "index_client_interviewees_on_interviewee_id"
  end

  create_table "client_interviewees", id: :serial, force: :cascade do |t|
    t.integer "client_id"
    t.integer "interviewee_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["client_id"], name: "index_client_interviewees_on_client_id"
    t.index ["client_id"], name: "index_client_interviewees_on_client_id"
    t.index ["interviewee_id"], name: "index_client_interviewees_on_interviewee_id"
    t.index ["interviewee_id"], name: "index_client_interviewees_on_interviewee_id"
  end

  create_table "client_needs", id: :serial, force: :cascade do |t|
    t.integer "rank"
    t.integer "client_id"
    t.integer "need_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["client_id"], name: "index_client_needs_on_client_id"
    t.index ["client_id"], name: "index_client_needs_on_client_id"
    t.index ["need_id"], name: "index_client_needs_on_need_id"
    t.index ["need_id"], name: "index_client_needs_on_need_id"
  end

  create_table "client_needs", id: :serial, force: :cascade do |t|
    t.integer "rank"
    t.integer "client_id"
    t.integer "need_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["client_id"], name: "index_client_needs_on_client_id"
    t.index ["client_id"], name: "index_client_needs_on_client_id"
    t.index ["need_id"], name: "index_client_needs_on_need_id"
    t.index ["need_id"], name: "index_client_needs_on_need_id"
  end

  create_table "client_problems", id: :serial, force: :cascade do |t|
    t.integer "rank"
    t.integer "client_id"
    t.integer "problem_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["client_id"], name: "index_client_problems_on_client_id"
    t.index ["client_id"], name: "index_client_problems_on_client_id"
    t.index ["problem_id"], name: "index_client_problems_on_problem_id"
    t.index ["problem_id"], name: "index_client_problems_on_problem_id"
  end

  create_table "client_problems", id: :serial, force: :cascade do |t|
    t.integer "rank"
    t.integer "client_id"
    t.integer "problem_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["client_id"], name: "index_client_problems_on_client_id"
    t.index ["client_id"], name: "index_client_problems_on_client_id"
    t.index ["problem_id"], name: "index_client_problems_on_problem_id"
    t.index ["problem_id"], name: "index_client_problems_on_problem_id"
  end

  create_table "client_quantitative_cases", id: :serial, force: :cascade do |t|
    t.integer "quantitative_case_id"
    t.integer "client_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "client_quantitative_cases", id: :serial, force: :cascade do |t|
    t.integer "quantitative_case_id"
    t.integer "client_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "client_right_government_forms", id: :serial, force: :cascade do |t|
    t.integer "government_form_id"
    t.integer "client_right_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_right_id"], name: "index_client_right_government_forms_on_client_right_id"
    t.index ["client_right_id"], name: "index_client_right_government_forms_on_client_right_id"
    t.index ["government_form_id"], name: "index_client_right_government_forms_on_government_form_id"
    t.index ["government_form_id"], name: "index_client_right_government_forms_on_government_form_id"
  end

  create_table "client_right_government_forms", id: :serial, force: :cascade do |t|
    t.integer "government_form_id"
    t.integer "client_right_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_right_id"], name: "index_client_right_government_forms_on_client_right_id"
    t.index ["client_right_id"], name: "index_client_right_government_forms_on_client_right_id"
    t.index ["government_form_id"], name: "index_client_right_government_forms_on_government_form_id"
    t.index ["government_form_id"], name: "index_client_right_government_forms_on_government_form_id"
  end

  create_table "client_rights", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "client_rights", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "client_type_government_forms", id: :serial, force: :cascade do |t|
    t.integer "client_type_id"
    t.integer "government_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["client_type_id"], name: "index_client_type_government_forms_on_client_type_id"
    t.index ["client_type_id"], name: "index_client_type_government_forms_on_client_type_id"
    t.index ["government_form_id"], name: "index_client_type_government_forms_on_government_form_id"
    t.index ["government_form_id"], name: "index_client_type_government_forms_on_government_form_id"
  end

  create_table "client_type_government_forms", id: :serial, force: :cascade do |t|
    t.integer "client_type_id"
    t.integer "government_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["client_type_id"], name: "index_client_type_government_forms_on_client_type_id"
    t.index ["client_type_id"], name: "index_client_type_government_forms_on_client_type_id"
    t.index ["government_form_id"], name: "index_client_type_government_forms_on_government_form_id"
    t.index ["government_form_id"], name: "index_client_type_government_forms_on_government_form_id"
  end

  create_table "client_types", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "client_types", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "clients", id: :serial, force: :cascade do |t|
    t.string "code", default: ""
    t.string "given_name", default: ""
    t.string "family_name", default: ""
    t.string "gender", default: ""
    t.date "date_of_birth"
    t.string "status", default: "Referred"
    t.date "initial_referral_date"
    t.string "referral_phone", default: ""
    t.integer "birth_province_id"
    t.integer "received_by_id"
    t.integer "followed_up_by_id"
    t.date "follow_up_date"
    t.string "current_address", default: ""
    t.string "school_name", default: ""
    t.string "school_grade", default: ""
    t.boolean "has_been_in_orphanage"
    t.boolean "able", default: false
    t.boolean "has_been_in_government_care"
    t.text "relevant_referral_information", default: ""
    t.string "archive_state", default: ""
    t.text "rejected_note", default: ""
    t.integer "province_id"
    t.integer "referral_source_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "completed", default: false
    t.text "reason_for_referral", default: ""
    t.boolean "is_receiving_additional_benefits", default: false
    t.text "background", default: ""
    t.integer "grade"
    t.string "slug"
    t.string "able_state", default: ""
    t.integer "donor_id"
    t.string "local_given_name", default: ""
    t.string "local_family_name", default: ""
    t.string "kid_id", default: ""
    t.string "house_number", default: ""
    t.string "street_number", default: ""
    t.string "old_village", default: ""
    t.string "old_commune", default: ""
    t.string "archive_district", default: ""
    t.string "live_with", default: ""
    t.integer "id_poor"
    t.integer "rice_support", default: 0
    t.text "exit_note", default: ""
    t.date "exit_date"
    t.date "accepted_date"
    t.string "gov_city", default: ""
    t.string "gov_commune", default: ""
    t.string "gov_district", default: ""
    t.date "gov_date"
    t.string "gov_village_code", default: ""
    t.string "gov_client_code", default: ""
    t.string "gov_interview_village", default: ""
    t.string "gov_interview_commune", default: ""
    t.string "gov_interview_district", default: ""
    t.string "gov_interview_city", default: ""
    t.string "gov_caseworker_name", default: ""
    t.string "gov_caseworker_phone", default: ""
    t.string "gov_carer_name", default: ""
    t.string "gov_carer_relationship", default: ""
    t.string "gov_carer_home", default: ""
    t.string "gov_carer_street", default: ""
    t.string "gov_carer_village", default: ""
    t.string "gov_carer_commune", default: ""
    t.string "gov_carer_district", default: ""
    t.string "gov_carer_city", default: ""
    t.string "gov_carer_phone", default: ""
    t.string "gov_information_source", default: ""
    t.text "gov_referral_reason", default: ""
    t.text "gov_guardian_comment", default: ""
    t.text "gov_caseworker_comment", default: ""
    t.integer "district_id"
    t.string "telephone_number", default: ""
    t.string "name_of_referee", default: ""
    t.string "main_school_contact", default: ""
    t.string "rated_for_id_poor", default: ""
    t.string "what3words", default: ""
    t.string "exit_reasons", default: [], array: true
    t.string "exit_circumstance", default: ""
    t.string "other_info_of_exit", default: ""
    t.string "suburb", default: ""
    t.string "description_house_landmark", default: ""
    t.string "directions", default: ""
    t.string "street_line1", default: ""
    t.string "street_line2", default: ""
    t.string "plot", default: ""
    t.string "road", default: ""
    t.string "postal_code", default: ""
    t.integer "subdistrict_id"
    t.integer "township_id"
    t.integer "state_id"
    t.string "country_origin", default: ""
    t.integer "commune_id"
    t.integer "village_id"
    t.string "profile"
    t.integer "referral_source_category_id"
    t.string "archived_slug"
    t.integer "assessments_count", default: 0, null: false
    t.integer "current_family_id"
    t.boolean "outside", default: false
    t.string "outside_address", default: ""
    t.string "address_type", default: ""
    t.string "client_phone", default: ""
    t.string "phone_owner", default: ""
    t.string "client_email", default: ""
    t.string "referee_relationship", default: ""
    t.integer "referee_id"
    t.integer "carer_id"
    t.string "nickname", default: ""
    t.string "relation_to_referee", default: ""
    t.boolean "concern_is_outside", default: false
    t.string "concern_outside_address", default: ""
    t.integer "concern_province_id"
    t.integer "concern_district_id"
    t.integer "concern_commune_id"
    t.integer "concern_village_id"
    t.string "concern_street", default: ""
    t.string "concern_house", default: ""
    t.string "concern_address", default: ""
    t.string "concern_address_type", default: ""
    t.string "concern_phone", default: ""
    t.string "concern_phone_owner", default: ""
    t.string "concern_email", default: ""
    t.string "concern_email_owner", default: ""
    t.string "concern_location", default: ""
    t.boolean "concern_same_as_client", default: false
    t.string "location_description", default: ""
    t.string "phone_counselling_summary", default: ""
    t.string "presented_id"
    t.string "id_number"
    t.string "other_phone_number"
    t.string "brsc_branch"
    t.string "current_island"
    t.string "current_street"
    t.string "current_po_box"
    t.string "current_city"
    t.string "current_settlement"
    t.string "current_resident_own_or_rent"
    t.string "current_household_type"
    t.string "island2"
    t.string "street2"
    t.string "po_box2"
    t.string "city2"
    t.string "settlement2"
    t.string "resident_own_or_rent2"
    t.string "household_type2"
    t.string "legacy_brcs_id"
    t.boolean "whatsapp", default: false
    t.string "global_id"
    t.string "external_id"
    t.string "external_id_display"
    t.string "mosvy_number"
    t.string "external_case_worker_name"
    t.string "external_case_worker_id"
    t.boolean "other_phone_whatsapp", default: false
    t.string "preferred_language", default: "English"
    t.boolean "national_id", default: false, null: false
    t.boolean "birth_cert", default: false, null: false
    t.boolean "family_book", default: false, null: false
    t.boolean "passport", default: false, null: false
    t.boolean "travel_doc", default: false, null: false
    t.boolean "referral_doc", default: false, null: false
    t.boolean "local_consent", default: false, null: false
    t.boolean "police_interview", default: false, null: false
    t.boolean "other_legal_doc", default: false, null: false
    t.string "national_id_files", default: [], array: true
    t.string "birth_cert_files", default: [], array: true
    t.string "family_book_files", default: [], array: true
    t.string "passport_files", default: [], array: true
    t.string "travel_doc_files", default: [], array: true
    t.string "referral_doc_files", default: [], array: true
    t.string "local_consent_files", default: [], array: true
    t.string "police_interview_files", default: [], array: true
    t.string "other_legal_doc_files", default: [], array: true
    t.boolean "referred_external", default: false
    t.string "marital_status"
    t.string "nationality"
    t.string "ethnicity"
    t.string "location_of_concern"
    t.string "type_of_trafficking"
    t.text "education_background"
    t.string "department"
    t.string "neighbor_name"
    t.string "neighbor_phone"
    t.string "dosavy_name"
    t.string "dosavy_phone"
    t.string "chief_commune_name"
    t.string "chief_commune_phone"
    t.string "chief_village_name"
    t.string "chief_village_phone"
    t.string "ccwc_name"
    t.string "ccwc_phone"
    t.string "legal_team_name"
    t.string "legal_representative_name"
    t.string "legal_team_phone"
    t.string "other_agency_name"
    t.string "other_representative_name"
    t.string "other_agency_phone"
    t.string "locality"
    t.string "national_id_number"
    t.string "passport_number"
    t.index ["commune_id"], name: "index_clients_on_commune_id"
    t.index ["commune_id"], name: "index_clients_on_commune_id"
    t.index ["current_family_id"], name: "index_clients_on_current_family_id"
    t.index ["current_family_id"], name: "index_clients_on_current_family_id"
    t.index ["district_id"], name: "index_clients_on_district_id"
    t.index ["district_id"], name: "index_clients_on_district_id"
    t.index ["donor_id"], name: "index_clients_on_donor_id"
    t.index ["donor_id"], name: "index_clients_on_donor_id"
    t.index ["external_id"], name: "index_clients_on_external_id"
    t.index ["external_id"], name: "index_clients_on_external_id"
    t.index ["global_id"], name: "index_clients_on_global_id"
    t.index ["global_id"], name: "index_clients_on_global_id"
    t.index ["mosvy_number"], name: "index_clients_on_mosvy_number"
    t.index ["mosvy_number"], name: "index_clients_on_mosvy_number"
    t.index ["slug"], name: "index_clients_on_slug", unique: true
    t.index ["slug"], name: "index_clients_on_slug", unique: true
    t.index ["state_id"], name: "index_clients_on_state_id"
    t.index ["state_id"], name: "index_clients_on_state_id"
    t.index ["subdistrict_id"], name: "index_clients_on_subdistrict_id"
    t.index ["subdistrict_id"], name: "index_clients_on_subdistrict_id"
    t.index ["township_id"], name: "index_clients_on_township_id"
    t.index ["township_id"], name: "index_clients_on_township_id"
    t.index ["village_id"], name: "index_clients_on_village_id"
    t.index ["village_id"], name: "index_clients_on_village_id"
  end

  create_table "clients", id: :serial, force: :cascade do |t|
    t.string "code", default: ""
    t.string "given_name", default: ""
    t.string "family_name", default: ""
    t.string "gender", default: ""
    t.date "date_of_birth"
    t.string "status", default: "Referred"
    t.date "initial_referral_date"
    t.string "referral_phone", default: ""
    t.integer "birth_province_id"
    t.integer "received_by_id"
    t.integer "followed_up_by_id"
    t.date "follow_up_date"
    t.string "current_address", default: ""
    t.string "school_name", default: ""
    t.string "school_grade", default: ""
    t.boolean "has_been_in_orphanage"
    t.boolean "able", default: false
    t.boolean "has_been_in_government_care"
    t.text "relevant_referral_information", default: ""
    t.string "archive_state", default: ""
    t.text "rejected_note", default: ""
    t.integer "province_id"
    t.integer "referral_source_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "completed", default: false
    t.text "reason_for_referral", default: ""
    t.boolean "is_receiving_additional_benefits", default: false
    t.text "background", default: ""
    t.integer "grade"
    t.string "slug"
    t.string "able_state", default: ""
    t.integer "donor_id"
    t.string "local_given_name", default: ""
    t.string "local_family_name", default: ""
    t.string "kid_id", default: ""
    t.string "house_number", default: ""
    t.string "street_number", default: ""
    t.string "old_village", default: ""
    t.string "old_commune", default: ""
    t.string "archive_district", default: ""
    t.string "live_with", default: ""
    t.integer "id_poor"
    t.integer "rice_support", default: 0
    t.text "exit_note", default: ""
    t.date "exit_date"
    t.date "accepted_date"
    t.string "gov_city", default: ""
    t.string "gov_commune", default: ""
    t.string "gov_district", default: ""
    t.date "gov_date"
    t.string "gov_village_code", default: ""
    t.string "gov_client_code", default: ""
    t.string "gov_interview_village", default: ""
    t.string "gov_interview_commune", default: ""
    t.string "gov_interview_district", default: ""
    t.string "gov_interview_city", default: ""
    t.string "gov_caseworker_name", default: ""
    t.string "gov_caseworker_phone", default: ""
    t.string "gov_carer_name", default: ""
    t.string "gov_carer_relationship", default: ""
    t.string "gov_carer_home", default: ""
    t.string "gov_carer_street", default: ""
    t.string "gov_carer_village", default: ""
    t.string "gov_carer_commune", default: ""
    t.string "gov_carer_district", default: ""
    t.string "gov_carer_city", default: ""
    t.string "gov_carer_phone", default: ""
    t.string "gov_information_source", default: ""
    t.text "gov_referral_reason", default: ""
    t.text "gov_guardian_comment", default: ""
    t.text "gov_caseworker_comment", default: ""
    t.integer "district_id"
    t.string "telephone_number", default: ""
    t.string "name_of_referee", default: ""
    t.string "main_school_contact", default: ""
    t.string "rated_for_id_poor", default: ""
    t.string "what3words", default: ""
    t.string "exit_reasons", default: [], array: true
    t.string "exit_circumstance", default: ""
    t.string "other_info_of_exit", default: ""
    t.string "suburb", default: ""
    t.string "description_house_landmark", default: ""
    t.string "directions", default: ""
    t.string "street_line1", default: ""
    t.string "street_line2", default: ""
    t.string "plot", default: ""
    t.string "road", default: ""
    t.string "postal_code", default: ""
    t.integer "subdistrict_id"
    t.integer "township_id"
    t.integer "state_id"
    t.string "country_origin", default: ""
    t.integer "commune_id"
    t.integer "village_id"
    t.string "profile"
    t.integer "referral_source_category_id"
    t.string "archived_slug"
    t.integer "assessments_count", default: 0, null: false
    t.integer "current_family_id"
    t.boolean "outside", default: false
    t.string "outside_address", default: ""
    t.string "address_type", default: ""
    t.string "client_phone", default: ""
    t.string "phone_owner", default: ""
    t.string "client_email", default: ""
    t.string "referee_relationship", default: ""
    t.integer "referee_id"
    t.integer "carer_id"
    t.string "nickname", default: ""
    t.string "relation_to_referee", default: ""
    t.boolean "concern_is_outside", default: false
    t.string "concern_outside_address", default: ""
    t.integer "concern_province_id"
    t.integer "concern_district_id"
    t.integer "concern_commune_id"
    t.integer "concern_village_id"
    t.string "concern_street", default: ""
    t.string "concern_house", default: ""
    t.string "concern_address", default: ""
    t.string "concern_address_type", default: ""
    t.string "concern_phone", default: ""
    t.string "concern_phone_owner", default: ""
    t.string "concern_email", default: ""
    t.string "concern_email_owner", default: ""
    t.string "concern_location", default: ""
    t.boolean "concern_same_as_client", default: false
    t.string "location_description", default: ""
    t.string "phone_counselling_summary", default: ""
    t.string "presented_id"
    t.string "id_number"
    t.string "other_phone_number"
    t.string "brsc_branch"
    t.string "current_island"
    t.string "current_street"
    t.string "current_po_box"
    t.string "current_city"
    t.string "current_settlement"
    t.string "current_resident_own_or_rent"
    t.string "current_household_type"
    t.string "island2"
    t.string "street2"
    t.string "po_box2"
    t.string "city2"
    t.string "settlement2"
    t.string "resident_own_or_rent2"
    t.string "household_type2"
    t.string "legacy_brcs_id"
    t.boolean "whatsapp", default: false
    t.string "global_id"
    t.string "external_id"
    t.string "external_id_display"
    t.string "mosvy_number"
    t.string "external_case_worker_name"
    t.string "external_case_worker_id"
    t.boolean "other_phone_whatsapp", default: false
    t.string "preferred_language", default: "English"
    t.boolean "national_id", default: false, null: false
    t.boolean "birth_cert", default: false, null: false
    t.boolean "family_book", default: false, null: false
    t.boolean "passport", default: false, null: false
    t.boolean "travel_doc", default: false, null: false
    t.boolean "referral_doc", default: false, null: false
    t.boolean "local_consent", default: false, null: false
    t.boolean "police_interview", default: false, null: false
    t.boolean "other_legal_doc", default: false, null: false
    t.string "national_id_files", default: [], array: true
    t.string "birth_cert_files", default: [], array: true
    t.string "family_book_files", default: [], array: true
    t.string "passport_files", default: [], array: true
    t.string "travel_doc_files", default: [], array: true
    t.string "referral_doc_files", default: [], array: true
    t.string "local_consent_files", default: [], array: true
    t.string "police_interview_files", default: [], array: true
    t.string "other_legal_doc_files", default: [], array: true
    t.boolean "referred_external", default: false
    t.string "marital_status"
    t.string "nationality"
    t.string "ethnicity"
    t.string "location_of_concern"
    t.string "type_of_trafficking"
    t.text "education_background"
    t.string "department"
    t.string "neighbor_name"
    t.string "neighbor_phone"
    t.string "dosavy_name"
    t.string "dosavy_phone"
    t.string "chief_commune_name"
    t.string "chief_commune_phone"
    t.string "chief_village_name"
    t.string "chief_village_phone"
    t.string "ccwc_name"
    t.string "ccwc_phone"
    t.string "legal_team_name"
    t.string "legal_representative_name"
    t.string "legal_team_phone"
    t.string "other_agency_name"
    t.string "other_representative_name"
    t.string "other_agency_phone"
    t.string "locality"
    t.string "national_id_number"
    t.string "passport_number"
    t.index ["commune_id"], name: "index_clients_on_commune_id"
    t.index ["commune_id"], name: "index_clients_on_commune_id"
    t.index ["current_family_id"], name: "index_clients_on_current_family_id"
    t.index ["current_family_id"], name: "index_clients_on_current_family_id"
    t.index ["district_id"], name: "index_clients_on_district_id"
    t.index ["district_id"], name: "index_clients_on_district_id"
    t.index ["donor_id"], name: "index_clients_on_donor_id"
    t.index ["donor_id"], name: "index_clients_on_donor_id"
    t.index ["external_id"], name: "index_clients_on_external_id"
    t.index ["external_id"], name: "index_clients_on_external_id"
    t.index ["global_id"], name: "index_clients_on_global_id"
    t.index ["global_id"], name: "index_clients_on_global_id"
    t.index ["mosvy_number"], name: "index_clients_on_mosvy_number"
    t.index ["mosvy_number"], name: "index_clients_on_mosvy_number"
    t.index ["slug"], name: "index_clients_on_slug", unique: true
    t.index ["slug"], name: "index_clients_on_slug", unique: true
    t.index ["state_id"], name: "index_clients_on_state_id"
    t.index ["state_id"], name: "index_clients_on_state_id"
    t.index ["subdistrict_id"], name: "index_clients_on_subdistrict_id"
    t.index ["subdistrict_id"], name: "index_clients_on_subdistrict_id"
    t.index ["township_id"], name: "index_clients_on_township_id"
    t.index ["township_id"], name: "index_clients_on_township_id"
    t.index ["village_id"], name: "index_clients_on_village_id"
    t.index ["village_id"], name: "index_clients_on_village_id"
  end

  create_table "clients_quantitative_cases", id: :serial, force: :cascade do |t|
    t.integer "client_id"
    t.integer "quantitative_case_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "clients_quantitative_cases", id: :serial, force: :cascade do |t|
    t.integer "client_id"
    t.integer "quantitative_case_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "communes", id: :serial, force: :cascade do |t|
    t.string "code", default: ""
    t.string "name_kh", default: ""
    t.string "name_en", default: ""
    t.integer "district_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "district_type"
    t.index ["district_id"], name: "index_communes_on_district_id"
    t.index ["district_id"], name: "index_communes_on_district_id"
  end

  create_table "communes", id: :serial, force: :cascade do |t|
    t.string "code", default: ""
    t.string "name_kh", default: ""
    t.string "name_en", default: ""
    t.integer "district_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "district_type"
    t.index ["district_id"], name: "index_communes_on_district_id"
    t.index ["district_id"], name: "index_communes_on_district_id"
  end

  create_table "custom_assessment_settings", id: :serial, force: :cascade do |t|
    t.string "custom_assessment_name", default: "Custom Assessment"
    t.integer "max_custom_assessment", default: 6
    t.string "custom_assessment_frequency", default: "month"
    t.integer "custom_age", default: 18
    t.integer "setting_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "enable_custom_assessment", default: false
  end

  create_table "custom_assessment_settings", id: :serial, force: :cascade do |t|
    t.string "custom_assessment_name", default: "Custom Assessment"
    t.integer "max_custom_assessment", default: 6
    t.string "custom_assessment_frequency", default: "month"
    t.integer "custom_age", default: 18
    t.integer "setting_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "enable_custom_assessment", default: false
  end

  create_table "custom_field_permissions", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "custom_field_id"
    t.boolean "readable", default: true
    t.boolean "editable", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["custom_field_id"], name: "index_custom_field_permissions_on_custom_field_id"
    t.index ["custom_field_id"], name: "index_custom_field_permissions_on_custom_field_id"
    t.index ["user_id"], name: "index_custom_field_permissions_on_user_id"
    t.index ["user_id"], name: "index_custom_field_permissions_on_user_id"
  end

  create_table "custom_field_permissions", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "custom_field_id"
    t.boolean "readable", default: true
    t.boolean "editable", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["custom_field_id"], name: "index_custom_field_permissions_on_custom_field_id"
    t.index ["custom_field_id"], name: "index_custom_field_permissions_on_custom_field_id"
    t.index ["user_id"], name: "index_custom_field_permissions_on_user_id"
    t.index ["user_id"], name: "index_custom_field_permissions_on_user_id"
  end

  create_table "custom_field_properties", id: :serial, force: :cascade do |t|
    t.jsonb "properties", default: {}
    t.string "custom_formable_type"
    t.integer "custom_formable_id"
    t.integer "custom_field_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "attachments"
    t.integer "user_id"
    t.index ["custom_field_id"], name: "index_custom_field_properties_on_custom_field_id"
    t.index ["custom_field_id"], name: "index_custom_field_properties_on_custom_field_id"
  end

  create_table "custom_field_properties", id: :serial, force: :cascade do |t|
    t.jsonb "properties", default: {}
    t.string "custom_formable_type"
    t.integer "custom_formable_id"
    t.integer "custom_field_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "attachments"
    t.integer "user_id"
    t.index ["custom_field_id"], name: "index_custom_field_properties_on_custom_field_id"
    t.index ["custom_field_id"], name: "index_custom_field_properties_on_custom_field_id"
  end

  create_table "custom_fields", id: :serial, force: :cascade do |t|
    t.string "entity_type", default: ""
    t.text "properties", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "form_title", default: ""
    t.string "frequency", default: ""
    t.integer "time_of_frequency", default: 0
    t.string "ngo_name", default: ""
    t.jsonb "fields"
  end

  create_table "custom_fields", id: :serial, force: :cascade do |t|
    t.string "entity_type", default: ""
    t.text "properties", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "form_title", default: ""
    t.string "frequency", default: ""
    t.integer "time_of_frequency", default: 0
    t.string "ngo_name", default: ""
    t.jsonb "fields"
  end

  create_table "departments", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.text "description", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "users_count", default: 0
  end

  create_table "departments", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.text "description", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "users_count", default: 0
  end

  create_table "districts", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "province_id"
    t.string "code", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["province_id"], name: "index_districts_on_province_id"
    t.index ["province_id"], name: "index_districts_on_province_id"
  end

  create_table "districts", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "province_id"
    t.string "code", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["province_id"], name: "index_districts_on_province_id"
    t.index ["province_id"], name: "index_districts_on_province_id"
  end

  create_table "domain_groups", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.text "description", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "domains_count", default: 0
  end

  create_table "domain_groups", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.text "description", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "domains_count", default: 0
  end

  create_table "domain_program_streams", id: :serial, force: :cascade do |t|
    t.integer "program_stream_id"
    t.integer "domain_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_domain_program_streams_on_deleted_at"
    t.index ["deleted_at"], name: "index_domain_program_streams_on_deleted_at"
  end

  create_table "domain_program_streams", id: :serial, force: :cascade do |t|
    t.integer "program_stream_id"
    t.integer "domain_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_domain_program_streams_on_deleted_at"
    t.index ["deleted_at"], name: "index_domain_program_streams_on_deleted_at"
  end

  create_table "domains", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.string "identity", default: ""
    t.text "description", default: ""
    t.integer "domain_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "tasks_count", default: 0
    t.string "score_1_color", default: "danger"
    t.string "score_2_color", default: "warning"
    t.string "score_3_color", default: "info"
    t.string "score_4_color", default: "primary"
    t.text "score_1_definition", default: ""
    t.text "score_2_definition", default: ""
    t.text "score_3_definition", default: ""
    t.text "score_4_definition", default: ""
    t.boolean "custom_domain", default: false
    t.text "local_description", default: ""
    t.text "score_1_local_definition", default: ""
    t.text "score_2_local_definition", default: ""
    t.text "score_3_local_definition", default: ""
    t.text "score_4_local_definition", default: ""
    t.integer "custom_assessment_setting_id"
    t.index ["domain_group_id"], name: "index_domains_on_domain_group_id"
    t.index ["domain_group_id"], name: "index_domains_on_domain_group_id"
  end

  create_table "domains", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.string "identity", default: ""
    t.text "description", default: ""
    t.integer "domain_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "tasks_count", default: 0
    t.string "score_1_color", default: "danger"
    t.string "score_2_color", default: "warning"
    t.string "score_3_color", default: "info"
    t.string "score_4_color", default: "primary"
    t.text "score_1_definition", default: ""
    t.text "score_2_definition", default: ""
    t.text "score_3_definition", default: ""
    t.text "score_4_definition", default: ""
    t.boolean "custom_domain", default: false
    t.text "local_description", default: ""
    t.text "score_1_local_definition", default: ""
    t.text "score_2_local_definition", default: ""
    t.text "score_3_local_definition", default: ""
    t.text "score_4_local_definition", default: ""
    t.integer "custom_assessment_setting_id"
    t.index ["domain_group_id"], name: "index_domains_on_domain_group_id"
    t.index ["domain_group_id"], name: "index_domains_on_domain_group_id"
  end

  create_table "donor_organizations", id: :integer, default: nil, force: :cascade do |t|
    t.integer "donor_id"
    t.integer "organization_id"
    t.index ["donor_id"], name: "index_donor_organizations_on_donor_id"
    t.index ["donor_id"], name: "index_donor_organizations_on_donor_id"
    t.index ["organization_id"], name: "index_donor_organizations_on_organization_id"
    t.index ["organization_id"], name: "index_donor_organizations_on_organization_id"
  end

  create_table "donor_organizations", id: :integer, default: nil, force: :cascade do |t|
    t.integer "donor_id"
    t.integer "organization_id"
    t.index ["donor_id"], name: "index_donor_organizations_on_donor_id"
    t.index ["donor_id"], name: "index_donor_organizations_on_donor_id"
    t.index ["organization_id"], name: "index_donor_organizations_on_organization_id"
    t.index ["organization_id"], name: "index_donor_organizations_on_organization_id"
  end

  create_table "donors", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.text "description", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "code", default: ""
    t.string "global_id", limit: 32, default: ""
    t.index ["global_id"], name: "index_donors_on_global_id"
    t.index ["global_id"], name: "index_donors_on_global_id"
  end

  create_table "donors", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.text "description", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "code", default: ""
    t.string "global_id", limit: 32, default: ""
    t.index ["global_id"], name: "index_donors_on_global_id"
    t.index ["global_id"], name: "index_donors_on_global_id"
  end

  create_table "enrollment_trackings", id: :serial, force: :cascade do |t|
    t.integer "enrollment_id"
    t.integer "tracking_id"
    t.jsonb "properties", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["enrollment_id"], name: "index_enrollment_trackings_on_enrollment_id"
    t.index ["enrollment_id"], name: "index_enrollment_trackings_on_enrollment_id"
    t.index ["tracking_id"], name: "index_enrollment_trackings_on_tracking_id"
    t.index ["tracking_id"], name: "index_enrollment_trackings_on_tracking_id"
  end

  create_table "enrollment_trackings", id: :serial, force: :cascade do |t|
    t.integer "enrollment_id"
    t.integer "tracking_id"
    t.jsonb "properties", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["enrollment_id"], name: "index_enrollment_trackings_on_enrollment_id"
    t.index ["enrollment_id"], name: "index_enrollment_trackings_on_enrollment_id"
    t.index ["tracking_id"], name: "index_enrollment_trackings_on_tracking_id"
    t.index ["tracking_id"], name: "index_enrollment_trackings_on_tracking_id"
  end

  create_table "enrollments", id: :serial, force: :cascade do |t|
    t.jsonb "properties", default: {}
    t.string "status", default: "Active"
    t.date "enrollment_date"
    t.datetime "deleted_at"
    t.string "programmable_type"
    t.integer "programmable_id"
    t.integer "program_stream_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_enrollments_on_deleted_at"
    t.index ["deleted_at"], name: "index_enrollments_on_deleted_at"
    t.index ["program_stream_id"], name: "index_enrollments_on_program_stream_id"
    t.index ["program_stream_id"], name: "index_enrollments_on_program_stream_id"
  end

  create_table "enrollments", id: :serial, force: :cascade do |t|
    t.jsonb "properties", default: {}
    t.string "status", default: "Active"
    t.date "enrollment_date"
    t.datetime "deleted_at"
    t.string "programmable_type"
    t.integer "programmable_id"
    t.integer "program_stream_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_enrollments_on_deleted_at"
    t.index ["deleted_at"], name: "index_enrollments_on_deleted_at"
    t.index ["program_stream_id"], name: "index_enrollments_on_program_stream_id"
    t.index ["program_stream_id"], name: "index_enrollments_on_program_stream_id"
  end

  create_table "enter_ngo_users", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "enter_ngo_id"
    t.index ["enter_ngo_id"], name: "index_enter_ngo_users_on_enter_ngo_id"
    t.index ["enter_ngo_id"], name: "index_enter_ngo_users_on_enter_ngo_id"
    t.index ["user_id"], name: "index_enter_ngo_users_on_user_id"
    t.index ["user_id"], name: "index_enter_ngo_users_on_user_id"
  end

  create_table "enter_ngo_users", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "enter_ngo_id"
    t.index ["enter_ngo_id"], name: "index_enter_ngo_users_on_enter_ngo_id"
    t.index ["enter_ngo_id"], name: "index_enter_ngo_users_on_enter_ngo_id"
    t.index ["user_id"], name: "index_enter_ngo_users_on_user_id"
    t.index ["user_id"], name: "index_enter_ngo_users_on_user_id"
  end

  create_table "enter_ngos", id: :serial, force: :cascade do |t|
    t.date "accepted_date"
    t.integer "client_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.index ["client_id"], name: "index_enter_ngos_on_client_id"
    t.index ["client_id"], name: "index_enter_ngos_on_client_id"
    t.index ["deleted_at"], name: "index_enter_ngos_on_deleted_at"
    t.index ["deleted_at"], name: "index_enter_ngos_on_deleted_at"
  end

  create_table "enter_ngos", id: :serial, force: :cascade do |t|
    t.date "accepted_date"
    t.integer "client_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.index ["client_id"], name: "index_enter_ngos_on_client_id"
    t.index ["client_id"], name: "index_enter_ngos_on_client_id"
    t.index ["deleted_at"], name: "index_enter_ngos_on_deleted_at"
    t.index ["deleted_at"], name: "index_enter_ngos_on_deleted_at"
  end

  create_table "exit_ngos", id: :serial, force: :cascade do |t|
    t.integer "client_id"
    t.string "exit_circumstance", default: ""
    t.string "other_info_of_exit", default: ""
    t.string "exit_reasons", default: [], array: true
    t.text "exit_note", default: ""
    t.date "exit_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.index ["client_id"], name: "index_exit_ngos_on_client_id"
    t.index ["client_id"], name: "index_exit_ngos_on_client_id"
    t.index ["deleted_at"], name: "index_exit_ngos_on_deleted_at"
    t.index ["deleted_at"], name: "index_exit_ngos_on_deleted_at"
  end

  create_table "exit_ngos", id: :serial, force: :cascade do |t|
    t.integer "client_id"
    t.string "exit_circumstance", default: ""
    t.string "other_info_of_exit", default: ""
    t.string "exit_reasons", default: [], array: true
    t.text "exit_note", default: ""
    t.date "exit_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.index ["client_id"], name: "index_exit_ngos_on_client_id"
    t.index ["client_id"], name: "index_exit_ngos_on_client_id"
    t.index ["deleted_at"], name: "index_exit_ngos_on_deleted_at"
    t.index ["deleted_at"], name: "index_exit_ngos_on_deleted_at"
  end

  create_table "external_system_global_identities", id: :integer, default: nil, force: :cascade do |t|
    t.integer "external_system_id"
    t.string "global_id"
    t.string "external_id"
    t.string "client_slug"
    t.string "organization_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_system_id"], name: "index_external_system_global_identities_on_external_system_id"
    t.index ["external_system_id"], name: "index_external_system_global_identities_on_external_system_id"
    t.index ["global_id"], name: "index_external_system_global_identities_on_global_id"
    t.index ["global_id"], name: "index_external_system_global_identities_on_global_id"
  end

  create_table "external_system_global_identities", id: :integer, default: nil, force: :cascade do |t|
    t.integer "external_system_id"
    t.string "global_id"
    t.string "external_id"
    t.string "client_slug"
    t.string "organization_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_system_id"], name: "index_external_system_global_identities_on_external_system_id"
    t.index ["external_system_id"], name: "index_external_system_global_identities_on_external_system_id"
    t.index ["global_id"], name: "index_external_system_global_identities_on_global_id"
    t.index ["global_id"], name: "index_external_system_global_identities_on_global_id"
  end

  create_table "external_systems", id: :integer, default: nil, force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "external_systems", id: :integer, default: nil, force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "families", id: :serial, force: :cascade do |t|
    t.string "code"
    t.string "name", default: ""
    t.string "address", default: ""
    t.text "caregiver_information", default: ""
    t.integer "significant_family_member_count", default: 1
    t.float "household_income", default: 0.0
    t.boolean "dependable_income", default: false
    t.integer "female_children_count", default: 0
    t.integer "male_children_count", default: 0
    t.integer "female_adult_count", default: 0
    t.integer "male_adult_count", default: 0
    t.string "family_type", default: "kinship"
    t.date "contract_date"
    t.integer "province_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "cases_count", default: 0
    t.string "case_history", default: ""
    t.integer "children", default: [], array: true
    t.string "status", default: ""
    t.integer "district_id"
    t.string "old_commune", default: ""
    t.string "old_village", default: ""
    t.string "house", default: ""
    t.string "street", default: ""
    t.integer "commune_id"
    t.integer "village_id"
    t.integer "user_id"
    t.datetime "deleted_at"
    t.string "slug", default: ""
    t.index ["commune_id"], name: "index_families_on_commune_id"
    t.index ["commune_id"], name: "index_families_on_commune_id"
    t.index ["deleted_at"], name: "index_families_on_deleted_at"
    t.index ["deleted_at"], name: "index_families_on_deleted_at"
    t.index ["district_id"], name: "index_families_on_district_id"
    t.index ["district_id"], name: "index_families_on_district_id"
    t.index ["user_id"], name: "index_families_on_user_id"
    t.index ["user_id"], name: "index_families_on_user_id"
    t.index ["village_id"], name: "index_families_on_village_id"
    t.index ["village_id"], name: "index_families_on_village_id"
  end

  create_table "families", id: :serial, force: :cascade do |t|
    t.string "code"
    t.string "name", default: ""
    t.string "address", default: ""
    t.text "caregiver_information", default: ""
    t.integer "significant_family_member_count", default: 1
    t.float "household_income", default: 0.0
    t.boolean "dependable_income", default: false
    t.integer "female_children_count", default: 0
    t.integer "male_children_count", default: 0
    t.integer "female_adult_count", default: 0
    t.integer "male_adult_count", default: 0
    t.string "family_type", default: "kinship"
    t.date "contract_date"
    t.integer "province_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "cases_count", default: 0
    t.string "case_history", default: ""
    t.integer "children", default: [], array: true
    t.string "status", default: ""
    t.integer "district_id"
    t.string "old_commune", default: ""
    t.string "old_village", default: ""
    t.string "house", default: ""
    t.string "street", default: ""
    t.integer "commune_id"
    t.integer "village_id"
    t.integer "user_id"
    t.datetime "deleted_at"
    t.string "slug", default: ""
    t.index ["commune_id"], name: "index_families_on_commune_id"
    t.index ["commune_id"], name: "index_families_on_commune_id"
    t.index ["deleted_at"], name: "index_families_on_deleted_at"
    t.index ["deleted_at"], name: "index_families_on_deleted_at"
    t.index ["district_id"], name: "index_families_on_district_id"
    t.index ["district_id"], name: "index_families_on_district_id"
    t.index ["user_id"], name: "index_families_on_user_id"
    t.index ["user_id"], name: "index_families_on_user_id"
    t.index ["village_id"], name: "index_families_on_village_id"
    t.index ["village_id"], name: "index_families_on_village_id"
  end

  create_table "family_members", id: :serial, force: :cascade do |t|
    t.string "adult_name", default: ""
    t.date "date_of_birth"
    t.string "occupation", default: ""
    t.string "relation", default: ""
    t.integer "family_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "guardian", default: false
    t.string "gender"
    t.text "note"
    t.index ["family_id"], name: "index_family_members_on_family_id"
    t.index ["family_id"], name: "index_family_members_on_family_id"
  end

  create_table "family_members", id: :serial, force: :cascade do |t|
    t.string "adult_name", default: ""
    t.date "date_of_birth"
    t.string "occupation", default: ""
    t.string "relation", default: ""
    t.integer "family_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "guardian", default: false
    t.string "gender"
    t.text "note"
    t.index ["family_id"], name: "index_family_members_on_family_id"
    t.index ["family_id"], name: "index_family_members_on_family_id"
  end

  create_table "family_plans", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "priority"
  end

  create_table "family_plans", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "priority"
  end

  create_table "family_referrals", id: :serial, force: :cascade do |t|
    t.string "slug", default: ""
    t.date "date_of_referral"
    t.string "referred_to", default: ""
    t.string "referred_from", default: ""
    t.text "referral_reason", default: ""
    t.string "name_of_referee", default: ""
    t.string "referral_phone", default: ""
    t.string "name_of_family", default: ""
    t.string "ngo_name", default: ""
    t.integer "referee_id"
    t.boolean "saved", default: false
    t.string "consent_form", default: [], array: true
    t.integer "family_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["family_id"], name: "index_family_referrals_on_family_id"
    t.index ["family_id"], name: "index_family_referrals_on_family_id"
  end

  create_table "family_referrals", id: :serial, force: :cascade do |t|
    t.string "slug", default: ""
    t.date "date_of_referral"
    t.string "referred_to", default: ""
    t.string "referred_from", default: ""
    t.text "referral_reason", default: ""
    t.string "name_of_referee", default: ""
    t.string "referral_phone", default: ""
    t.string "name_of_family", default: ""
    t.string "ngo_name", default: ""
    t.integer "referee_id"
    t.boolean "saved", default: false
    t.string "consent_form", default: [], array: true
    t.integer "family_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["family_id"], name: "index_family_referrals_on_family_id"
    t.index ["family_id"], name: "index_family_referrals_on_family_id"
  end

  create_table "field_setting_translations", id: :serial, force: :cascade do |t|
    t.integer "field_setting_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "label"
    t.index ["field_setting_id"], name: "index_field_setting_translations_on_field_setting_id"
    t.index ["field_setting_id"], name: "index_field_setting_translations_on_field_setting_id"
    t.index ["locale"], name: "index_field_setting_translations_on_locale"
    t.index ["locale"], name: "index_field_setting_translations_on_locale"
  end

  create_table "field_setting_translations", id: :serial, force: :cascade do |t|
    t.integer "field_setting_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "label"
    t.index ["field_setting_id"], name: "index_field_setting_translations_on_field_setting_id"
    t.index ["field_setting_id"], name: "index_field_setting_translations_on_field_setting_id"
    t.index ["locale"], name: "index_field_setting_translations_on_locale"
    t.index ["locale"], name: "index_field_setting_translations_on_locale"
  end

  create_table "field_settings", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "group", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type", default: "field", null: false
    t.boolean "visible", default: true, null: false
    t.string "current_label"
    t.boolean "required", default: false
    t.string "klass_name"
    t.string "for_instances"
    t.boolean "label_only", default: false
  end

  create_table "field_settings", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "group", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type", default: "field", null: false
    t.boolean "visible", default: true, null: false
    t.string "current_label"
    t.boolean "required", default: false
    t.string "klass_name"
    t.string "for_instances"
    t.boolean "label_only", default: false
  end

  create_table "form_builder_attachments", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.jsonb "file", default: []
    t.string "form_buildable_type"
    t.integer "form_buildable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "form_builder_attachments", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.jsonb "file", default: []
    t.string "form_buildable_type"
    t.integer "form_buildable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "friendly_id_slugs", id: :serial, force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "friendly_id_slugs", id: :serial, force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "global_identities", id: false, force: :cascade do |t|
    t.string "ulid"
    t.index ["ulid"], name: "index_global_identities_on_ulid", unique: true
    t.index ["ulid"], name: "index_global_identities_on_ulid", unique: true
  end

  create_table "global_identities", id: false, force: :cascade do |t|
    t.string "ulid"
    t.index ["ulid"], name: "index_global_identities_on_ulid", unique: true
    t.index ["ulid"], name: "index_global_identities_on_ulid", unique: true
  end

  create_table "global_identity_organizations", id: :integer, default: nil, force: :cascade do |t|
    t.string "global_id"
    t.integer "organization_id"
    t.integer "client_id"
    t.index ["client_id"], name: "index_global_identity_organizations_on_client_id"
    t.index ["client_id"], name: "index_global_identity_organizations_on_client_id"
    t.index ["global_id"], name: "index_global_identity_organizations_on_global_id"
    t.index ["global_id"], name: "index_global_identity_organizations_on_global_id"
    t.index ["organization_id"], name: "index_global_identity_organizations_on_organization_id"
    t.index ["organization_id"], name: "index_global_identity_organizations_on_organization_id"
  end

  create_table "global_identity_organizations", id: :integer, default: nil, force: :cascade do |t|
    t.string "global_id"
    t.integer "organization_id"
    t.integer "client_id"
    t.index ["client_id"], name: "index_global_identity_organizations_on_client_id"
    t.index ["client_id"], name: "index_global_identity_organizations_on_client_id"
    t.index ["global_id"], name: "index_global_identity_organizations_on_global_id"
    t.index ["global_id"], name: "index_global_identity_organizations_on_global_id"
    t.index ["organization_id"], name: "index_global_identity_organizations_on_organization_id"
    t.index ["organization_id"], name: "index_global_identity_organizations_on_organization_id"
  end

  create_table "global_identity_tmp", id: :integer, default: nil, force: :cascade do |t|
    t.binary "ulid"
    t.string "ngo_name"
    t.integer "client_id"
  end

  create_table "global_identity_tmp", id: :integer, default: nil, force: :cascade do |t|
    t.binary "ulid"
    t.string "ngo_name"
    t.integer "client_id"
  end

  create_table "global_services", id: false, force: :cascade do |t|
    t.uuid "uuid"
    t.index ["uuid"], name: "index_global_services_on_uuid", unique: true
    t.index ["uuid"], name: "index_global_services_on_uuid", unique: true
  end

  create_table "global_services", id: false, force: :cascade do |t|
    t.uuid "uuid"
    t.index ["uuid"], name: "index_global_services_on_uuid", unique: true
    t.index ["uuid"], name: "index_global_services_on_uuid", unique: true
  end

  create_table "government_form_children_plans", id: :serial, force: :cascade do |t|
    t.text "goal", default: ""
    t.text "action", default: ""
    t.text "who", default: ""
    t.integer "government_form_id"
    t.integer "children_plan_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "score"
    t.text "comment", default: ""
    t.date "completion_date"
    t.index ["children_plan_id"], name: "index_government_form_children_plans_on_children_plan_id"
    t.index ["children_plan_id"], name: "index_government_form_children_plans_on_children_plan_id"
    t.index ["government_form_id"], name: "index_government_form_children_plans_on_government_form_id"
    t.index ["government_form_id"], name: "index_government_form_children_plans_on_government_form_id"
  end

  create_table "government_form_children_plans", id: :serial, force: :cascade do |t|
    t.text "goal", default: ""
    t.text "action", default: ""
    t.text "who", default: ""
    t.integer "government_form_id"
    t.integer "children_plan_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "score"
    t.text "comment", default: ""
    t.date "completion_date"
    t.index ["children_plan_id"], name: "index_government_form_children_plans_on_children_plan_id"
    t.index ["children_plan_id"], name: "index_government_form_children_plans_on_children_plan_id"
    t.index ["government_form_id"], name: "index_government_form_children_plans_on_government_form_id"
    t.index ["government_form_id"], name: "index_government_form_children_plans_on_government_form_id"
  end

  create_table "government_form_family_plans", id: :serial, force: :cascade do |t|
    t.text "goal", default: ""
    t.text "action", default: ""
    t.text "result", default: ""
    t.integer "government_form_id"
    t.integer "family_plan_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "score"
    t.text "comment", default: ""
    t.index ["family_plan_id"], name: "index_government_form_family_plans_on_family_plan_id"
    t.index ["family_plan_id"], name: "index_government_form_family_plans_on_family_plan_id"
    t.index ["government_form_id"], name: "index_government_form_family_plans_on_government_form_id"
    t.index ["government_form_id"], name: "index_government_form_family_plans_on_government_form_id"
  end

  create_table "government_form_family_plans", id: :serial, force: :cascade do |t|
    t.text "goal", default: ""
    t.text "action", default: ""
    t.text "result", default: ""
    t.integer "government_form_id"
    t.integer "family_plan_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "score"
    t.text "comment", default: ""
    t.index ["family_plan_id"], name: "index_government_form_family_plans_on_family_plan_id"
    t.index ["family_plan_id"], name: "index_government_form_family_plans_on_family_plan_id"
    t.index ["government_form_id"], name: "index_government_form_family_plans_on_government_form_id"
    t.index ["government_form_id"], name: "index_government_form_family_plans_on_government_form_id"
  end

  create_table "government_form_interviewees", id: :serial, force: :cascade do |t|
    t.integer "government_form_id"
    t.integer "interviewee_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["government_form_id"], name: "index_government_form_interviewees_on_government_form_id"
    t.index ["government_form_id"], name: "index_government_form_interviewees_on_government_form_id"
    t.index ["interviewee_id"], name: "index_government_form_interviewees_on_interviewee_id"
    t.index ["interviewee_id"], name: "index_government_form_interviewees_on_interviewee_id"
  end

  create_table "government_form_interviewees", id: :serial, force: :cascade do |t|
    t.integer "government_form_id"
    t.integer "interviewee_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["government_form_id"], name: "index_government_form_interviewees_on_government_form_id"
    t.index ["government_form_id"], name: "index_government_form_interviewees_on_government_form_id"
    t.index ["interviewee_id"], name: "index_government_form_interviewees_on_interviewee_id"
    t.index ["interviewee_id"], name: "index_government_form_interviewees_on_interviewee_id"
  end

  create_table "government_form_needs", id: :serial, force: :cascade do |t|
    t.integer "rank"
    t.integer "need_id"
    t.integer "government_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["government_form_id"], name: "index_government_form_needs_on_government_form_id"
    t.index ["government_form_id"], name: "index_government_form_needs_on_government_form_id"
    t.index ["need_id"], name: "index_government_form_needs_on_need_id"
    t.index ["need_id"], name: "index_government_form_needs_on_need_id"
  end

  create_table "government_form_needs", id: :serial, force: :cascade do |t|
    t.integer "rank"
    t.integer "need_id"
    t.integer "government_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["government_form_id"], name: "index_government_form_needs_on_government_form_id"
    t.index ["government_form_id"], name: "index_government_form_needs_on_government_form_id"
    t.index ["need_id"], name: "index_government_form_needs_on_need_id"
    t.index ["need_id"], name: "index_government_form_needs_on_need_id"
  end

  create_table "government_form_problems", id: :serial, force: :cascade do |t|
    t.integer "rank"
    t.integer "problem_id"
    t.integer "government_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["government_form_id"], name: "index_government_form_problems_on_government_form_id"
    t.index ["government_form_id"], name: "index_government_form_problems_on_government_form_id"
    t.index ["problem_id"], name: "index_government_form_problems_on_problem_id"
    t.index ["problem_id"], name: "index_government_form_problems_on_problem_id"
  end

  create_table "government_form_problems", id: :serial, force: :cascade do |t|
    t.integer "rank"
    t.integer "problem_id"
    t.integer "government_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["government_form_id"], name: "index_government_form_problems_on_government_form_id"
    t.index ["government_form_id"], name: "index_government_form_problems_on_government_form_id"
    t.index ["problem_id"], name: "index_government_form_problems_on_problem_id"
    t.index ["problem_id"], name: "index_government_form_problems_on_problem_id"
  end

  create_table "government_form_service_types", id: :serial, force: :cascade do |t|
    t.integer "government_form_id"
    t.integer "service_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["government_form_id"], name: "index_government_form_service_types_on_government_form_id"
    t.index ["government_form_id"], name: "index_government_form_service_types_on_government_form_id"
    t.index ["service_type_id"], name: "index_government_form_service_types_on_service_type_id"
    t.index ["service_type_id"], name: "index_government_form_service_types_on_service_type_id"
  end

  create_table "government_form_service_types", id: :serial, force: :cascade do |t|
    t.integer "government_form_id"
    t.integer "service_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["government_form_id"], name: "index_government_form_service_types_on_government_form_id"
    t.index ["government_form_id"], name: "index_government_form_service_types_on_government_form_id"
    t.index ["service_type_id"], name: "index_government_form_service_types_on_service_type_id"
    t.index ["service_type_id"], name: "index_government_form_service_types_on_service_type_id"
  end

  create_table "government_forms", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.date "date"
    t.string "client_code", default: ""
    t.integer "interview_district_id"
    t.integer "interview_province_id"
    t.integer "case_worker_id"
    t.string "case_worker_phone", default: ""
    t.integer "client_id"
    t.string "primary_carer_relationship", default: ""
    t.string "primary_carer_house", default: ""
    t.string "primary_carer_street", default: ""
    t.integer "primary_carer_district_id"
    t.integer "primary_carer_province_id"
    t.text "source_info", default: ""
    t.text "summary_info_of_referral", default: ""
    t.text "guardian_comment", default: ""
    t.text "case_worker_comment", default: ""
    t.string "other_interviewee", default: ""
    t.string "other_client_type", default: ""
    t.string "other_need", default: ""
    t.string "other_problem", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "province_id"
    t.integer "district_id"
    t.integer "commune_id"
    t.integer "village_id"
    t.string "caseworker_assumption", default: ""
    t.text "assumption_description", default: ""
    t.date "assumption_date"
    t.string "contact_type", default: ""
    t.string "client_decision", default: ""
    t.string "other_service_type", default: ""
    t.date "gov_placement_date"
    t.string "care_type", default: ""
    t.string "primary_carer", default: ""
    t.string "secondary_carer", default: ""
    t.string "carer_contact_info", default: ""
    t.integer "assessment_province_id"
    t.integer "assessment_district_id"
    t.string "new_carer", default: ""
    t.string "new_carer_gender", default: ""
    t.date "new_carer_date_of_birth"
    t.string "new_carer_relationship", default: ""
    t.integer "interview_commune_id"
    t.integer "interview_village_id"
    t.integer "assessment_commune_id"
    t.integer "primary_carer_commune_id"
    t.integer "primary_carer_village_id"
    t.text "recent_issues_and_progress", default: ""
    t.string "other_case_closure"
    t.text "brief_case_history"
    t.integer "case_closure_id"
    t.index ["client_id"], name: "index_government_forms_on_client_id"
    t.index ["client_id"], name: "index_government_forms_on_client_id"
    t.index ["commune_id"], name: "index_government_forms_on_commune_id"
    t.index ["commune_id"], name: "index_government_forms_on_commune_id"
    t.index ["district_id"], name: "index_government_forms_on_district_id"
    t.index ["district_id"], name: "index_government_forms_on_district_id"
    t.index ["province_id"], name: "index_government_forms_on_province_id"
    t.index ["province_id"], name: "index_government_forms_on_province_id"
    t.index ["village_id"], name: "index_government_forms_on_village_id"
    t.index ["village_id"], name: "index_government_forms_on_village_id"
  end

  create_table "government_forms", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.date "date"
    t.string "client_code", default: ""
    t.integer "interview_district_id"
    t.integer "interview_province_id"
    t.integer "case_worker_id"
    t.string "case_worker_phone", default: ""
    t.integer "client_id"
    t.string "primary_carer_relationship", default: ""
    t.string "primary_carer_house", default: ""
    t.string "primary_carer_street", default: ""
    t.integer "primary_carer_district_id"
    t.integer "primary_carer_province_id"
    t.text "source_info", default: ""
    t.text "summary_info_of_referral", default: ""
    t.text "guardian_comment", default: ""
    t.text "case_worker_comment", default: ""
    t.string "other_interviewee", default: ""
    t.string "other_client_type", default: ""
    t.string "other_need", default: ""
    t.string "other_problem", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "province_id"
    t.integer "district_id"
    t.integer "commune_id"
    t.integer "village_id"
    t.string "caseworker_assumption", default: ""
    t.text "assumption_description", default: ""
    t.date "assumption_date"
    t.string "contact_type", default: ""
    t.string "client_decision", default: ""
    t.string "other_service_type", default: ""
    t.date "gov_placement_date"
    t.string "care_type", default: ""
    t.string "primary_carer", default: ""
    t.string "secondary_carer", default: ""
    t.string "carer_contact_info", default: ""
    t.integer "assessment_province_id"
    t.integer "assessment_district_id"
    t.string "new_carer", default: ""
    t.string "new_carer_gender", default: ""
    t.date "new_carer_date_of_birth"
    t.string "new_carer_relationship", default: ""
    t.integer "interview_commune_id"
    t.integer "interview_village_id"
    t.integer "assessment_commune_id"
    t.integer "primary_carer_commune_id"
    t.integer "primary_carer_village_id"
    t.text "recent_issues_and_progress", default: ""
    t.string "other_case_closure"
    t.text "brief_case_history"
    t.integer "case_closure_id"
    t.index ["client_id"], name: "index_government_forms_on_client_id"
    t.index ["client_id"], name: "index_government_forms_on_client_id"
    t.index ["commune_id"], name: "index_government_forms_on_commune_id"
    t.index ["commune_id"], name: "index_government_forms_on_commune_id"
    t.index ["district_id"], name: "index_government_forms_on_district_id"
    t.index ["district_id"], name: "index_government_forms_on_district_id"
    t.index ["province_id"], name: "index_government_forms_on_province_id"
    t.index ["province_id"], name: "index_government_forms_on_province_id"
    t.index ["village_id"], name: "index_government_forms_on_village_id"
    t.index ["village_id"], name: "index_government_forms_on_village_id"
  end

  create_table "government_reports", id: :serial, force: :cascade do |t|
    t.string "code", default: ""
    t.string "initial_capital", default: ""
    t.string "initial_city", default: ""
    t.string "initial_commune", default: ""
    t.date "initial_date"
    t.string "client_code", default: ""
    t.string "commune", default: ""
    t.string "city", default: ""
    t.string "capital", default: ""
    t.string "organisation_name", default: ""
    t.string "organisation_phone_number", default: ""
    t.string "client_name", default: ""
    t.date "client_date_of_birth"
    t.string "client_gender", default: ""
    t.string "found_client_at", default: ""
    t.string "found_client_village", default: ""
    t.string "education", default: ""
    t.string "carer_name", default: ""
    t.string "client_contact", default: ""
    t.string "carer_house_number", default: ""
    t.string "carer_street_number", default: ""
    t.string "carer_village", default: ""
    t.string "carer_commune", default: ""
    t.string "carer_city", default: ""
    t.string "carer_capital", default: ""
    t.string "carer_phone_number", default: ""
    t.date "case_information_date"
    t.string "referral_name", default: ""
    t.string "referral_position", default: ""
    t.boolean "anonymous", default: false
    t.text "anonymous_description", default: ""
    t.boolean "client_living_with_guardian", default: false
    t.text "present_physical_health", default: ""
    t.text "physical_health_need", default: ""
    t.text "physical_health_plan", default: ""
    t.text "present_supplies", default: ""
    t.text "supplies_need", default: ""
    t.text "supplies_plan", default: ""
    t.text "present_education", default: ""
    t.text "education_need", default: ""
    t.text "education_plan", default: ""
    t.text "present_family_communication", default: ""
    t.text "family_communication_need", default: ""
    t.text "family_communication_plan", default: ""
    t.text "present_society_communication", default: ""
    t.text "society_communication_need", default: ""
    t.text "society_communication_plan", default: ""
    t.text "present_emotional_health", default: ""
    t.text "emotional_health_need", default: ""
    t.text "emotional_health_plan", default: ""
    t.boolean "mission_obtainable", default: false
    t.boolean "first_mission", default: false
    t.boolean "second_mission", default: false
    t.boolean "third_mission", default: false
    t.boolean "fourth_mission", default: false
    t.date "done_date"
    t.date "agreed_date"
    t.integer "client_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "government_reports", id: :serial, force: :cascade do |t|
    t.string "code", default: ""
    t.string "initial_capital", default: ""
    t.string "initial_city", default: ""
    t.string "initial_commune", default: ""
    t.date "initial_date"
    t.string "client_code", default: ""
    t.string "commune", default: ""
    t.string "city", default: ""
    t.string "capital", default: ""
    t.string "organisation_name", default: ""
    t.string "organisation_phone_number", default: ""
    t.string "client_name", default: ""
    t.date "client_date_of_birth"
    t.string "client_gender", default: ""
    t.string "found_client_at", default: ""
    t.string "found_client_village", default: ""
    t.string "education", default: ""
    t.string "carer_name", default: ""
    t.string "client_contact", default: ""
    t.string "carer_house_number", default: ""
    t.string "carer_street_number", default: ""
    t.string "carer_village", default: ""
    t.string "carer_commune", default: ""
    t.string "carer_city", default: ""
    t.string "carer_capital", default: ""
    t.string "carer_phone_number", default: ""
    t.date "case_information_date"
    t.string "referral_name", default: ""
    t.string "referral_position", default: ""
    t.boolean "anonymous", default: false
    t.text "anonymous_description", default: ""
    t.boolean "client_living_with_guardian", default: false
    t.text "present_physical_health", default: ""
    t.text "physical_health_need", default: ""
    t.text "physical_health_plan", default: ""
    t.text "present_supplies", default: ""
    t.text "supplies_need", default: ""
    t.text "supplies_plan", default: ""
    t.text "present_education", default: ""
    t.text "education_need", default: ""
    t.text "education_plan", default: ""
    t.text "present_family_communication", default: ""
    t.text "family_communication_need", default: ""
    t.text "family_communication_plan", default: ""
    t.text "present_society_communication", default: ""
    t.text "society_communication_need", default: ""
    t.text "society_communication_plan", default: ""
    t.text "present_emotional_health", default: ""
    t.text "emotional_health_need", default: ""
    t.text "emotional_health_plan", default: ""
    t.boolean "mission_obtainable", default: false
    t.boolean "first_mission", default: false
    t.boolean "second_mission", default: false
    t.boolean "third_mission", default: false
    t.boolean "fourth_mission", default: false
    t.date "done_date"
    t.date "agreed_date"
    t.integer "client_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "hotlines", id: :serial, force: :cascade do |t|
    t.integer "client_id"
    t.integer "call_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["call_id"], name: "index_hotlines_on_call_id"
    t.index ["call_id"], name: "index_hotlines_on_call_id"
    t.index ["client_id"], name: "index_hotlines_on_client_id"
    t.index ["client_id"], name: "index_hotlines_on_client_id"
  end

  create_table "hotlines", id: :serial, force: :cascade do |t|
    t.integer "client_id"
    t.integer "call_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["call_id"], name: "index_hotlines_on_call_id"
    t.index ["call_id"], name: "index_hotlines_on_call_id"
    t.index ["client_id"], name: "index_hotlines_on_client_id"
    t.index ["client_id"], name: "index_hotlines_on_client_id"
  end

  create_table "interventions", id: :serial, force: :cascade do |t|
    t.string "action", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "interventions", id: :serial, force: :cascade do |t|
    t.string "action", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "interviewees", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "interviewees", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "leave_programs", id: :serial, force: :cascade do |t|
    t.jsonb "properties", default: {}
    t.integer "client_enrollment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "program_stream_id"
    t.date "exit_date"
    t.datetime "deleted_at"
    t.integer "enrollment_id"
    t.index ["client_enrollment_id"], name: "index_leave_programs_on_client_enrollment_id"
    t.index ["client_enrollment_id"], name: "index_leave_programs_on_client_enrollment_id"
    t.index ["deleted_at"], name: "index_leave_programs_on_deleted_at"
    t.index ["deleted_at"], name: "index_leave_programs_on_deleted_at"
    t.index ["enrollment_id"], name: "index_leave_programs_on_enrollment_id"
    t.index ["enrollment_id"], name: "index_leave_programs_on_enrollment_id"
  end

  create_table "leave_programs", id: :serial, force: :cascade do |t|
    t.jsonb "properties", default: {}
    t.integer "client_enrollment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "program_stream_id"
    t.date "exit_date"
    t.datetime "deleted_at"
    t.integer "enrollment_id"
    t.index ["client_enrollment_id"], name: "index_leave_programs_on_client_enrollment_id"
    t.index ["client_enrollment_id"], name: "index_leave_programs_on_client_enrollment_id"
    t.index ["deleted_at"], name: "index_leave_programs_on_deleted_at"
    t.index ["deleted_at"], name: "index_leave_programs_on_deleted_at"
    t.index ["enrollment_id"], name: "index_leave_programs_on_enrollment_id"
    t.index ["enrollment_id"], name: "index_leave_programs_on_enrollment_id"
  end

  create_table "locations", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "order_option", default: 0
  end

  create_table "locations", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "order_option", default: 0
  end

  create_table "materials", id: :serial, force: :cascade do |t|
    t.string "status", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "materials", id: :serial, force: :cascade do |t|
    t.string "status", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "meta_fields", id: :serial, force: :cascade do |t|
    t.string "field_name"
    t.string "field_type"
    t.boolean "hidden", default: true
    t.boolean "required", default: false
    t.string "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "necessities", id: :serial, force: :cascade do |t|
    t.string "content", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "necessities", id: :serial, force: :cascade do |t|
    t.string "content", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "needs", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "needs", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "oauth_access_grants", id: :integer, default: nil, force: :cascade do |t|
    t.integer "resource_owner_id", null: false
    t.integer "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_grants", id: :integer, default: nil, force: :cascade do |t|
    t.integer "resource_owner_id", null: false
    t.integer "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", id: :integer, default: nil, force: :cascade do |t|
    t.integer "resource_owner_id"
    t.integer "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_access_tokens", id: :integer, default: nil, force: :cascade do |t|
    t.integer "resource_owner_id"
    t.integer "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", id: :integer, default: nil, force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "oauth_applications", id: :integer, default: nil, force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "organization_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "organization_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "organizations", id: :serial, force: :cascade do |t|
    t.string "full_name"
    t.string "short_name"
    t.string "logo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "fcf_ngo", default: false
    t.string "country", default: ""
    t.boolean "aht", default: false
    t.boolean "integrated", default: false
    t.string "supported_languages", default: ["km", "en", "my"], array: true
    t.integer "clients_count", default: 0
    t.integer "active_client", default: 0
    t.integer "accepted_client", default: 0
    t.boolean "demo", default: false
    t.string "referral_source_category_name"
  end

  create_table "organizations", id: :serial, force: :cascade do |t|
    t.string "full_name"
    t.string "short_name"
    t.string "logo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "fcf_ngo", default: false
    t.string "country", default: ""
    t.boolean "aht", default: false
    t.boolean "integrated", default: false
    t.string "supported_languages", default: ["km", "en", "my"], array: true
    t.integer "clients_count", default: 0
    t.integer "active_client", default: 0
    t.integer "accepted_client", default: 0
    t.boolean "demo", default: false
    t.string "referral_source_category_name"
  end

  create_table "partners", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.string "address", default: ""
    t.date "start_date"
    t.string "contact_person_name", default: ""
    t.string "contact_person_email", default: ""
    t.string "contact_person_mobile", default: ""
    t.string "archive_organization_type", default: ""
    t.string "affiliation", default: ""
    t.string "engagement", default: ""
    t.text "background", default: ""
    t.integer "province_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "cases_count", default: 0
    t.integer "organization_type_id"
    t.index ["organization_type_id"], name: "index_partners_on_organization_type_id"
    t.index ["organization_type_id"], name: "index_partners_on_organization_type_id"
  end

  create_table "partners", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.string "address", default: ""
    t.date "start_date"
    t.string "contact_person_name", default: ""
    t.string "contact_person_email", default: ""
    t.string "contact_person_mobile", default: ""
    t.string "archive_organization_type", default: ""
    t.string "affiliation", default: ""
    t.string "engagement", default: ""
    t.text "background", default: ""
    t.integer "province_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "cases_count", default: 0
    t.integer "organization_type_id"
    t.index ["organization_type_id"], name: "index_partners_on_organization_type_id"
    t.index ["organization_type_id"], name: "index_partners_on_organization_type_id"
  end

  create_table "permissions", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.boolean "case_notes_readable", default: true
    t.boolean "case_notes_editable", default: true
    t.boolean "assessments_editable", default: true
    t.boolean "assessments_readable", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_permissions_on_user_id"
    t.index ["user_id"], name: "index_permissions_on_user_id"
  end

  create_table "permissions", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.boolean "case_notes_readable", default: true
    t.boolean "case_notes_editable", default: true
    t.boolean "assessments_editable", default: true
    t.boolean "assessments_readable", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_permissions_on_user_id"
    t.index ["user_id"], name: "index_permissions_on_user_id"
  end

  create_table "problems", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "problems", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "program_stream_permissions", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "program_stream_id"
    t.boolean "readable", default: true
    t.boolean "editable", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_program_stream_permissions_on_deleted_at"
    t.index ["deleted_at"], name: "index_program_stream_permissions_on_deleted_at"
    t.index ["program_stream_id"], name: "index_program_stream_permissions_on_program_stream_id"
    t.index ["program_stream_id"], name: "index_program_stream_permissions_on_program_stream_id"
    t.index ["user_id"], name: "index_program_stream_permissions_on_user_id"
    t.index ["user_id"], name: "index_program_stream_permissions_on_user_id"
  end

  create_table "program_stream_permissions", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "program_stream_id"
    t.boolean "readable", default: true
    t.boolean "editable", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_program_stream_permissions_on_deleted_at"
    t.index ["deleted_at"], name: "index_program_stream_permissions_on_deleted_at"
    t.index ["program_stream_id"], name: "index_program_stream_permissions_on_program_stream_id"
    t.index ["program_stream_id"], name: "index_program_stream_permissions_on_program_stream_id"
    t.index ["user_id"], name: "index_program_stream_permissions_on_user_id"
    t.index ["user_id"], name: "index_program_stream_permissions_on_user_id"
  end

  create_table "program_stream_services", id: :serial, force: :cascade do |t|
    t.datetime "deleted_at"
    t.integer "program_stream_id"
    t.integer "service_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_program_stream_services_on_deleted_at"
    t.index ["deleted_at"], name: "index_program_stream_services_on_deleted_at"
    t.index ["program_stream_id"], name: "index_program_stream_services_on_program_stream_id"
    t.index ["program_stream_id"], name: "index_program_stream_services_on_program_stream_id"
    t.index ["service_id"], name: "index_program_stream_services_on_service_id"
    t.index ["service_id"], name: "index_program_stream_services_on_service_id"
  end

  create_table "program_stream_services", id: :serial, force: :cascade do |t|
    t.datetime "deleted_at"
    t.integer "program_stream_id"
    t.integer "service_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_program_stream_services_on_deleted_at"
    t.index ["deleted_at"], name: "index_program_stream_services_on_deleted_at"
    t.index ["program_stream_id"], name: "index_program_stream_services_on_program_stream_id"
    t.index ["program_stream_id"], name: "index_program_stream_services_on_program_stream_id"
    t.index ["service_id"], name: "index_program_stream_services_on_service_id"
    t.index ["service_id"], name: "index_program_stream_services_on_service_id"
  end

  create_table "program_streams", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.jsonb "rules", default: {}
    t.jsonb "enrollment", default: {}
    t.jsonb "exit_program", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "quantity"
    t.string "ngo_name", default: ""
    t.boolean "completed", default: false
    t.integer "program_exclusive", default: [], array: true
    t.integer "mutual_dependence", default: [], array: true
    t.boolean "tracking_required", default: false
    t.datetime "archived_at"
    t.index ["archived_at"], name: "index_program_streams_on_archived_at"
    t.index ["archived_at"], name: "index_program_streams_on_archived_at"
  end

  create_table "program_streams", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.jsonb "rules", default: {}
    t.jsonb "enrollment", default: {}
    t.jsonb "exit_program", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "quantity"
    t.string "ngo_name", default: ""
    t.boolean "completed", default: false
    t.integer "program_exclusive", default: [], array: true
    t.integer "mutual_dependence", default: [], array: true
    t.boolean "tracking_required", default: false
    t.datetime "archived_at"
    t.index ["archived_at"], name: "index_program_streams_on_archived_at"
    t.index ["archived_at"], name: "index_program_streams_on_archived_at"
  end

  create_table "progress_note_types", id: :serial, force: :cascade do |t|
    t.string "note_type", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "progress_note_types", id: :serial, force: :cascade do |t|
    t.string "note_type", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "progress_notes", id: :serial, force: :cascade do |t|
    t.date "date"
    t.string "other_location", default: ""
    t.text "response", default: ""
    t.text "additional_note", default: ""
    t.integer "client_id"
    t.integer "progress_note_type_id"
    t.integer "location_id"
    t.integer "material_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.index ["client_id"], name: "index_progress_notes_on_client_id"
    t.index ["client_id"], name: "index_progress_notes_on_client_id"
    t.index ["location_id"], name: "index_progress_notes_on_location_id"
    t.index ["location_id"], name: "index_progress_notes_on_location_id"
    t.index ["material_id"], name: "index_progress_notes_on_material_id"
    t.index ["material_id"], name: "index_progress_notes_on_material_id"
    t.index ["progress_note_type_id"], name: "index_progress_notes_on_progress_note_type_id"
    t.index ["progress_note_type_id"], name: "index_progress_notes_on_progress_note_type_id"
    t.index ["user_id"], name: "index_progress_notes_on_user_id"
    t.index ["user_id"], name: "index_progress_notes_on_user_id"
  end

  create_table "progress_notes", id: :serial, force: :cascade do |t|
    t.date "date"
    t.string "other_location", default: ""
    t.text "response", default: ""
    t.text "additional_note", default: ""
    t.integer "client_id"
    t.integer "progress_note_type_id"
    t.integer "location_id"
    t.integer "material_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.index ["client_id"], name: "index_progress_notes_on_client_id"
    t.index ["client_id"], name: "index_progress_notes_on_client_id"
    t.index ["location_id"], name: "index_progress_notes_on_location_id"
    t.index ["location_id"], name: "index_progress_notes_on_location_id"
    t.index ["material_id"], name: "index_progress_notes_on_material_id"
    t.index ["material_id"], name: "index_progress_notes_on_material_id"
    t.index ["progress_note_type_id"], name: "index_progress_notes_on_progress_note_type_id"
    t.index ["progress_note_type_id"], name: "index_progress_notes_on_progress_note_type_id"
    t.index ["user_id"], name: "index_progress_notes_on_user_id"
    t.index ["user_id"], name: "index_progress_notes_on_user_id"
  end

  create_table "protection_concerns", id: :serial, force: :cascade do |t|
    t.string "content", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "protection_concerns", id: :serial, force: :cascade do |t|
    t.string "content", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "provinces", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.text "description", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "cases_count", default: 0
    t.integer "clients_count", default: 0
    t.integer "families_count", default: 0
    t.integer "partners_count", default: 0
    t.integer "users_count", default: 0, null: false
    t.string "country"
  end

  create_table "provinces", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.text "description", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "cases_count", default: 0
    t.integer "clients_count", default: 0
    t.integer "families_count", default: 0
    t.integer "partners_count", default: 0
    t.integer "users_count", default: 0, null: false
    t.string "country"
  end

  create_table "quantitative_cases", id: :serial, force: :cascade do |t|
    t.string "value", default: ""
    t.integer "quantitative_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "quantitative_cases", id: :serial, force: :cascade do |t|
    t.string "value", default: ""
    t.integer "quantitative_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "quantitative_type_permissions", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "quantitative_type_id"
    t.boolean "readable", default: true
    t.boolean "editable", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quantitative_type_id"], name: "index_quantitative_type_permissions_on_quantitative_type_id"
    t.index ["quantitative_type_id"], name: "index_quantitative_type_permissions_on_quantitative_type_id"
    t.index ["user_id"], name: "index_quantitative_type_permissions_on_user_id"
    t.index ["user_id"], name: "index_quantitative_type_permissions_on_user_id"
  end

  create_table "quantitative_type_permissions", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "quantitative_type_id"
    t.boolean "readable", default: true
    t.boolean "editable", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quantitative_type_id"], name: "index_quantitative_type_permissions_on_quantitative_type_id"
    t.index ["quantitative_type_id"], name: "index_quantitative_type_permissions_on_quantitative_type_id"
    t.index ["user_id"], name: "index_quantitative_type_permissions_on_user_id"
    t.index ["user_id"], name: "index_quantitative_type_permissions_on_user_id"
  end

  create_table "quantitative_types", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.text "description", default: ""
    t.integer "quantitative_cases_count", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "multiple", default: true
  end

  create_table "quantitative_types", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.text "description", default: ""
    t.integer "quantitative_cases_count", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "multiple", default: true
  end

  create_table "quarterly_reports", id: :serial, force: :cascade do |t|
    t.date "visit_date"
    t.bigint "code"
    t.integer "case_id"
    t.text "general_health_or_appearance", default: ""
    t.text "child_school_attendance_or_progress", default: ""
    t.text "general_appearance_of_home", default: ""
    t.text "observations_of_drug_alchohol_abuse", default: ""
    t.text "describe_if_yes", default: ""
    t.text "describe_the_family_current_situation", default: ""
    t.text "has_the_situation_changed_from_the_previous_visit", default: ""
    t.text "how_did_i_encourage_the_client", default: ""
    t.text "what_future_teachings_or_trainings_could_help_the_client", default: ""
    t.text "what_is_my_plan_for_the_next_visit_to_the_client", default: ""
    t.boolean "money_and_supplies_being_used_appropriately", default: false
    t.text "how_are_they_being_misused", default: ""
    t.integer "staff_id"
    t.text "spiritual_developments_with_the_child_or_family", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["case_id"], name: "index_quarterly_reports_on_case_id"
    t.index ["case_id"], name: "index_quarterly_reports_on_case_id"
  end

  create_table "quarterly_reports", id: :serial, force: :cascade do |t|
    t.date "visit_date"
    t.bigint "code"
    t.integer "case_id"
    t.text "general_health_or_appearance", default: ""
    t.text "child_school_attendance_or_progress", default: ""
    t.text "general_appearance_of_home", default: ""
    t.text "observations_of_drug_alchohol_abuse", default: ""
    t.text "describe_if_yes", default: ""
    t.text "describe_the_family_current_situation", default: ""
    t.text "has_the_situation_changed_from_the_previous_visit", default: ""
    t.text "how_did_i_encourage_the_client", default: ""
    t.text "what_future_teachings_or_trainings_could_help_the_client", default: ""
    t.text "what_is_my_plan_for_the_next_visit_to_the_client", default: ""
    t.boolean "money_and_supplies_being_used_appropriately", default: false
    t.text "how_are_they_being_misused", default: ""
    t.integer "staff_id"
    t.text "spiritual_developments_with_the_child_or_family", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["case_id"], name: "index_quarterly_reports_on_case_id"
    t.index ["case_id"], name: "index_quarterly_reports_on_case_id"
  end

  create_table "question_groups", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "question_groups", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "referees", id: :serial, force: :cascade do |t|
    t.string "address_type", default: ""
    t.string "current_address", default: ""
    t.string "email", default: ""
    t.string "gender", default: ""
    t.string "house_number", default: ""
    t.string "outside_address", default: ""
    t.string "street_number", default: ""
    t.boolean "outside", default: false
    t.boolean "anonymous", default: false
    t.integer "province_id"
    t.integer "district_id"
    t.integer "commune_id"
    t.integer "village_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", default: ""
    t.string "phone", default: ""
    t.boolean "adult"
    t.string "suburb", default: ""
    t.string "description_house_landmark", default: ""
    t.string "directions", default: ""
    t.string "street_line1", default: ""
    t.string "street_line2", default: ""
    t.string "plot", default: ""
    t.string "road", default: ""
    t.string "postal_code", default: ""
    t.integer "state_id"
    t.integer "township_id"
    t.integer "subdistrict_id"
    t.string "locality"
    t.index ["commune_id"], name: "index_referees_on_commune_id"
    t.index ["commune_id"], name: "index_referees_on_commune_id"
    t.index ["district_id"], name: "index_referees_on_district_id"
    t.index ["district_id"], name: "index_referees_on_district_id"
    t.index ["province_id"], name: "index_referees_on_province_id"
    t.index ["province_id"], name: "index_referees_on_province_id"
    t.index ["state_id"], name: "index_referees_on_state_id"
    t.index ["state_id"], name: "index_referees_on_state_id"
    t.index ["subdistrict_id"], name: "index_referees_on_subdistrict_id"
    t.index ["subdistrict_id"], name: "index_referees_on_subdistrict_id"
    t.index ["township_id"], name: "index_referees_on_township_id"
    t.index ["township_id"], name: "index_referees_on_township_id"
    t.index ["village_id"], name: "index_referees_on_village_id"
    t.index ["village_id"], name: "index_referees_on_village_id"
  end

  create_table "referees", id: :serial, force: :cascade do |t|
    t.string "address_type", default: ""
    t.string "current_address", default: ""
    t.string "email", default: ""
    t.string "gender", default: ""
    t.string "house_number", default: ""
    t.string "outside_address", default: ""
    t.string "street_number", default: ""
    t.boolean "outside", default: false
    t.boolean "anonymous", default: false
    t.integer "province_id"
    t.integer "district_id"
    t.integer "commune_id"
    t.integer "village_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", default: ""
    t.string "phone", default: ""
    t.boolean "adult"
    t.string "suburb", default: ""
    t.string "description_house_landmark", default: ""
    t.string "directions", default: ""
    t.string "street_line1", default: ""
    t.string "street_line2", default: ""
    t.string "plot", default: ""
    t.string "road", default: ""
    t.string "postal_code", default: ""
    t.integer "state_id"
    t.integer "township_id"
    t.integer "subdistrict_id"
    t.string "locality"
    t.index ["commune_id"], name: "index_referees_on_commune_id"
    t.index ["commune_id"], name: "index_referees_on_commune_id"
    t.index ["district_id"], name: "index_referees_on_district_id"
    t.index ["district_id"], name: "index_referees_on_district_id"
    t.index ["province_id"], name: "index_referees_on_province_id"
    t.index ["province_id"], name: "index_referees_on_province_id"
    t.index ["state_id"], name: "index_referees_on_state_id"
    t.index ["state_id"], name: "index_referees_on_state_id"
    t.index ["subdistrict_id"], name: "index_referees_on_subdistrict_id"
    t.index ["subdistrict_id"], name: "index_referees_on_subdistrict_id"
    t.index ["township_id"], name: "index_referees_on_township_id"
    t.index ["township_id"], name: "index_referees_on_township_id"
    t.index ["village_id"], name: "index_referees_on_village_id"
    t.index ["village_id"], name: "index_referees_on_village_id"
  end

  create_table "referral_sources", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.text "description", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "clients_count", default: 0
    t.string "name_en", default: ""
    t.string "ancestry"
    t.index ["ancestry"], name: "index_referral_sources_on_ancestry"
    t.index ["ancestry"], name: "index_referral_sources_on_ancestry"
  end

  create_table "referral_sources", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.text "description", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "clients_count", default: 0
    t.string "name_en", default: ""
    t.string "ancestry"
    t.index ["ancestry"], name: "index_referral_sources_on_ancestry"
    t.index ["ancestry"], name: "index_referral_sources_on_ancestry"
  end

  create_table "referrals", id: :serial, force: :cascade do |t|
    t.string "slug", default: ""
    t.date "date_of_referral"
    t.string "referred_to", default: ""
    t.string "referred_from", default: ""
    t.text "referral_reason", default: ""
    t.string "name_of_referee", default: ""
    t.string "referral_phone", default: ""
    t.integer "referee_id"
    t.string "client_name", default: ""
    t.string "consent_form", default: [], array: true
    t.boolean "saved", default: false
    t.integer "client_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ngo_name", default: ""
    t.string "client_global_id"
    t.string "external_id"
    t.string "external_id_display"
    t.string "mosvy_number"
    t.string "external_case_worker_name"
    t.string "external_case_worker_id"
    t.string "client_gender", default: ""
    t.date "client_date_of_birth"
    t.string "village_code", default: ""
    t.string "referee_email"
    t.index ["client_global_id"], name: "index_referrals_on_client_global_id"
    t.index ["client_global_id"], name: "index_referrals_on_client_global_id"
    t.index ["client_id"], name: "index_referrals_on_client_id"
    t.index ["client_id"], name: "index_referrals_on_client_id"
    t.index ["external_id"], name: "index_referrals_on_external_id"
    t.index ["external_id"], name: "index_referrals_on_external_id"
    t.index ["mosvy_number"], name: "index_referrals_on_mosvy_number"
    t.index ["mosvy_number"], name: "index_referrals_on_mosvy_number"
  end

  create_table "referrals", id: :serial, force: :cascade do |t|
    t.string "slug", default: ""
    t.date "date_of_referral"
    t.string "referred_to", default: ""
    t.string "referred_from", default: ""
    t.text "referral_reason", default: ""
    t.string "name_of_referee", default: ""
    t.string "referral_phone", default: ""
    t.integer "referee_id"
    t.string "client_name", default: ""
    t.string "consent_form", default: [], array: true
    t.boolean "saved", default: false
    t.integer "client_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ngo_name", default: ""
    t.string "client_global_id"
    t.string "external_id"
    t.string "external_id_display"
    t.string "mosvy_number"
    t.string "external_case_worker_name"
    t.string "external_case_worker_id"
    t.string "client_gender", default: ""
    t.date "client_date_of_birth"
    t.string "village_code", default: ""
    t.string "referee_email"
    t.index ["client_global_id"], name: "index_referrals_on_client_global_id"
    t.index ["client_global_id"], name: "index_referrals_on_client_global_id"
    t.index ["client_id"], name: "index_referrals_on_client_id"
    t.index ["client_id"], name: "index_referrals_on_client_id"
    t.index ["external_id"], name: "index_referrals_on_external_id"
    t.index ["external_id"], name: "index_referrals_on_external_id"
    t.index ["mosvy_number"], name: "index_referrals_on_mosvy_number"
    t.index ["mosvy_number"], name: "index_referrals_on_mosvy_number"
  end

  create_table "referrals_services", id: false, force: :cascade do |t|
    t.integer "referral_id"
    t.integer "service_id"
  end

  create_table "referrals_services", id: false, force: :cascade do |t|
    t.integer "referral_id"
    t.integer "service_id"
  end

  create_table "service_types", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "service_types", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "services", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "parent_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "uuid"
    t.index ["deleted_at"], name: "index_services_on_deleted_at"
    t.index ["deleted_at"], name: "index_services_on_deleted_at"
    t.index ["name"], name: "index_services_on_name"
    t.index ["name"], name: "index_services_on_name"
    t.index ["parent_id"], name: "index_services_on_parent_id"
    t.index ["parent_id"], name: "index_services_on_parent_id"
    t.index ["uuid"], name: "index_services_on_uuid"
    t.index ["uuid"], name: "index_services_on_uuid"
  end

  create_table "services", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "parent_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "uuid"
    t.index ["deleted_at"], name: "index_services_on_deleted_at"
    t.index ["deleted_at"], name: "index_services_on_deleted_at"
    t.index ["name"], name: "index_services_on_name"
    t.index ["name"], name: "index_services_on_name"
    t.index ["parent_id"], name: "index_services_on_parent_id"
    t.index ["parent_id"], name: "index_services_on_parent_id"
    t.index ["uuid"], name: "index_services_on_uuid"
    t.index ["uuid"], name: "index_services_on_uuid"
  end

  create_table "settings", id: :serial, force: :cascade do |t|
    t.string "assessment_frequency", default: "month"
    t.integer "min_assessment"
    t.integer "max_assessment", default: 6
    t.string "country_name", default: ""
    t.integer "max_case_note"
    t.string "case_note_frequency"
    t.string "client_default_columns", default: [], array: true
    t.string "family_default_columns", default: [], array: true
    t.string "partner_default_columns", default: [], array: true
    t.string "user_default_columns", default: [], array: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "org_name", default: ""
    t.string "old_commune", default: ""
    t.integer "province_id"
    t.integer "district_id"
    t.integer "age", default: 18
    t.integer "commune_id"
    t.string "custom_assessment", default: "Custom Assessment"
    t.boolean "enable_custom_assessment", default: false
    t.boolean "enable_default_assessment", default: true
    t.integer "max_custom_assessment", default: 6
    t.string "custom_assessment_frequency", default: "month"
    t.integer "custom_age", default: 18
    t.string "default_assessment", default: "CSI Assessment"
    t.boolean "sharing_data", default: false
    t.string "custom_id1_latin", default: ""
    t.string "custom_id1_local", default: ""
    t.string "custom_id2_latin", default: ""
    t.string "custom_id2_local", default: ""
    t.boolean "enable_hotline", default: false
    t.boolean "enable_client_form", default: true
    t.string "assessment_score_order", default: "random_order", null: false
    t.boolean "disable_required_fields", default: false, null: false
    t.boolean "never_delete_incomplete_assessment", default: false, null: false
    t.integer "delete_incomplete_after_period_value", default: 7
    t.string "delete_incomplete_after_period_unit", default: "days"
    t.boolean "use_screening_assessment", default: false
    t.integer "screening_assessment_form_id"
    t.boolean "show_prev_assessment", default: false
    t.boolean "two_weeks_assessment_reminder", default: false
    t.index ["commune_id"], name: "index_settings_on_commune_id"
    t.index ["commune_id"], name: "index_settings_on_commune_id"
    t.index ["district_id"], name: "index_settings_on_district_id"
    t.index ["district_id"], name: "index_settings_on_district_id"
    t.index ["province_id"], name: "index_settings_on_province_id"
    t.index ["province_id"], name: "index_settings_on_province_id"
  end

  create_table "settings", id: :serial, force: :cascade do |t|
    t.string "assessment_frequency", default: "month"
    t.integer "min_assessment"
    t.integer "max_assessment", default: 6
    t.string "country_name", default: ""
    t.integer "max_case_note"
    t.string "case_note_frequency"
    t.string "client_default_columns", default: [], array: true
    t.string "family_default_columns", default: [], array: true
    t.string "partner_default_columns", default: [], array: true
    t.string "user_default_columns", default: [], array: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "org_name", default: ""
    t.string "old_commune", default: ""
    t.integer "province_id"
    t.integer "district_id"
    t.integer "age", default: 18
    t.integer "commune_id"
    t.string "custom_assessment", default: "Custom Assessment"
    t.boolean "enable_custom_assessment", default: false
    t.boolean "enable_default_assessment", default: true
    t.integer "max_custom_assessment", default: 6
    t.string "custom_assessment_frequency", default: "month"
    t.integer "custom_age", default: 18
    t.string "default_assessment", default: "CSI Assessment"
    t.boolean "sharing_data", default: false
    t.string "custom_id1_latin", default: ""
    t.string "custom_id1_local", default: ""
    t.string "custom_id2_latin", default: ""
    t.string "custom_id2_local", default: ""
    t.boolean "enable_hotline", default: false
    t.boolean "enable_client_form", default: true
    t.string "assessment_score_order", default: "random_order", null: false
    t.boolean "disable_required_fields", default: false, null: false
    t.boolean "never_delete_incomplete_assessment", default: false, null: false
    t.integer "delete_incomplete_after_period_value", default: 7
    t.string "delete_incomplete_after_period_unit", default: "days"
    t.boolean "use_screening_assessment", default: false
    t.integer "screening_assessment_form_id"
    t.boolean "show_prev_assessment", default: false
    t.boolean "two_weeks_assessment_reminder", default: false
    t.index ["commune_id"], name: "index_settings_on_commune_id"
    t.index ["commune_id"], name: "index_settings_on_commune_id"
    t.index ["district_id"], name: "index_settings_on_district_id"
    t.index ["district_id"], name: "index_settings_on_district_id"
    t.index ["province_id"], name: "index_settings_on_province_id"
    t.index ["province_id"], name: "index_settings_on_province_id"
  end

  create_table "shared_clients", id: :serial, force: :cascade do |t|
    t.string "slug", default: ""
    t.string "given_name", default: ""
    t.string "family_name", default: ""
    t.string "local_given_name", default: ""
    t.string "local_family_name", default: ""
    t.string "gender", default: ""
    t.date "date_of_birth"
    t.string "live_with", default: ""
    t.string "telephone_number", default: ""
    t.integer "birth_province_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "country_origin", default: ""
    t.string "duplicate_checker"
    t.string "archived_slug"
    t.string "global_id"
    t.string "external_id"
    t.string "external_id_display"
    t.string "mosvy_number"
    t.string "external_case_worker_name"
    t.string "external_case_worker_id"
    t.index ["duplicate_checker"], name: "index_shared_clients_on_duplicate_checker"
    t.index ["duplicate_checker"], name: "index_shared_clients_on_duplicate_checker"
    t.index ["external_id"], name: "index_shared_clients_on_external_id"
    t.index ["external_id"], name: "index_shared_clients_on_external_id"
    t.index ["global_id"], name: "index_shared_clients_on_global_id"
    t.index ["global_id"], name: "index_shared_clients_on_global_id"
    t.index ["mosvy_number"], name: "index_shared_clients_on_mosvy_number"
    t.index ["mosvy_number"], name: "index_shared_clients_on_mosvy_number"
    t.index ["slug"], name: "index_shared_clients_on_slug", unique: true
    t.index ["slug"], name: "index_shared_clients_on_slug", unique: true
  end

  create_table "shared_clients", id: :serial, force: :cascade do |t|
    t.string "slug", default: ""
    t.string "given_name", default: ""
    t.string "family_name", default: ""
    t.string "local_given_name", default: ""
    t.string "local_family_name", default: ""
    t.string "gender", default: ""
    t.date "date_of_birth"
    t.string "live_with", default: ""
    t.string "telephone_number", default: ""
    t.integer "birth_province_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "country_origin", default: ""
    t.string "duplicate_checker"
    t.string "archived_slug"
    t.string "global_id"
    t.string "external_id"
    t.string "external_id_display"
    t.string "mosvy_number"
    t.string "external_case_worker_name"
    t.string "external_case_worker_id"
    t.index ["duplicate_checker"], name: "index_shared_clients_on_duplicate_checker"
    t.index ["duplicate_checker"], name: "index_shared_clients_on_duplicate_checker"
    t.index ["external_id"], name: "index_shared_clients_on_external_id"
    t.index ["external_id"], name: "index_shared_clients_on_external_id"
    t.index ["global_id"], name: "index_shared_clients_on_global_id"
    t.index ["global_id"], name: "index_shared_clients_on_global_id"
    t.index ["mosvy_number"], name: "index_shared_clients_on_mosvy_number"
    t.index ["mosvy_number"], name: "index_shared_clients_on_mosvy_number"
    t.index ["slug"], name: "index_shared_clients_on_slug", unique: true
    t.index ["slug"], name: "index_shared_clients_on_slug", unique: true
  end

  create_table "sponsors", id: :serial, force: :cascade do |t|
    t.integer "client_id"
    t.integer "donor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["client_id"], name: "index_sponsors_on_client_id"
    t.index ["client_id"], name: "index_sponsors_on_client_id"
    t.index ["donor_id"], name: "index_sponsors_on_donor_id"
    t.index ["donor_id"], name: "index_sponsors_on_donor_id"
  end

  create_table "sponsors", id: :serial, force: :cascade do |t|
    t.integer "client_id"
    t.integer "donor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["client_id"], name: "index_sponsors_on_client_id"
    t.index ["client_id"], name: "index_sponsors_on_client_id"
    t.index ["donor_id"], name: "index_sponsors_on_donor_id"
    t.index ["donor_id"], name: "index_sponsors_on_donor_id"
  end

  create_table "stages", id: :serial, force: :cascade do |t|
    t.float "from_age"
    t.float "to_age"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stages", id: :serial, force: :cascade do |t|
    t.float "from_age"
    t.float "to_age"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "states", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "states", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subdistricts", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "district_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["district_id"], name: "index_subdistricts_on_district_id"
    t.index ["district_id"], name: "index_subdistricts_on_district_id"
  end

  create_table "subdistricts", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "district_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["district_id"], name: "index_subdistricts_on_district_id"
    t.index ["district_id"], name: "index_subdistricts_on_district_id"
  end

  create_table "surveys", id: :serial, force: :cascade do |t|
    t.integer "client_id"
    t.integer "user_id"
    t.integer "listening_score"
    t.integer "problem_solving_score"
    t.integer "getting_in_touch_score"
    t.integer "trust_score"
    t.integer "difficulty_help_score"
    t.integer "support_score"
    t.integer "family_need_score"
    t.integer "care_score"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["client_id"], name: "index_surveys_on_client_id"
    t.index ["client_id"], name: "index_surveys_on_client_id"
  end

  create_table "surveys", id: :serial, force: :cascade do |t|
    t.integer "client_id"
    t.integer "user_id"
    t.integer "listening_score"
    t.integer "problem_solving_score"
    t.integer "getting_in_touch_score"
    t.integer "trust_score"
    t.integer "difficulty_help_score"
    t.integer "support_score"
    t.integer "family_need_score"
    t.integer "care_score"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["client_id"], name: "index_surveys_on_client_id"
    t.index ["client_id"], name: "index_surveys_on_client_id"
  end

  create_table "tasks", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.date "completion_date"
    t.datetime "remind_at"
    t.boolean "completed", default: false
    t.integer "user_id"
    t.integer "case_note_domain_group_id"
    t.integer "domain_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "client_id"
    t.string "relation", default: ""
    t.string "case_note_id", default: ""
    t.integer "taskable_id"
    t.string "taskable_type"
    t.datetime "deleted_at"
    t.index ["client_id"], name: "index_tasks_on_client_id"
    t.index ["client_id"], name: "index_tasks_on_client_id"
    t.index ["deleted_at"], name: "index_tasks_on_deleted_at"
    t.index ["deleted_at"], name: "index_tasks_on_deleted_at"
    t.index ["taskable_type", "taskable_id"], name: "index_tasks_on_taskable_type_and_taskable_id"
    t.index ["taskable_type", "taskable_id"], name: "index_tasks_on_taskable_type_and_taskable_id"
  end

  create_table "tasks", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.date "completion_date"
    t.datetime "remind_at"
    t.boolean "completed", default: false
    t.integer "user_id"
    t.integer "case_note_domain_group_id"
    t.integer "domain_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "client_id"
    t.string "relation", default: ""
    t.string "case_note_id", default: ""
    t.integer "taskable_id"
    t.string "taskable_type"
    t.datetime "deleted_at"
    t.index ["client_id"], name: "index_tasks_on_client_id"
    t.index ["client_id"], name: "index_tasks_on_client_id"
    t.index ["deleted_at"], name: "index_tasks_on_deleted_at"
    t.index ["deleted_at"], name: "index_tasks_on_deleted_at"
    t.index ["taskable_type", "taskable_id"], name: "index_tasks_on_taskable_type_and_taskable_id"
    t.index ["taskable_type", "taskable_id"], name: "index_tasks_on_taskable_type_and_taskable_id"
  end

  create_table "thredded_categories", id: :serial, force: :cascade do |t|
    t.integer "messageboard_id", null: false
    t.string "name", limit: 191, null: false
    t.string "description", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug", limit: 191, null: false
    t.index "lower((name)::text) text_pattern_ops", name: "thredded_categories_name_ci"
    t.index ["messageboard_id", "slug"], name: "index_thredded_categories_on_messageboard_id_and_slug", unique: true
    t.index ["messageboard_id", "slug"], name: "index_thredded_categories_on_messageboard_id_and_slug", unique: true
    t.index ["messageboard_id"], name: "index_thredded_categories_on_messageboard_id"
    t.index ["messageboard_id"], name: "index_thredded_categories_on_messageboard_id"
  end

  create_table "thredded_categories", id: :serial, force: :cascade do |t|
    t.integer "messageboard_id", null: false
    t.string "name", limit: 191, null: false
    t.string "description", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug", limit: 191, null: false
    t.index "lower((name)::text) text_pattern_ops", name: "thredded_categories_name_ci"
    t.index ["messageboard_id", "slug"], name: "index_thredded_categories_on_messageboard_id_and_slug", unique: true
    t.index ["messageboard_id", "slug"], name: "index_thredded_categories_on_messageboard_id_and_slug", unique: true
    t.index ["messageboard_id"], name: "index_thredded_categories_on_messageboard_id"
    t.index ["messageboard_id"], name: "index_thredded_categories_on_messageboard_id"
  end

  create_table "thredded_messageboard_groups", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "thredded_messageboard_groups", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "thredded_messageboards", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.string "slug", limit: 191
    t.text "description"
    t.integer "topics_count", default: 0
    t.integer "posts_count", default: 0
    t.boolean "closed", default: false, null: false
    t.integer "last_topic_id"
    t.integer "messageboard_group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["closed"], name: "index_thredded_messageboards_on_closed"
    t.index ["closed"], name: "index_thredded_messageboards_on_closed"
    t.index ["messageboard_group_id"], name: "index_thredded_messageboards_on_messageboard_group_id"
    t.index ["messageboard_group_id"], name: "index_thredded_messageboards_on_messageboard_group_id"
    t.index ["slug"], name: "index_thredded_messageboards_on_slug"
    t.index ["slug"], name: "index_thredded_messageboards_on_slug"
  end

  create_table "thredded_messageboards", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.string "slug", limit: 191
    t.text "description"
    t.integer "topics_count", default: 0
    t.integer "posts_count", default: 0
    t.boolean "closed", default: false, null: false
    t.integer "last_topic_id"
    t.integer "messageboard_group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["closed"], name: "index_thredded_messageboards_on_closed"
    t.index ["closed"], name: "index_thredded_messageboards_on_closed"
    t.index ["messageboard_group_id"], name: "index_thredded_messageboards_on_messageboard_group_id"
    t.index ["messageboard_group_id"], name: "index_thredded_messageboards_on_messageboard_group_id"
    t.index ["slug"], name: "index_thredded_messageboards_on_slug"
    t.index ["slug"], name: "index_thredded_messageboards_on_slug"
  end

  create_table "thredded_post_moderation_records", id: :serial, force: :cascade do |t|
    t.integer "post_id"
    t.integer "messageboard_id"
    t.text "post_content"
    t.integer "post_user_id"
    t.text "post_user_name"
    t.integer "moderator_id"
    t.integer "moderation_state", null: false
    t.integer "previous_moderation_state", null: false
    t.datetime "created_at", null: false
    t.index ["messageboard_id", "created_at"], name: "index_thredded_moderation_records_for_display", order: { created_at: :desc }
    t.index ["messageboard_id", "created_at"], name: "index_thredded_moderation_records_for_display", order: { created_at: :desc }
  end

  create_table "thredded_post_moderation_records", id: :serial, force: :cascade do |t|
    t.integer "post_id"
    t.integer "messageboard_id"
    t.text "post_content"
    t.integer "post_user_id"
    t.text "post_user_name"
    t.integer "moderator_id"
    t.integer "moderation_state", null: false
    t.integer "previous_moderation_state", null: false
    t.datetime "created_at", null: false
    t.index ["messageboard_id", "created_at"], name: "index_thredded_moderation_records_for_display", order: { created_at: :desc }
    t.index ["messageboard_id", "created_at"], name: "index_thredded_moderation_records_for_display", order: { created_at: :desc }
  end

  create_table "thredded_post_notifications", id: :serial, force: :cascade do |t|
    t.string "email", limit: 191, null: false
    t.integer "post_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "post_type", limit: 191
    t.index ["post_id", "post_type"], name: "index_thredded_post_notifications_on_post"
    t.index ["post_id", "post_type"], name: "index_thredded_post_notifications_on_post"
  end

  create_table "thredded_post_notifications", id: :serial, force: :cascade do |t|
    t.string "email", limit: 191, null: false
    t.integer "post_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "post_type", limit: 191
    t.index ["post_id", "post_type"], name: "index_thredded_post_notifications_on_post"
    t.index ["post_id", "post_type"], name: "index_thredded_post_notifications_on_post"
  end

  create_table "thredded_posts", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.text "content"
    t.string "ip", limit: 255
    t.string "source", limit: 255, default: "web"
    t.integer "postable_id", null: false
    t.integer "messageboard_id", null: false
    t.integer "moderation_state", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "to_tsvector('english'::regconfig, content)", name: "thredded_posts_content_fts", using: :gist
    t.index ["messageboard_id"], name: "index_thredded_posts_on_messageboard_id"
    t.index ["messageboard_id"], name: "index_thredded_posts_on_messageboard_id"
    t.index ["moderation_state", "updated_at"], name: "index_thredded_posts_for_display"
    t.index ["moderation_state", "updated_at"], name: "index_thredded_posts_for_display"
    t.index ["postable_id"], name: "index_thredded_posts_on_postable_id_and_postable_type"
    t.index ["postable_id"], name: "index_thredded_posts_on_postable_id_and_postable_type"
    t.index ["user_id"], name: "index_thredded_posts_on_user_id"
    t.index ["user_id"], name: "index_thredded_posts_on_user_id"
  end

  create_table "thredded_posts", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.text "content"
    t.string "ip", limit: 255
    t.string "source", limit: 255, default: "web"
    t.integer "postable_id", null: false
    t.integer "messageboard_id", null: false
    t.integer "moderation_state", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "to_tsvector('english'::regconfig, content)", name: "thredded_posts_content_fts", using: :gist
    t.index ["messageboard_id"], name: "index_thredded_posts_on_messageboard_id"
    t.index ["messageboard_id"], name: "index_thredded_posts_on_messageboard_id"
    t.index ["moderation_state", "updated_at"], name: "index_thredded_posts_for_display"
    t.index ["moderation_state", "updated_at"], name: "index_thredded_posts_for_display"
    t.index ["postable_id"], name: "index_thredded_posts_on_postable_id_and_postable_type"
    t.index ["postable_id"], name: "index_thredded_posts_on_postable_id_and_postable_type"
    t.index ["user_id"], name: "index_thredded_posts_on_user_id"
    t.index ["user_id"], name: "index_thredded_posts_on_user_id"
  end

  create_table "thredded_private_posts", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.text "content"
    t.integer "postable_id", null: false
    t.string "ip", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "thredded_private_posts", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.text "content"
    t.integer "postable_id", null: false
    t.string "ip", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "thredded_private_topics", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "last_user_id"
    t.string "title", limit: 255, null: false
    t.string "slug", limit: 191, null: false
    t.integer "posts_count", default: 0
    t.string "hash_id", limit: 191, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hash_id"], name: "index_thredded_private_topics_on_hash_id"
    t.index ["hash_id"], name: "index_thredded_private_topics_on_hash_id"
    t.index ["slug"], name: "index_thredded_private_topics_on_slug"
    t.index ["slug"], name: "index_thredded_private_topics_on_slug"
  end

  create_table "thredded_private_topics", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "last_user_id"
    t.string "title", limit: 255, null: false
    t.string "slug", limit: 191, null: false
    t.integer "posts_count", default: 0
    t.string "hash_id", limit: 191, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hash_id"], name: "index_thredded_private_topics_on_hash_id"
    t.index ["hash_id"], name: "index_thredded_private_topics_on_hash_id"
    t.index ["slug"], name: "index_thredded_private_topics_on_slug"
    t.index ["slug"], name: "index_thredded_private_topics_on_slug"
  end

  create_table "thredded_private_users", id: :serial, force: :cascade do |t|
    t.integer "private_topic_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["private_topic_id"], name: "index_thredded_private_users_on_private_topic_id"
    t.index ["private_topic_id"], name: "index_thredded_private_users_on_private_topic_id"
    t.index ["user_id"], name: "index_thredded_private_users_on_user_id"
    t.index ["user_id"], name: "index_thredded_private_users_on_user_id"
  end

  create_table "thredded_private_users", id: :serial, force: :cascade do |t|
    t.integer "private_topic_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["private_topic_id"], name: "index_thredded_private_users_on_private_topic_id"
    t.index ["private_topic_id"], name: "index_thredded_private_users_on_private_topic_id"
    t.index ["user_id"], name: "index_thredded_private_users_on_user_id"
    t.index ["user_id"], name: "index_thredded_private_users_on_user_id"
  end

  create_table "thredded_topic_categories", id: :serial, force: :cascade do |t|
    t.integer "topic_id", null: false
    t.integer "category_id", null: false
    t.index ["category_id"], name: "index_thredded_topic_categories_on_category_id"
    t.index ["category_id"], name: "index_thredded_topic_categories_on_category_id"
    t.index ["topic_id"], name: "index_thredded_topic_categories_on_topic_id"
    t.index ["topic_id"], name: "index_thredded_topic_categories_on_topic_id"
  end

  create_table "thredded_topic_categories", id: :serial, force: :cascade do |t|
    t.integer "topic_id", null: false
    t.integer "category_id", null: false
    t.index ["category_id"], name: "index_thredded_topic_categories_on_category_id"
    t.index ["category_id"], name: "index_thredded_topic_categories_on_category_id"
    t.index ["topic_id"], name: "index_thredded_topic_categories_on_topic_id"
    t.index ["topic_id"], name: "index_thredded_topic_categories_on_topic_id"
  end

  create_table "thredded_topics", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "last_user_id"
    t.string "title", limit: 255, null: false
    t.string "slug", limit: 191, null: false
    t.integer "messageboard_id", null: false
    t.integer "posts_count", default: 0, null: false
    t.boolean "sticky", default: false, null: false
    t.boolean "locked", default: false, null: false
    t.string "hash_id", limit: 191, null: false
    t.string "type", limit: 191
    t.integer "moderation_state", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "to_tsvector('english'::regconfig, (title)::text)", name: "thredded_topics_title_fts", using: :gist
    t.index ["hash_id"], name: "index_thredded_topics_on_hash_id"
    t.index ["hash_id"], name: "index_thredded_topics_on_hash_id"
    t.index ["messageboard_id", "slug"], name: "index_thredded_topics_on_messageboard_id_and_slug", unique: true
    t.index ["messageboard_id", "slug"], name: "index_thredded_topics_on_messageboard_id_and_slug", unique: true
    t.index ["messageboard_id"], name: "index_thredded_topics_on_messageboard_id"
    t.index ["messageboard_id"], name: "index_thredded_topics_on_messageboard_id"
    t.index ["moderation_state", "sticky", "updated_at"], name: "index_thredded_topics_for_display", order: { sticky: :desc, updated_at: :desc }
    t.index ["moderation_state", "sticky", "updated_at"], name: "index_thredded_topics_for_display", order: { sticky: :desc, updated_at: :desc }
    t.index ["user_id"], name: "index_thredded_topics_on_user_id"
    t.index ["user_id"], name: "index_thredded_topics_on_user_id"
  end

  create_table "thredded_topics", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "last_user_id"
    t.string "title", limit: 255, null: false
    t.string "slug", limit: 191, null: false
    t.integer "messageboard_id", null: false
    t.integer "posts_count", default: 0, null: false
    t.boolean "sticky", default: false, null: false
    t.boolean "locked", default: false, null: false
    t.string "hash_id", limit: 191, null: false
    t.string "type", limit: 191
    t.integer "moderation_state", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "to_tsvector('english'::regconfig, (title)::text)", name: "thredded_topics_title_fts", using: :gist
    t.index ["hash_id"], name: "index_thredded_topics_on_hash_id"
    t.index ["hash_id"], name: "index_thredded_topics_on_hash_id"
    t.index ["messageboard_id", "slug"], name: "index_thredded_topics_on_messageboard_id_and_slug", unique: true
    t.index ["messageboard_id", "slug"], name: "index_thredded_topics_on_messageboard_id_and_slug", unique: true
    t.index ["messageboard_id"], name: "index_thredded_topics_on_messageboard_id"
    t.index ["messageboard_id"], name: "index_thredded_topics_on_messageboard_id"
    t.index ["moderation_state", "sticky", "updated_at"], name: "index_thredded_topics_for_display", order: { sticky: :desc, updated_at: :desc }
    t.index ["moderation_state", "sticky", "updated_at"], name: "index_thredded_topics_for_display", order: { sticky: :desc, updated_at: :desc }
    t.index ["user_id"], name: "index_thredded_topics_on_user_id"
    t.index ["user_id"], name: "index_thredded_topics_on_user_id"
  end

  create_table "thredded_user_details", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.datetime "latest_activity_at"
    t.integer "posts_count", default: 0
    t.integer "topics_count", default: 0
    t.datetime "last_seen_at"
    t.integer "moderation_state", default: 1, null: false
    t.datetime "moderation_state_changed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["latest_activity_at"], name: "index_thredded_user_details_on_latest_activity_at"
    t.index ["latest_activity_at"], name: "index_thredded_user_details_on_latest_activity_at"
    t.index ["moderation_state", "moderation_state_changed_at"], name: "index_thredded_user_details_for_moderations", order: { moderation_state_changed_at: :desc }
    t.index ["moderation_state", "moderation_state_changed_at"], name: "index_thredded_user_details_for_moderations", order: { moderation_state_changed_at: :desc }
    t.index ["user_id"], name: "index_thredded_user_details_on_user_id"
    t.index ["user_id"], name: "index_thredded_user_details_on_user_id"
  end

  create_table "thredded_user_details", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.datetime "latest_activity_at"
    t.integer "posts_count", default: 0
    t.integer "topics_count", default: 0
    t.datetime "last_seen_at"
    t.integer "moderation_state", default: 1, null: false
    t.datetime "moderation_state_changed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["latest_activity_at"], name: "index_thredded_user_details_on_latest_activity_at"
    t.index ["latest_activity_at"], name: "index_thredded_user_details_on_latest_activity_at"
    t.index ["moderation_state", "moderation_state_changed_at"], name: "index_thredded_user_details_for_moderations", order: { moderation_state_changed_at: :desc }
    t.index ["moderation_state", "moderation_state_changed_at"], name: "index_thredded_user_details_for_moderations", order: { moderation_state_changed_at: :desc }
    t.index ["user_id"], name: "index_thredded_user_details_on_user_id"
    t.index ["user_id"], name: "index_thredded_user_details_on_user_id"
  end

  create_table "thredded_user_messageboard_preferences", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "messageboard_id", null: false
    t.boolean "notify_on_mention", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "messageboard_id"], name: "thredded_user_messageboard_preferences_user_id_messageboard_id", unique: true
    t.index ["user_id", "messageboard_id"], name: "thredded_user_messageboard_preferences_user_id_messageboard_id", unique: true
  end

  create_table "thredded_user_messageboard_preferences", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "messageboard_id", null: false
    t.boolean "notify_on_mention", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "messageboard_id"], name: "thredded_user_messageboard_preferences_user_id_messageboard_id", unique: true
    t.index ["user_id", "messageboard_id"], name: "thredded_user_messageboard_preferences_user_id_messageboard_id", unique: true
  end

  create_table "thredded_user_preferences", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.boolean "notify_on_mention", default: true, null: false
    t.boolean "notify_on_message", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_thredded_user_preferences_on_user_id"
    t.index ["user_id"], name: "index_thredded_user_preferences_on_user_id"
  end

  create_table "thredded_user_preferences", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.boolean "notify_on_mention", default: true, null: false
    t.boolean "notify_on_message", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_thredded_user_preferences_on_user_id"
    t.index ["user_id"], name: "index_thredded_user_preferences_on_user_id"
  end

  create_table "thredded_user_private_topic_read_states", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "postable_id", null: false
    t.integer "page", default: 1, null: false
    t.datetime "read_at", null: false
    t.index ["user_id", "postable_id"], name: "thredded_user_private_topic_read_states_user_postable", unique: true
    t.index ["user_id", "postable_id"], name: "thredded_user_private_topic_read_states_user_postable", unique: true
  end

  create_table "thredded_user_private_topic_read_states", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "postable_id", null: false
    t.integer "page", default: 1, null: false
    t.datetime "read_at", null: false
    t.index ["user_id", "postable_id"], name: "thredded_user_private_topic_read_states_user_postable", unique: true
    t.index ["user_id", "postable_id"], name: "thredded_user_private_topic_read_states_user_postable", unique: true
  end

  create_table "thredded_user_topic_follows", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "topic_id", null: false
    t.datetime "created_at", null: false
    t.integer "reason", limit: 2
    t.index ["user_id", "topic_id"], name: "thredded_user_topic_follows_user_topic", unique: true
    t.index ["user_id", "topic_id"], name: "thredded_user_topic_follows_user_topic", unique: true
  end

  create_table "thredded_user_topic_follows", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "topic_id", null: false
    t.datetime "created_at", null: false
    t.integer "reason", limit: 2
    t.index ["user_id", "topic_id"], name: "thredded_user_topic_follows_user_topic", unique: true
    t.index ["user_id", "topic_id"], name: "thredded_user_topic_follows_user_topic", unique: true
  end

  create_table "thredded_user_topic_read_states", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "postable_id", null: false
    t.integer "page", default: 1, null: false
    t.datetime "read_at", null: false
    t.index ["user_id", "postable_id"], name: "thredded_user_topic_read_states_user_postable", unique: true
    t.index ["user_id", "postable_id"], name: "thredded_user_topic_read_states_user_postable", unique: true
  end

  create_table "thredded_user_topic_read_states", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "postable_id", null: false
    t.integer "page", default: 1, null: false
    t.datetime "read_at", null: false
    t.index ["user_id", "postable_id"], name: "thredded_user_topic_read_states_user_postable", unique: true
    t.index ["user_id", "postable_id"], name: "thredded_user_topic_read_states_user_postable", unique: true
  end

  create_table "townships", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "state_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["state_id"], name: "index_townships_on_state_id"
    t.index ["state_id"], name: "index_townships_on_state_id"
  end

  create_table "townships", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "state_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["state_id"], name: "index_townships_on_state_id"
    t.index ["state_id"], name: "index_townships_on_state_id"
  end

  create_table "trackings", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.jsonb "fields", default: {}
    t.string "frequency", default: ""
    t.integer "time_of_frequency"
    t.integer "program_stream_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_trackings_on_deleted_at"
    t.index ["deleted_at"], name: "index_trackings_on_deleted_at"
    t.index ["name", "program_stream_id"], name: "index_trackings_on_name_and_program_stream_id", unique: true
    t.index ["name", "program_stream_id"], name: "index_trackings_on_name_and_program_stream_id", unique: true
    t.index ["program_stream_id"], name: "index_trackings_on_program_stream_id"
    t.index ["program_stream_id"], name: "index_trackings_on_program_stream_id"
  end

  create_table "trackings", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.jsonb "fields", default: {}
    t.string "frequency", default: ""
    t.integer "time_of_frequency"
    t.integer "program_stream_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_trackings_on_deleted_at"
    t.index ["deleted_at"], name: "index_trackings_on_deleted_at"
    t.index ["name", "program_stream_id"], name: "index_trackings_on_name_and_program_stream_id", unique: true
    t.index ["name", "program_stream_id"], name: "index_trackings_on_name_and_program_stream_id", unique: true
    t.index ["program_stream_id"], name: "index_trackings_on_program_stream_id"
    t.index ["program_stream_id"], name: "index_trackings_on_program_stream_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "first_name", default: ""
    t.string "last_name", default: ""
    t.string "roles", default: "case worker"
    t.date "start_date"
    t.string "job_title", default: ""
    t.string "mobile", default: ""
    t.date "date_of_birth"
    t.boolean "archived", default: false
    t.integer "province_id"
    t.integer "department_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.integer "clients_count", default: 0
    t.integer "cases_count", default: 0
    t.integer "tasks_count", default: 0
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.json "tokens"
    t.boolean "admin", default: false
    t.integer "changelogs_count", default: 0
    t.integer "organization_id"
    t.boolean "disable", default: false
    t.datetime "expires_at"
    t.boolean "task_notify", default: true
    t.integer "manager_id"
    t.boolean "calendar_integration", default: false
    t.integer "pin_number"
    t.integer "manager_ids", default: [], array: true
    t.boolean "program_warning", default: false
    t.boolean "staff_performance_notification", default: true
    t.string "pin_code", default: ""
    t.boolean "domain_warning", default: false
    t.boolean "referral_notification", default: false
    t.string "gender", default: ""
    t.boolean "enable_gov_log_in", default: false
    t.boolean "enable_research_log_in", default: false
    t.datetime "deleted_at"
    t.datetime "activated_at"
    t.datetime "deactivated_at"
    t.string "preferred_language", default: "en"
    t.string "organization_name"
    t.string "profile"
    t.index "lower((email)::text) text_pattern_ops", name: "users_email_lower", unique: true
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "first_name", default: ""
    t.string "last_name", default: ""
    t.string "roles", default: "case worker"
    t.date "start_date"
    t.string "job_title", default: ""
    t.string "mobile", default: ""
    t.date "date_of_birth"
    t.boolean "archived", default: false
    t.integer "province_id"
    t.integer "department_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.integer "clients_count", default: 0
    t.integer "cases_count", default: 0
    t.integer "tasks_count", default: 0
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.json "tokens"
    t.boolean "admin", default: false
    t.integer "changelogs_count", default: 0
    t.integer "organization_id"
    t.boolean "disable", default: false
    t.datetime "expires_at"
    t.boolean "task_notify", default: true
    t.integer "manager_id"
    t.boolean "calendar_integration", default: false
    t.integer "pin_number"
    t.integer "manager_ids", default: [], array: true
    t.boolean "program_warning", default: false
    t.boolean "staff_performance_notification", default: true
    t.string "pin_code", default: ""
    t.boolean "domain_warning", default: false
    t.boolean "referral_notification", default: false
    t.string "gender", default: ""
    t.boolean "enable_gov_log_in", default: false
    t.boolean "enable_research_log_in", default: false
    t.datetime "deleted_at"
    t.datetime "activated_at"
    t.datetime "deactivated_at"
    t.string "preferred_language", default: "en"
    t.string "organization_name"
    t.string "profile"
    t.index "lower((email)::text) text_pattern_ops", name: "users_email_lower", unique: true
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "version_associations", id: :serial, force: :cascade do |t|
    t.integer "version_id"
    t.string "foreign_key_name", null: false
    t.integer "foreign_key_id"
    t.string "foreign_type"
    t.index ["foreign_key_name", "foreign_key_id", "foreign_type"], name: "index_version_associations_on_foreign_key"
    t.index ["version_id"], name: "index_version_associations_on_version_id"
    t.index ["version_id"], name: "index_version_associations_on_version_id"
  end

  create_table "version_associations", id: :serial, force: :cascade do |t|
    t.integer "version_id"
    t.string "foreign_key_name", null: false
    t.integer "foreign_key_id"
    t.string "foreign_type"
    t.index ["foreign_key_name", "foreign_key_id", "foreign_type"], name: "index_version_associations_on_foreign_key"
    t.index ["version_id"], name: "index_version_associations_on_version_id"
    t.index ["version_id"], name: "index_version_associations_on_version_id"
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.integer "transaction_id"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
    t.index ["transaction_id"], name: "index_versions_on_transaction_id"
    t.index ["transaction_id"], name: "index_versions_on_transaction_id"
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.integer "transaction_id"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
    t.index ["transaction_id"], name: "index_versions_on_transaction_id"
    t.index ["transaction_id"], name: "index_versions_on_transaction_id"
  end

  create_table "villages", id: :serial, force: :cascade do |t|
    t.string "code", default: ""
    t.string "name_kh", default: ""
    t.string "name_en", default: ""
    t.integer "commune_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["commune_id"], name: "index_villages_on_commune_id"
    t.index ["commune_id"], name: "index_villages_on_commune_id"
  end

  create_table "villages", id: :serial, force: :cascade do |t|
    t.string "code", default: ""
    t.string "name_kh", default: ""
    t.string "name_en", default: ""
    t.integer "commune_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["commune_id"], name: "index_villages_on_commune_id"
    t.index ["commune_id"], name: "index_villages_on_commune_id"
  end

  create_table "visit_clients", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.time "deleted_at"
    t.index ["user_id"], name: "index_visit_clients_on_user_id"
    t.index ["user_id"], name: "index_visit_clients_on_user_id"
  end

  create_table "visit_clients", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.time "deleted_at"
    t.index ["user_id"], name: "index_visit_clients_on_user_id"
    t.index ["user_id"], name: "index_visit_clients_on_user_id"
  end

  create_table "visits", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.time "deleted_at"
    t.index ["user_id"], name: "index_visits_on_user_id"
    t.index ["user_id"], name: "index_visits_on_user_id"
  end

  create_table "visits", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.time "deleted_at"
    t.index ["user_id"], name: "index_visits_on_user_id"
    t.index ["user_id"], name: "index_visits_on_user_id"
  end

  add_foreign_key "able_screening_questions", "public.question_groups", column: "question_group_id"
  add_foreign_key "able_screening_questions", "public.stages", column: "stage_id"
  add_foreign_key "able_screening_questions", "question_groups"
  add_foreign_key "able_screening_questions", "stages"
  add_foreign_key "able_screening_questions", "public.question_groups", column: "question_group_id"
  add_foreign_key "able_screening_questions", "public.stages", column: "stage_id"
  add_foreign_key "able_screening_questions", "question_groups"
  add_foreign_key "able_screening_questions", "stages"
  add_foreign_key "action_results", "government_forms"
  add_foreign_key "action_results", "public.government_forms", column: "government_form_id"
  add_foreign_key "action_results", "government_forms"
  add_foreign_key "action_results", "public.government_forms", column: "government_form_id"
  add_foreign_key "advanced_searches", "public.users", column: "user_id"
  add_foreign_key "advanced_searches", "users"
  add_foreign_key "advanced_searches", "public.users", column: "user_id"
  add_foreign_key "advanced_searches", "users"
  add_foreign_key "assessments", "clients"
  add_foreign_key "assessments", "public.clients", column: "client_id"
  add_foreign_key "assessments", "clients"
  add_foreign_key "assessments", "public.clients", column: "client_id"
  add_foreign_key "attachments", "able_screening_questions"
  add_foreign_key "attachments", "progress_notes"
  add_foreign_key "attachments", "public.able_screening_questions", column: "able_screening_question_id"
  add_foreign_key "attachments", "public.progress_notes", column: "progress_note_id"
  add_foreign_key "attachments", "able_screening_questions"
  add_foreign_key "attachments", "progress_notes"
  add_foreign_key "attachments", "public.able_screening_questions", column: "able_screening_question_id"
  add_foreign_key "attachments", "public.progress_notes", column: "progress_note_id"
  add_foreign_key "calendars", "public.users", column: "user_id"
  add_foreign_key "calendars", "users"
  add_foreign_key "calendars", "public.users", column: "user_id"
  add_foreign_key "calendars", "users"
  add_foreign_key "call_necessities", "calls"
  add_foreign_key "call_necessities", "necessities"
  add_foreign_key "call_necessities", "public.calls", column: "call_id"
  add_foreign_key "call_necessities", "public.necessities", column: "necessity_id"
  add_foreign_key "call_necessities", "calls"
  add_foreign_key "call_necessities", "necessities"
  add_foreign_key "call_necessities", "public.calls", column: "call_id"
  add_foreign_key "call_necessities", "public.necessities", column: "necessity_id"
  add_foreign_key "call_protection_concerns", "calls"
  add_foreign_key "call_protection_concerns", "protection_concerns"
  add_foreign_key "call_protection_concerns", "public.calls", column: "call_id"
  add_foreign_key "call_protection_concerns", "public.protection_concerns", column: "protection_concern_id"
  add_foreign_key "call_protection_concerns", "calls"
  add_foreign_key "call_protection_concerns", "protection_concerns"
  add_foreign_key "call_protection_concerns", "public.calls", column: "call_id"
  add_foreign_key "call_protection_concerns", "public.protection_concerns", column: "protection_concern_id"
  add_foreign_key "calls", "public.referees", column: "referee_id"
  add_foreign_key "calls", "referees"
  add_foreign_key "calls", "public.referees", column: "referee_id"
  add_foreign_key "calls", "referees"
  add_foreign_key "carers", "communes"
  add_foreign_key "carers", "districts"
  add_foreign_key "carers", "provinces"
  add_foreign_key "carers", "public.communes", column: "commune_id"
  add_foreign_key "carers", "public.districts", column: "district_id"
  add_foreign_key "carers", "public.provinces", column: "province_id"
  add_foreign_key "carers", "public.states", column: "state_id"
  add_foreign_key "carers", "public.subdistricts", column: "subdistrict_id"
  add_foreign_key "carers", "public.townships", column: "township_id"
  add_foreign_key "carers", "public.villages", column: "village_id"
  add_foreign_key "carers", "states"
  add_foreign_key "carers", "subdistricts"
  add_foreign_key "carers", "townships"
  add_foreign_key "carers", "villages"
  add_foreign_key "carers", "communes"
  add_foreign_key "carers", "districts"
  add_foreign_key "carers", "provinces"
  add_foreign_key "carers", "public.communes", column: "commune_id"
  add_foreign_key "carers", "public.districts", column: "district_id"
  add_foreign_key "carers", "public.provinces", column: "province_id"
  add_foreign_key "carers", "public.states", column: "state_id"
  add_foreign_key "carers", "public.subdistricts", column: "subdistrict_id"
  add_foreign_key "carers", "public.townships", column: "township_id"
  add_foreign_key "carers", "public.villages", column: "village_id"
  add_foreign_key "carers", "states"
  add_foreign_key "carers", "subdistricts"
  add_foreign_key "carers", "townships"
  add_foreign_key "carers", "villages"
  add_foreign_key "case_contracts", "cases"
  add_foreign_key "case_contracts", "public.cases", column: "case_id"
  add_foreign_key "case_contracts", "cases"
  add_foreign_key "case_contracts", "public.cases", column: "case_id"
  add_foreign_key "case_notes", "clients"
  add_foreign_key "case_notes", "custom_assessment_settings"
  add_foreign_key "case_notes", "public.clients", column: "client_id"
  add_foreign_key "case_notes", "public.custom_assessment_settings", column: "custom_assessment_setting_id"
  add_foreign_key "case_notes", "clients"
  add_foreign_key "case_notes", "custom_assessment_settings"
  add_foreign_key "case_notes", "public.clients", column: "client_id"
  add_foreign_key "case_notes", "public.custom_assessment_settings", column: "custom_assessment_setting_id"
  add_foreign_key "case_worker_clients", "clients"
  add_foreign_key "case_worker_clients", "public.clients", column: "client_id"
  add_foreign_key "case_worker_clients", "public.users", column: "user_id"
  add_foreign_key "case_worker_clients", "users"
  add_foreign_key "case_worker_clients", "clients"
  add_foreign_key "case_worker_clients", "public.clients", column: "client_id"
  add_foreign_key "case_worker_clients", "public.users", column: "user_id"
  add_foreign_key "case_worker_clients", "users"
  add_foreign_key "case_worker_tasks", "public.tasks", column: "task_id"
  add_foreign_key "case_worker_tasks", "public.users", column: "user_id"
  add_foreign_key "case_worker_tasks", "tasks"
  add_foreign_key "case_worker_tasks", "users"
  add_foreign_key "case_worker_tasks", "public.tasks", column: "task_id"
  add_foreign_key "case_worker_tasks", "public.users", column: "user_id"
  add_foreign_key "case_worker_tasks", "tasks"
  add_foreign_key "case_worker_tasks", "users"
  add_foreign_key "changelog_types", "changelogs"
  add_foreign_key "changelog_types", "public.changelogs", column: "changelog_id"
  add_foreign_key "changelog_types", "changelogs"
  add_foreign_key "changelog_types", "public.changelogs", column: "changelog_id"
  add_foreign_key "changelogs", "public.users", column: "user_id"
  add_foreign_key "changelogs", "users"
  add_foreign_key "changelogs", "public.users", column: "user_id"
  add_foreign_key "changelogs", "users"
  add_foreign_key "client_client_types", "client_types"
  add_foreign_key "client_client_types", "clients"
  add_foreign_key "client_client_types", "public.client_types", column: "client_type_id"
  add_foreign_key "client_client_types", "public.clients", column: "client_id"
  add_foreign_key "client_client_types", "client_types"
  add_foreign_key "client_client_types", "clients"
  add_foreign_key "client_client_types", "public.client_types", column: "client_type_id"
  add_foreign_key "client_client_types", "public.clients", column: "client_id"
  add_foreign_key "client_enrollment_trackings", "client_enrollments"
  add_foreign_key "client_enrollment_trackings", "public.client_enrollments", column: "client_enrollment_id"
  add_foreign_key "client_enrollment_trackings", "client_enrollments"
  add_foreign_key "client_enrollment_trackings", "public.client_enrollments", column: "client_enrollment_id"
  add_foreign_key "client_enrollments", "clients"
  add_foreign_key "client_enrollments", "program_streams"
  add_foreign_key "client_enrollments", "public.clients", column: "client_id"
  add_foreign_key "client_enrollments", "public.program_streams", column: "program_stream_id"
  add_foreign_key "client_enrollments", "clients"
  add_foreign_key "client_enrollments", "program_streams"
  add_foreign_key "client_enrollments", "public.clients", column: "client_id"
  add_foreign_key "client_enrollments", "public.program_streams", column: "program_stream_id"
  add_foreign_key "client_interviewees", "clients"
  add_foreign_key "client_interviewees", "interviewees"
  add_foreign_key "client_interviewees", "public.clients", column: "client_id"
  add_foreign_key "client_interviewees", "public.interviewees", column: "interviewee_id"
  add_foreign_key "client_interviewees", "clients"
  add_foreign_key "client_interviewees", "interviewees"
  add_foreign_key "client_interviewees", "public.clients", column: "client_id"
  add_foreign_key "client_interviewees", "public.interviewees", column: "interviewee_id"
  add_foreign_key "client_needs", "clients"
  add_foreign_key "client_needs", "needs"
  add_foreign_key "client_needs", "public.clients", column: "client_id"
  add_foreign_key "client_needs", "public.needs", column: "need_id"
  add_foreign_key "client_needs", "clients"
  add_foreign_key "client_needs", "needs"
  add_foreign_key "client_needs", "public.clients", column: "client_id"
  add_foreign_key "client_needs", "public.needs", column: "need_id"
  add_foreign_key "client_problems", "clients"
  add_foreign_key "client_problems", "problems"
  add_foreign_key "client_problems", "public.clients", column: "client_id"
  add_foreign_key "client_problems", "public.problems", column: "problem_id"
  add_foreign_key "client_problems", "clients"
  add_foreign_key "client_problems", "problems"
  add_foreign_key "client_problems", "public.clients", column: "client_id"
  add_foreign_key "client_problems", "public.problems", column: "problem_id"
  add_foreign_key "client_right_government_forms", "client_rights"
  add_foreign_key "client_right_government_forms", "government_forms"
  add_foreign_key "client_right_government_forms", "public.client_rights", column: "client_right_id"
  add_foreign_key "client_right_government_forms", "public.government_forms", column: "government_form_id"
  add_foreign_key "client_right_government_forms", "client_rights"
  add_foreign_key "client_right_government_forms", "government_forms"
  add_foreign_key "client_right_government_forms", "public.client_rights", column: "client_right_id"
  add_foreign_key "client_right_government_forms", "public.government_forms", column: "government_form_id"
  add_foreign_key "client_type_government_forms", "client_types"
  add_foreign_key "client_type_government_forms", "government_forms"
  add_foreign_key "client_type_government_forms", "public.client_types", column: "client_type_id"
  add_foreign_key "client_type_government_forms", "public.government_forms", column: "government_form_id"
  add_foreign_key "client_type_government_forms", "client_types"
  add_foreign_key "client_type_government_forms", "government_forms"
  add_foreign_key "client_type_government_forms", "public.client_types", column: "client_type_id"
  add_foreign_key "client_type_government_forms", "public.government_forms", column: "government_form_id"
  add_foreign_key "clients", "communes"
  add_foreign_key "clients", "districts"
  add_foreign_key "clients", "donors"
  add_foreign_key "clients", "public.communes", column: "commune_id"
  add_foreign_key "clients", "public.districts", column: "district_id"
  add_foreign_key "clients", "public.donors", column: "donor_id"
  add_foreign_key "clients", "public.states", column: "state_id"
  add_foreign_key "clients", "public.subdistricts", column: "subdistrict_id"
  add_foreign_key "clients", "public.townships", column: "township_id"
  add_foreign_key "clients", "public.villages", column: "village_id"
  add_foreign_key "clients", "states"
  add_foreign_key "clients", "subdistricts"
  add_foreign_key "clients", "townships"
  add_foreign_key "clients", "villages"
  add_foreign_key "clients", "communes"
  add_foreign_key "clients", "districts"
  add_foreign_key "clients", "donors"
  add_foreign_key "clients", "public.communes", column: "commune_id"
  add_foreign_key "clients", "public.districts", column: "district_id"
  add_foreign_key "clients", "public.donors", column: "donor_id"
  add_foreign_key "clients", "public.states", column: "state_id"
  add_foreign_key "clients", "public.subdistricts", column: "subdistrict_id"
  add_foreign_key "clients", "public.townships", column: "township_id"
  add_foreign_key "clients", "public.villages", column: "village_id"
  add_foreign_key "clients", "states"
  add_foreign_key "clients", "subdistricts"
  add_foreign_key "clients", "townships"
  add_foreign_key "clients", "villages"
  add_foreign_key "communes", "districts"
  add_foreign_key "communes", "public.districts", column: "district_id"
  add_foreign_key "communes", "districts"
  add_foreign_key "communes", "public.districts", column: "district_id"
  add_foreign_key "custom_field_permissions", "custom_fields"
  add_foreign_key "custom_field_permissions", "public.custom_fields", column: "custom_field_id"
  add_foreign_key "custom_field_permissions", "public.users", column: "user_id"
  add_foreign_key "custom_field_permissions", "users"
  add_foreign_key "custom_field_permissions", "custom_fields"
  add_foreign_key "custom_field_permissions", "public.custom_fields", column: "custom_field_id"
  add_foreign_key "custom_field_permissions", "public.users", column: "user_id"
  add_foreign_key "custom_field_permissions", "users"
  add_foreign_key "custom_field_properties", "custom_fields"
  add_foreign_key "custom_field_properties", "public.custom_fields", column: "custom_field_id"
  add_foreign_key "custom_field_properties", "custom_fields"
  add_foreign_key "custom_field_properties", "public.custom_fields", column: "custom_field_id"
  add_foreign_key "districts", "provinces"
  add_foreign_key "districts", "public.provinces", column: "province_id"
  add_foreign_key "districts", "provinces"
  add_foreign_key "districts", "public.provinces", column: "province_id"
  add_foreign_key "domains", "domain_groups"
  add_foreign_key "domains", "public.domain_groups", column: "domain_group_id"
  add_foreign_key "domains", "domain_groups"
  add_foreign_key "domains", "public.domain_groups", column: "domain_group_id"
  add_foreign_key "donor_organizations", "donors"
  add_foreign_key "donor_organizations", "organizations"
  add_foreign_key "donor_organizations", "public.donors", column: "donor_id"
  add_foreign_key "donor_organizations", "public.organizations", column: "organization_id"
  add_foreign_key "donor_organizations", "donors"
  add_foreign_key "donor_organizations", "organizations"
  add_foreign_key "donor_organizations", "public.donors", column: "donor_id"
  add_foreign_key "donor_organizations", "public.organizations", column: "organization_id"
  add_foreign_key "enrollment_trackings", "enrollments"
  add_foreign_key "enrollment_trackings", "public.enrollments", column: "enrollment_id"
  add_foreign_key "enrollment_trackings", "public.trackings", column: "tracking_id"
  add_foreign_key "enrollment_trackings", "trackings"
  add_foreign_key "enrollment_trackings", "enrollments"
  add_foreign_key "enrollment_trackings", "public.enrollments", column: "enrollment_id"
  add_foreign_key "enrollment_trackings", "public.trackings", column: "tracking_id"
  add_foreign_key "enrollment_trackings", "trackings"
  add_foreign_key "enrollments", "program_streams"
  add_foreign_key "enrollments", "public.program_streams", column: "program_stream_id"
  add_foreign_key "enrollments", "program_streams"
  add_foreign_key "enrollments", "public.program_streams", column: "program_stream_id"
  add_foreign_key "enter_ngo_users", "enter_ngos"
  add_foreign_key "enter_ngo_users", "public.enter_ngos", column: "enter_ngo_id"
  add_foreign_key "enter_ngo_users", "public.users", column: "user_id"
  add_foreign_key "enter_ngo_users", "users"
  add_foreign_key "enter_ngo_users", "enter_ngos"
  add_foreign_key "enter_ngo_users", "public.enter_ngos", column: "enter_ngo_id"
  add_foreign_key "enter_ngo_users", "public.users", column: "user_id"
  add_foreign_key "enter_ngo_users", "users"
  add_foreign_key "enter_ngos", "clients"
  add_foreign_key "enter_ngos", "public.clients", column: "client_id"
  add_foreign_key "enter_ngos", "clients"
  add_foreign_key "enter_ngos", "public.clients", column: "client_id"
  add_foreign_key "exit_ngos", "clients"
  add_foreign_key "exit_ngos", "public.clients", column: "client_id"
  add_foreign_key "exit_ngos", "clients"
  add_foreign_key "exit_ngos", "public.clients", column: "client_id"
  add_foreign_key "external_system_global_identities", "external_systems"
  add_foreign_key "external_system_global_identities", "public.external_systems", column: "external_system_id"
  add_foreign_key "external_system_global_identities", "public.global_identities", column: "global_id", primary_key: "ulid"
  add_foreign_key "external_system_global_identities", "external_systems"
  add_foreign_key "external_system_global_identities", "public.external_systems", column: "external_system_id"
  add_foreign_key "external_system_global_identities", "public.global_identities", column: "global_id", primary_key: "ulid"
  add_foreign_key "families", "communes"
  add_foreign_key "families", "districts"
  add_foreign_key "families", "public.communes", column: "commune_id"
  add_foreign_key "families", "public.districts", column: "district_id"
  add_foreign_key "families", "public.users", column: "user_id"
  add_foreign_key "families", "public.villages", column: "village_id"
  add_foreign_key "families", "users"
  add_foreign_key "families", "villages"
  add_foreign_key "families", "communes"
  add_foreign_key "families", "districts"
  add_foreign_key "families", "public.communes", column: "commune_id"
  add_foreign_key "families", "public.districts", column: "district_id"
  add_foreign_key "families", "public.users", column: "user_id"
  add_foreign_key "families", "public.villages", column: "village_id"
  add_foreign_key "families", "users"
  add_foreign_key "families", "villages"
  add_foreign_key "family_members", "families"
  add_foreign_key "family_members", "public.families", column: "family_id"
  add_foreign_key "family_members", "families"
  add_foreign_key "family_members", "public.families", column: "family_id"
  add_foreign_key "family_referrals", "families"
  add_foreign_key "family_referrals", "public.families", column: "family_id"
  add_foreign_key "family_referrals", "families"
  add_foreign_key "family_referrals", "public.families", column: "family_id"
  add_foreign_key "global_identity_organizations", "organizations"
  add_foreign_key "global_identity_organizations", "public.organizations", column: "organization_id"
  add_foreign_key "global_identity_organizations", "organizations"
  add_foreign_key "global_identity_organizations", "public.organizations", column: "organization_id"
  add_foreign_key "government_form_children_plans", "children_plans"
  add_foreign_key "government_form_children_plans", "government_forms"
  add_foreign_key "government_form_children_plans", "public.children_plans", column: "children_plan_id"
  add_foreign_key "government_form_children_plans", "public.government_forms", column: "government_form_id"
  add_foreign_key "government_form_children_plans", "children_plans"
  add_foreign_key "government_form_children_plans", "government_forms"
  add_foreign_key "government_form_children_plans", "public.children_plans", column: "children_plan_id"
  add_foreign_key "government_form_children_plans", "public.government_forms", column: "government_form_id"
  add_foreign_key "government_form_family_plans", "family_plans"
  add_foreign_key "government_form_family_plans", "government_forms"
  add_foreign_key "government_form_family_plans", "public.family_plans", column: "family_plan_id"
  add_foreign_key "government_form_family_plans", "public.government_forms", column: "government_form_id"
  add_foreign_key "government_form_family_plans", "family_plans"
  add_foreign_key "government_form_family_plans", "government_forms"
  add_foreign_key "government_form_family_plans", "public.family_plans", column: "family_plan_id"
  add_foreign_key "government_form_family_plans", "public.government_forms", column: "government_form_id"
  add_foreign_key "government_form_interviewees", "government_forms"
  add_foreign_key "government_form_interviewees", "interviewees"
  add_foreign_key "government_form_interviewees", "public.government_forms", column: "government_form_id"
  add_foreign_key "government_form_interviewees", "public.interviewees", column: "interviewee_id"
  add_foreign_key "government_form_interviewees", "government_forms"
  add_foreign_key "government_form_interviewees", "interviewees"
  add_foreign_key "government_form_interviewees", "public.government_forms", column: "government_form_id"
  add_foreign_key "government_form_interviewees", "public.interviewees", column: "interviewee_id"
  add_foreign_key "government_form_needs", "government_forms"
  add_foreign_key "government_form_needs", "needs"
  add_foreign_key "government_form_needs", "public.government_forms", column: "government_form_id"
  add_foreign_key "government_form_needs", "public.needs", column: "need_id"
  add_foreign_key "government_form_needs", "government_forms"
  add_foreign_key "government_form_needs", "needs"
  add_foreign_key "government_form_needs", "public.government_forms", column: "government_form_id"
  add_foreign_key "government_form_needs", "public.needs", column: "need_id"
  add_foreign_key "government_form_problems", "government_forms"
  add_foreign_key "government_form_problems", "problems"
  add_foreign_key "government_form_problems", "public.government_forms", column: "government_form_id"
  add_foreign_key "government_form_problems", "public.problems", column: "problem_id"
  add_foreign_key "government_form_problems", "government_forms"
  add_foreign_key "government_form_problems", "problems"
  add_foreign_key "government_form_problems", "public.government_forms", column: "government_form_id"
  add_foreign_key "government_form_problems", "public.problems", column: "problem_id"
  add_foreign_key "government_form_service_types", "government_forms"
  add_foreign_key "government_form_service_types", "public.government_forms", column: "government_form_id"
  add_foreign_key "government_form_service_types", "public.service_types", column: "service_type_id"
  add_foreign_key "government_form_service_types", "service_types"
  add_foreign_key "government_form_service_types", "government_forms"
  add_foreign_key "government_form_service_types", "public.government_forms", column: "government_form_id"
  add_foreign_key "government_form_service_types", "public.service_types", column: "service_type_id"
  add_foreign_key "government_form_service_types", "service_types"
  add_foreign_key "government_forms", "clients"
  add_foreign_key "government_forms", "communes"
  add_foreign_key "government_forms", "districts"
  add_foreign_key "government_forms", "provinces"
  add_foreign_key "government_forms", "public.clients", column: "client_id"
  add_foreign_key "government_forms", "public.communes", column: "commune_id"
  add_foreign_key "government_forms", "public.districts", column: "district_id"
  add_foreign_key "government_forms", "public.provinces", column: "province_id"
  add_foreign_key "government_forms", "public.villages", column: "village_id"
  add_foreign_key "government_forms", "villages"
  add_foreign_key "government_forms", "clients"
  add_foreign_key "government_forms", "communes"
  add_foreign_key "government_forms", "districts"
  add_foreign_key "government_forms", "provinces"
  add_foreign_key "government_forms", "public.clients", column: "client_id"
  add_foreign_key "government_forms", "public.communes", column: "commune_id"
  add_foreign_key "government_forms", "public.districts", column: "district_id"
  add_foreign_key "government_forms", "public.provinces", column: "province_id"
  add_foreign_key "government_forms", "public.villages", column: "village_id"
  add_foreign_key "government_forms", "villages"
  add_foreign_key "hotlines", "calls"
  add_foreign_key "hotlines", "clients"
  add_foreign_key "hotlines", "public.calls", column: "call_id"
  add_foreign_key "hotlines", "public.clients", column: "client_id"
  add_foreign_key "hotlines", "calls"
  add_foreign_key "hotlines", "clients"
  add_foreign_key "hotlines", "public.calls", column: "call_id"
  add_foreign_key "hotlines", "public.clients", column: "client_id"
  add_foreign_key "leave_programs", "client_enrollments"
  add_foreign_key "leave_programs", "enrollments"
  add_foreign_key "leave_programs", "public.client_enrollments", column: "client_enrollment_id"
  add_foreign_key "leave_programs", "public.enrollments", column: "enrollment_id"
  add_foreign_key "leave_programs", "client_enrollments"
  add_foreign_key "leave_programs", "enrollments"
  add_foreign_key "leave_programs", "public.client_enrollments", column: "client_enrollment_id"
  add_foreign_key "leave_programs", "public.enrollments", column: "enrollment_id"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_grants", "public.oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_grants", "public.oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "public.oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "public.oauth_applications", column: "application_id"
  add_foreign_key "partners", "organization_types"
  add_foreign_key "partners", "public.organization_types", column: "organization_type_id"
  add_foreign_key "partners", "organization_types"
  add_foreign_key "partners", "public.organization_types", column: "organization_type_id"
  add_foreign_key "program_stream_permissions", "program_streams"
  add_foreign_key "program_stream_permissions", "public.program_streams", column: "program_stream_id"
  add_foreign_key "program_stream_permissions", "public.users", column: "user_id"
  add_foreign_key "program_stream_permissions", "users"
  add_foreign_key "program_stream_permissions", "program_streams"
  add_foreign_key "program_stream_permissions", "public.program_streams", column: "program_stream_id"
  add_foreign_key "program_stream_permissions", "public.users", column: "user_id"
  add_foreign_key "program_stream_permissions", "users"
  add_foreign_key "program_stream_services", "program_streams"
  add_foreign_key "program_stream_services", "public.program_streams", column: "program_stream_id"
  add_foreign_key "program_stream_services", "public.services", column: "service_id"
  add_foreign_key "program_stream_services", "services"
  add_foreign_key "program_stream_services", "program_streams"
  add_foreign_key "program_stream_services", "public.program_streams", column: "program_stream_id"
  add_foreign_key "program_stream_services", "public.services", column: "service_id"
  add_foreign_key "program_stream_services", "services"
  add_foreign_key "progress_notes", "clients"
  add_foreign_key "progress_notes", "locations"
  add_foreign_key "progress_notes", "materials"
  add_foreign_key "progress_notes", "progress_note_types"
  add_foreign_key "progress_notes", "public.clients", column: "client_id"
  add_foreign_key "progress_notes", "public.locations", column: "location_id"
  add_foreign_key "progress_notes", "public.materials", column: "material_id"
  add_foreign_key "progress_notes", "public.progress_note_types", column: "progress_note_type_id"
  add_foreign_key "progress_notes", "public.users", column: "user_id"
  add_foreign_key "progress_notes", "users"
  add_foreign_key "progress_notes", "clients"
  add_foreign_key "progress_notes", "locations"
  add_foreign_key "progress_notes", "materials"
  add_foreign_key "progress_notes", "progress_note_types"
  add_foreign_key "progress_notes", "public.clients", column: "client_id"
  add_foreign_key "progress_notes", "public.locations", column: "location_id"
  add_foreign_key "progress_notes", "public.materials", column: "material_id"
  add_foreign_key "progress_notes", "public.progress_note_types", column: "progress_note_type_id"
  add_foreign_key "progress_notes", "public.users", column: "user_id"
  add_foreign_key "progress_notes", "users"
  add_foreign_key "quantitative_type_permissions", "public.quantitative_types", column: "quantitative_type_id"
  add_foreign_key "quantitative_type_permissions", "public.users", column: "user_id"
  add_foreign_key "quantitative_type_permissions", "quantitative_types"
  add_foreign_key "quantitative_type_permissions", "users"
  add_foreign_key "quantitative_type_permissions", "public.quantitative_types", column: "quantitative_type_id"
  add_foreign_key "quantitative_type_permissions", "public.users", column: "user_id"
  add_foreign_key "quantitative_type_permissions", "quantitative_types"
  add_foreign_key "quantitative_type_permissions", "users"
  add_foreign_key "quarterly_reports", "cases"
  add_foreign_key "quarterly_reports", "public.cases", column: "case_id"
  add_foreign_key "quarterly_reports", "cases"
  add_foreign_key "quarterly_reports", "public.cases", column: "case_id"
  add_foreign_key "referees", "communes"
  add_foreign_key "referees", "districts"
  add_foreign_key "referees", "provinces"
  add_foreign_key "referees", "public.communes", column: "commune_id"
  add_foreign_key "referees", "public.districts", column: "district_id"
  add_foreign_key "referees", "public.provinces", column: "province_id"
  add_foreign_key "referees", "public.states", column: "state_id"
  add_foreign_key "referees", "public.subdistricts", column: "subdistrict_id"
  add_foreign_key "referees", "public.townships", column: "township_id"
  add_foreign_key "referees", "public.villages", column: "village_id"
  add_foreign_key "referees", "states"
  add_foreign_key "referees", "subdistricts"
  add_foreign_key "referees", "townships"
  add_foreign_key "referees", "villages"
  add_foreign_key "referees", "communes"
  add_foreign_key "referees", "districts"
  add_foreign_key "referees", "provinces"
  add_foreign_key "referees", "public.communes", column: "commune_id"
  add_foreign_key "referees", "public.districts", column: "district_id"
  add_foreign_key "referees", "public.provinces", column: "province_id"
  add_foreign_key "referees", "public.states", column: "state_id"
  add_foreign_key "referees", "public.subdistricts", column: "subdistrict_id"
  add_foreign_key "referees", "public.townships", column: "township_id"
  add_foreign_key "referees", "public.villages", column: "village_id"
  add_foreign_key "referees", "states"
  add_foreign_key "referees", "subdistricts"
  add_foreign_key "referees", "townships"
  add_foreign_key "referees", "villages"
  add_foreign_key "referrals", "clients"
  add_foreign_key "referrals", "public.clients", column: "client_id"
  add_foreign_key "referrals", "clients"
  add_foreign_key "referrals", "public.clients", column: "client_id"
  add_foreign_key "services", "public.global_services", column: "uuid", primary_key: "uuid"
  add_foreign_key "services", "public.global_services", column: "uuid", primary_key: "uuid"
  add_foreign_key "services", "public.global_services", column: "uuid", primary_key: "uuid"
  add_foreign_key "services", "public.global_services", column: "uuid", primary_key: "uuid"
  add_foreign_key "settings", "communes"
  add_foreign_key "settings", "districts"
  add_foreign_key "settings", "provinces"
  add_foreign_key "settings", "public.communes", column: "commune_id"
  add_foreign_key "settings", "public.districts", column: "district_id"
  add_foreign_key "settings", "public.provinces", column: "province_id"
  add_foreign_key "settings", "communes"
  add_foreign_key "settings", "districts"
  add_foreign_key "settings", "provinces"
  add_foreign_key "settings", "public.communes", column: "commune_id"
  add_foreign_key "settings", "public.districts", column: "district_id"
  add_foreign_key "settings", "public.provinces", column: "province_id"
  add_foreign_key "sponsors", "clients"
  add_foreign_key "sponsors", "donors"
  add_foreign_key "sponsors", "public.clients", column: "client_id"
  add_foreign_key "sponsors", "public.donors", column: "donor_id"
  add_foreign_key "sponsors", "clients"
  add_foreign_key "sponsors", "donors"
  add_foreign_key "sponsors", "public.clients", column: "client_id"
  add_foreign_key "sponsors", "public.donors", column: "donor_id"
  add_foreign_key "subdistricts", "districts"
  add_foreign_key "subdistricts", "public.districts", column: "district_id"
  add_foreign_key "subdistricts", "districts"
  add_foreign_key "subdistricts", "public.districts", column: "district_id"
  add_foreign_key "surveys", "clients"
  add_foreign_key "surveys", "public.clients", column: "client_id"
  add_foreign_key "surveys", "clients"
  add_foreign_key "surveys", "public.clients", column: "client_id"
  add_foreign_key "tasks", "clients", on_delete: :nullify
  add_foreign_key "tasks", "public.clients", column: "client_id", on_delete: :nullify
  add_foreign_key "tasks", "clients", on_delete: :nullify
  add_foreign_key "tasks", "public.clients", column: "client_id", on_delete: :nullify
  add_foreign_key "townships", "public.states", column: "state_id"
  add_foreign_key "townships", "states"
  add_foreign_key "townships", "public.states", column: "state_id"
  add_foreign_key "townships", "states"
  add_foreign_key "trackings", "program_streams"
  add_foreign_key "trackings", "public.program_streams", column: "program_stream_id"
  add_foreign_key "trackings", "program_streams"
  add_foreign_key "trackings", "public.program_streams", column: "program_stream_id"
  add_foreign_key "users", "organizations"
  add_foreign_key "users", "public.organizations", column: "organization_id"
  add_foreign_key "users", "organizations"
  add_foreign_key "users", "public.organizations", column: "organization_id"
  add_foreign_key "villages", "communes"
  add_foreign_key "villages", "public.communes", column: "commune_id"
  add_foreign_key "villages", "communes"
  add_foreign_key "villages", "public.communes", column: "commune_id"
  add_foreign_key "visit_clients", "public.users", column: "user_id"
  add_foreign_key "visit_clients", "users"
  add_foreign_key "visit_clients", "public.users", column: "user_id"
  add_foreign_key "visit_clients", "users"
  add_foreign_key "visits", "public.users", column: "user_id"
  add_foreign_key "visits", "users"
  add_foreign_key "visits", "public.users", column: "user_id"
  add_foreign_key "visits", "users"
end
