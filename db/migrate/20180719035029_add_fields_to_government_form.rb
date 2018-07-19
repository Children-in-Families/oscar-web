class AddFieldsToGovernmentForm < ActiveRecord::Migration
  def change
    add_column :government_forms, :gov_placement_date, :date
    add_column :government_forms, :care_type, :string, default: ''
    add_column :government_forms, :primary_carer, :string, default: ''
    add_column :government_forms, :secondary_carer, :string, default: ''
    add_column :government_forms, :carer_contact_info, :string, default: ''
  end
end
