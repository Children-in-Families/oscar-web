class CreateGovernmentForm < ActiveRecord::Migration
  def change
    create_table :government_forms do |t|
      t.string :name, default: ''
      t.date :date
      t.string :client_code, default: ''
      t.string :interview_village, default: ''
      t.string :interview_commune, default: ''
      t.integer :interview_district_id
      t.integer :interview_province_id
      t.integer :case_worker_id
      t.string :case_worker_phone, default: ''
      t.references :client, index: true, foreign_key: true
      t.string :primary_carer_relationship, default: ''
      t.string :primary_carer_house, default: ''
      t.string :primary_carer_street, default: ''
      t.string :primary_carer_village, default: ''
      t.string :primary_carer_commune, default: ''
      t.integer :primary_carer_district_id
      t.integer :primary_carer_province_id
      t.string :source_info, default: ''
      t.string :summary_info_of_referral, default: ''
      t.string :guardian_comment, default: ''
      t.string :case_worker_comment, default: ''
      t.string :other_interviewee, default: ''
      t.string :other_client_type, default: ''
      t.string :other_need, default: ''
      t.string :other_problem, default: ''

      t.timestamps
    end
  end
end
