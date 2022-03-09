class AddFieldScreeningTypeToScreeningAssessments < ActiveRecord::Migration
  def change
    add_column :screening_assessments, :screening_type, :string, default: 'multiple'
    add_index :screening_assessments, :screening_type
  end
end
