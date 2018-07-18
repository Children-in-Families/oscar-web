class AddFieldsToGovernmentForm < ActiveRecord::Migration
  def change
    add_column :government_forms, :caseworker_assumption, :string, default: ''
    add_column :government_forms, :assumption_description, :text, default: ''
    add_column :government_forms, :assumption_date, :date
    add_column :government_forms, :contact_type, :string, default: ''
    add_column :government_forms, :client_decision, :string, default: ''
    add_column :government_forms, :other_service_type, :string, default: ''
  end
end
