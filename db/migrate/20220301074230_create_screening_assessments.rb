class CreateScreeningAssessments < ActiveRecord::Migration
  def change
    create_table :screening_assessments do |t|
      t.datetime :screening_assessment_date
      t.string :client_age
      t.string :visitor
      t.string :client_milestone_age
      t.string :attachments, default: [],    array: true
      t.text :note
      t.boolean :smile_back_during_interaction
      t.boolean :follow_object_passed_midline
      t.boolean :turn_head_to_sound
      t.boolean :head_up_45_degree
    end
    add_index :screening_assessments, :screening_assessment_date
  end
end
