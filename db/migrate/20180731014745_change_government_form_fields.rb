class ChangeGovernmentFormFields < ActiveRecord::Migration
  def change
    remove_column :government_forms, :interview_commune, :string
    remove_column :government_forms, :interview_village, :string
    remove_column :government_forms, :assessment_commune, :string
    remove_column :government_forms, :primary_carer_commune, :string
    remove_column :government_forms, :primary_carer_village, :string

    add_column :government_forms, :interview_commune_id, :integer
    add_column :government_forms, :interview_village_id, :integer
    add_column :government_forms, :assessment_commune_id, :integer
    add_column :government_forms, :primary_carer_commune_id, :integer
    add_column :government_forms, :primary_carer_village_id, :integer
  end
end
