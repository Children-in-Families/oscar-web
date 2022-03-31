class AddMissingIndexes < ActiveRecord::Migration
  def change
    add_index :case_worker_communities, [:community_id, :user_id]
    add_index :case_worker_families, [:family_id, :user_id]
    add_index :community_quantitative_cases, [:community_id, :quantitative_case_id], name: 'index_on_community_id_and_quantitative_case_id'
    add_index :custom_fields, :form_title
    add_index :custom_field_permissions, [:custom_field_id, :user_id]
    add_index :custom_field_properties, [:custom_formable_id, :custom_formable_type], name: 'index_on_custom_formable_id_and_custom_formable_type'
    add_index :enrollments, [:programmable_id, :programmable_type]
    add_index :enter_ngos, [:acceptable_id, :acceptable_type]
    add_index :exit_ngos, [:rejectable_id, :rejectable_type]
    add_index :external_systems, :name
    add_index :family_quantitative_cases, [:family_id, :quantitative_case_id], name: 'index_on_family_id_and_quantitative_case_id'
    add_index :form_builder_attachments, :name
    add_index :form_builder_attachments, [:form_buildable_id, :form_buildable_type], name: 'index_on_form_buildable_id_and_form_buildable_type'
    add_index :government_form_children_plans, [:children_plan_id, :government_form_id], name: 'index_on_children_plan_id_and_government_form_id'
    add_index :government_form_family_plans, [:family_plan_id, :government_form_id], name: 'index_on_family_plan_id_and_government_form_id'
    add_index :referral_sources, :name
    add_index :referral_sources, :name_en
    add_index :referrals_services, [:referral_id, :service_id]
    add_index :organizations, :short_name
    add_index :organizations, :full_name
    add_index :program_streams, :name
  end
end