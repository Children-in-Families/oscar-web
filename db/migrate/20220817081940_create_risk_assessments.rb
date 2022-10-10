class CreateRiskAssessments < ActiveRecord::Migration
  def change
    create_table :risk_assessments do |t|
      t.date :assessment_date
      t.string :protection_concern, array: true, default: []
      t.string :level_of_risk
      t.string :other_protection_concern_specification
      t.text :client_perspective
      t.boolean :has_known_chronic_disease, default: false
      t.boolean :has_disability, default: false
      t.boolean :has_hiv_or_aid, default: false
      t.string :known_chronic_disease_specification
      t.string :disability_specification
      t.string :hiv_or_aid_specification
      t.text :relevant_referral_information
      t.integer :history_of_disability_id
      t.integer :history_of_harm_id
      t.integer :history_of_high_risk_behaviour_id
      t.integer :history_of_family_separation_id
      t.belongs_to :client, index: { unique: true }, foreign_key: true

      t.timestamps null: false
    end
    add_index :risk_assessments, :assessment_date
    add_index :risk_assessments, :history_of_disability_id
    add_index :risk_assessments, :history_of_harm_id
    add_index :risk_assessments, :history_of_high_risk_behaviour_id
    add_index :risk_assessments, :history_of_family_separation_id
  end
end
