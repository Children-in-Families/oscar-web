class AddFieldsToGovernmentForm < ActiveRecord::Migration
  def change
    add_column :government_forms, :caseworker_assumption, :string, default: ''
    add_column :government_forms, :assumption_description, :text, default: ''
    add_column :government_forms, :assumption_date, :date
    add_column :government_forms, :contact_type, :string, default: ''
    add_column :government_forms, :client_decision, :string, default: ''
    add_column :government_forms, :other_service_type, :string, default: ''
    add_column :government_forms, :gov_placement_date, :date
    add_column :government_forms, :care_type, :string, default: ''
    add_column :government_forms, :primary_carer, :string, default: ''
    add_column :government_forms, :secondary_carer, :string, default: ''
    add_column :government_forms, :carer_contact_info, :string, default: ''
    add_column :government_forms, :assessment_province_id, :integer
    add_column :government_forms, :assessment_district_id, :integer
    add_column :government_forms, :assessment_commune, :string, default: ''
    add_column :government_forms, :new_carer, :string, default: ''
    add_column :government_forms, :new_carer_gender, :string, default: ''
    add_column :government_forms, :new_carer_date_of_birth, :date
    add_column :government_forms, :new_carer_relationship, :string, default: ''
  end
end
