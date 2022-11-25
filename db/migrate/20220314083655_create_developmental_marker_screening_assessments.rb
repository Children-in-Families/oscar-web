class CreateDevelopmentalMarkerScreeningAssessments < ActiveRecord::Migration[5.2]
  def change
    create_table :developmental_marker_screening_assessments do |t|
      t.integer :developmental_marker_id
      t.integer :screening_assessment_id
      t.boolean :question_1, default: true
      t.boolean :question_2, default: true
      t.boolean :question_3, default: true
      t.boolean :question_4, default: true
    end
    add_index :developmental_marker_screening_assessments, :developmental_marker_id, name: 'index_marker_screening_assessments_on_marker_id'
    add_index :developmental_marker_screening_assessments, :screening_assessment_id, name: 'index_marker_screening_assessments_on_screening_assessment_id'
  end
end
