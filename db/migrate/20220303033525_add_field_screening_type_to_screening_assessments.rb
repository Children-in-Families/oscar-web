class AddFieldScreeningTypeToScreeningAssessments < ActiveRecord::Migration[5.2]
  def change
    add_column :screening_assessments, :screening_type, :string, default: 'multiple'
    add_index :screening_assessments, :screening_type
  end
end
