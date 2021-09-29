class IndexForeignKeysInGovernmentForms < ActiveRecord::Migration
  def change
    add_index :government_forms, :assessment_commune_id
    add_index :government_forms, :assessment_district_id
    add_index :government_forms, :assessment_province_id
    add_index :government_forms, :case_closure_id
    add_index :government_forms, :case_worker_id
    add_index :government_forms, :interview_commune_id
    add_index :government_forms, :interview_district_id
    add_index :government_forms, :interview_province_id
    add_index :government_forms, :interview_village_id
    add_index :government_forms, :primary_carer_commune_id
    add_index :government_forms, :primary_carer_district_id
    add_index :government_forms, :primary_carer_province_id
    add_index :government_forms, :primary_carer_village_id
  end
end
