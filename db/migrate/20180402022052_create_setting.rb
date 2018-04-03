class CreateSetting < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.integer :min_assessment
      t.integer :max_assessment
      t.string :assessment_frequency
      t.string :country_name, default: ''
      t.integer :min_case_note
      t.integer :max_case_note
      t.string :case_note_frequency
    end
  end
end
