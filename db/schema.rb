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

ActiveRecord::Schema.define(version: 20160505031003) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "agencies", force: :cascade do |t|
    t.string   "name",                   default: ""
    t.text     "description",            default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "agencies_clients_count", default: 0
  end

  create_table "agencies_clients", force: :cascade do |t|
    t.integer  "client_id"
    t.integer  "agency_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "assessment_domains", force: :cascade do |t|
    t.text     "note",           default: ""
    t.integer  "previous_score"
    t.integer  "score"
    t.text     "reason",         default: ""
    t.integer  "assessment_id"
    t.integer  "domain_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "goal",           default: ""
  end

  create_table "assessments", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "client_id"
  end

  add_index "assessments", ["client_id"], name: "index_assessments_on_client_id", using: :btree

  create_table "case_contracts", force: :cascade do |t|
    t.date     "signed_on"
    t.integer  "case_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "case_contracts", ["case_id"], name: "index_case_contracts_on_case_id", using: :btree

  create_table "case_note_domain_groups", force: :cascade do |t|
    t.text     "note",            default: ""
    t.integer  "case_note_id"
    t.integer  "domain_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "case_notes", force: :cascade do |t|
    t.string   "attendee",      default: ""
    t.date     "meeting_date"
    t.integer  "assessment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "client_id"
  end

  add_index "case_notes", ["client_id"], name: "index_case_notes_on_client_id", using: :btree

  create_table "cases", force: :cascade do |t|
    t.date     "start_date"
    t.string   "carer_names",             default: ""
    t.string   "carer_address",           default: ""
    t.string   "carer_phone_number",      default: ""
    t.float    "support_amount",          default: 0.0
    t.text     "support_note",            default: ""
    t.text     "case_type",               default: "EC"
    t.boolean  "exited",                  default: false
    t.date     "exit_date"
    t.text     "exit_note",               default: ""
    t.integer  "user_id"
    t.integer  "client_id"
    t.integer  "family_id"
    t.integer  "partner_id"
    t.integer  "province_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "family_preservation",     default: false
    t.string   "status",                  default: ""
    t.date     "placement_date"
    t.date     "initial_assessment_date"
    t.float    "case_length"
    t.date     "case_conference_date"
    t.float    "time_in_care"
    t.boolean  "exited_from_cif",         default: false
  end

  create_table "clients", force: :cascade do |t|
    t.string   "code",                             default: ""
    t.string   "first_name",                       default: ""
    t.string   "last_name",                        default: ""
    t.string   "gender",                           default: "Male"
    t.date     "date_of_birth"
    t.string   "status",                           default: "Referred"
    t.date     "initial_referral_date"
    t.string   "referral_phone",                   default: ""
    t.integer  "birth_province_id"
    t.integer  "received_by_id"
    t.integer  "followed_up_by_id"
    t.date     "follow_up_date"
    t.string   "current_address",                  default: ""
    t.string   "school_name",                      default: ""
    t.string   "school_grade",                     default: ""
    t.boolean  "has_been_in_orphanage",            default: false
    t.boolean  "able",                             default: false
    t.boolean  "has_been_in_government_care",      default: false
    t.text     "relevant_referral_information",    default: ""
    t.string   "state",                            default: ""
    t.text     "rejected_note",                    default: ""
    t.integer  "province_id"
    t.integer  "referral_source_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "completed",                        default: false
    t.text     "reason_for_referral",              default: ""
    t.boolean  "is_receiving_additional_benefits", default: false
    t.text     "background",                       default: ""
    t.integer  "grade",                            default: 0
    t.string   "slug"
  end

  add_index "clients", ["slug"], name: "index_clients_on_slug", unique: true, using: :btree

  create_table "clients_quantitative_cases", force: :cascade do |t|
    t.integer  "client_id"
    t.integer  "quantitative_case_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "departments", force: :cascade do |t|
    t.string   "name",        default: ""
    t.text     "description", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "users_count", default: 0
  end

  create_table "domain_groups", force: :cascade do |t|
    t.string   "name",          default: ""
    t.text     "description",   default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "domains_count", default: 0
  end

  create_table "domains", force: :cascade do |t|
    t.string   "name",            default: ""
    t.string   "identity",        default: ""
    t.text     "description",     default: ""
    t.integer  "domain_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tasks_count",     default: 0
    t.string   "score_1_color",   default: "danger"
    t.string   "score_2_color",   default: "warning"
    t.string   "score_3_color",   default: "info"
    t.string   "score_4_color",   default: "success"
  end

  add_index "domains", ["domain_group_id"], name: "index_domains_on_domain_group_id", using: :btree

  create_table "families", force: :cascade do |t|
    t.string   "code"
    t.string   "name",                            default: ""
    t.string   "address",                         default: ""
    t.text     "caregiver_information",           default: ""
    t.integer  "significant_family_member_count", default: 1
    t.float    "household_income",                default: 0.0
    t.boolean  "dependable_income",               default: false
    t.integer  "female_children_count",           default: 0
    t.integer  "male_children_count",             default: 0
    t.integer  "female_adult_count",              default: 0
    t.integer  "male_adult_count",                default: 0
    t.string   "family_type",                     default: "kinship"
    t.date     "contract_date"
    t.integer  "province_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cases_count",                     default: 0
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "government_reports", force: :cascade do |t|
    t.string   "code",                          default: ""
    t.string   "initial_capital",               default: ""
    t.string   "initial_city",                  default: ""
    t.string   "initial_commune",               default: ""
    t.date     "initial_date"
    t.string   "client_code",                   default: ""
    t.string   "commune",                       default: ""
    t.string   "city",                          default: ""
    t.string   "capital",                       default: ""
    t.string   "organisation_name",             default: ""
    t.string   "organisation_phone_number",     default: ""
    t.string   "client_name",                   default: ""
    t.date     "client_date_of_birth"
    t.string   "client_gender",                 default: ""
    t.string   "found_client_at",               default: ""
    t.string   "found_client_village",          default: ""
    t.string   "education",                     default: ""
    t.string   "carer_name",                    default: ""
    t.string   "client_contact",                default: ""
    t.string   "carer_house_number",            default: ""
    t.string   "carer_street_number",           default: ""
    t.string   "carer_village",                 default: ""
    t.string   "carer_commune",                 default: ""
    t.string   "carer_city",                    default: ""
    t.string   "carer_capital",                 default: ""
    t.string   "carer_phone_number",            default: ""
    t.date     "case_information_date"
    t.string   "referral_name",                 default: ""
    t.string   "referral_position",             default: ""
    t.boolean  "anonymous",                     default: false
    t.text     "anonymous_description",         default: ""
    t.boolean  "client_living_with_guardian",   default: false
    t.text     "present_physical_health",       default: ""
    t.text     "physical_health_need",          default: ""
    t.text     "physical_health_plan",          default: ""
    t.text     "present_supplies",              default: ""
    t.text     "supplies_need",                 default: ""
    t.text     "supplies_plan",                 default: ""
    t.text     "present_education",             default: ""
    t.text     "education_need",                default: ""
    t.text     "education_plan",                default: ""
    t.text     "present_family_communication",  default: ""
    t.text     "family_communication_need",     default: ""
    t.text     "family_communication_plan",     default: ""
    t.text     "present_society_communication", default: ""
    t.text     "society_communication_need",    default: ""
    t.text     "society_communication_plan",    default: ""
    t.text     "present_emotional_health",      default: ""
    t.text     "emotional_health_need",         default: ""
    t.text     "emotional_health_plan",         default: ""
    t.boolean  "mission_obtainable",            default: false
    t.boolean  "first_mission",                 default: false
    t.boolean  "second_mission",                default: false
    t.boolean  "third_mission",                 default: false
    t.boolean  "fourth_mission",                default: false
    t.date     "done_date"
    t.date     "agreed_date"
    t.integer  "client_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "partners", force: :cascade do |t|
    t.string   "name",                  default: ""
    t.string   "address",               default: ""
    t.date     "start_date"
    t.string   "contact_person_name",   default: ""
    t.string   "contact_person_email",  default: ""
    t.string   "contact_person_mobile", default: ""
    t.string   "organisation_type",     default: ""
    t.string   "affiliation",           default: ""
    t.string   "engagement",            default: ""
    t.text     "background",            default: ""
    t.integer  "province_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cases_count",           default: 0
  end

  create_table "provinces", force: :cascade do |t|
    t.string   "name",           default: ""
    t.text     "description",    default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cases_count",    default: 0
    t.integer  "clients_count",  default: 0
    t.integer  "families_count", default: 0
    t.integer  "partners_count", default: 0
    t.integer  "users_count",    default: 0
  end

  create_table "quantitative_cases", force: :cascade do |t|
    t.string   "value",                default: ""
    t.integer  "quantitative_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "quantitative_types", force: :cascade do |t|
    t.string   "name",                     default: ""
    t.text     "description",              default: ""
    t.integer  "quantitative_cases_count", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "quarterly_reports", force: :cascade do |t|
    t.date     "visit_date"
    t.integer  "code",                                                     limit: 8
    t.integer  "case_id"
    t.text     "general_health_or_appearance",                                       default: ""
    t.text     "child_school_attendance_or_progress",                                default: ""
    t.text     "general_appearance_of_home",                                         default: ""
    t.text     "observations_of_drug_alchohol_abuse",                                default: ""
    t.text     "describe_if_yes",                                                    default: ""
    t.text     "describe_the_family_current_situation",                              default: ""
    t.text     "has_the_situation_changed_from_the_previous_visit",                  default: ""
    t.text     "how_did_i_encourage_the_client",                                     default: ""
    t.text     "what_future_teachings_or_trainings_could_help_the_client",           default: ""
    t.text     "what_is_my_plan_for_the_next_visit_to_the_client",                   default: ""
    t.boolean  "money_and_supplies_being_used_appropriately",                        default: false
    t.text     "how_are_they_being_misused",                                         default: ""
    t.integer  "staff_id"
    t.text     "spiritual_developments_with_the_child_or_family",                    default: ""
    t.datetime "created_at",                                                                         null: false
    t.datetime "updated_at",                                                                         null: false
  end

  add_index "quarterly_reports", ["case_id"], name: "index_quarterly_reports_on_case_id", using: :btree

  create_table "referral_sources", force: :cascade do |t|
    t.string   "name",          default: ""
    t.text     "description",   default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "clients_count", default: 0
  end

  create_table "tasks", force: :cascade do |t|
    t.string   "name",                      default: ""
    t.date     "completion_date"
    t.datetime "remind_at"
    t.boolean  "completed",                 default: false
    t.integer  "user_id"
    t.integer  "case_note_domain_group_id"
    t.integer  "domain_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "client_id"
  end

  add_index "tasks", ["client_id"], name: "index_tasks_on_client_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "first_name",             default: ""
    t.string   "last_name",              default: ""
    t.string   "roles",                  default: "case worker"
    t.date     "start_date"
    t.string   "job_title",              default: ""
    t.string   "mobile",                 default: ""
    t.date     "date_of_birth"
    t.boolean  "archived",               default: false
    t.integer  "province_id"
    t.integer  "department_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                  default: "",            null: false
    t.string   "encrypted_password",     default: "",            null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,             null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.integer  "clients_count",          default: 0
    t.integer  "cases_count",            default: 0
    t.integer  "tasks_count",            default: 0
    t.string   "provider",               default: "email",       null: false
    t.string   "uid",                    default: "",            null: false
    t.json     "tokens"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "assessments", "clients"
  add_foreign_key "case_contracts", "cases"
  add_foreign_key "case_notes", "clients"
  add_foreign_key "domains", "domain_groups"
  add_foreign_key "quarterly_reports", "cases"
  add_foreign_key "tasks", "clients"
end
