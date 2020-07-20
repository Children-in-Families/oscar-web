class AddUseScreeningAssessmentToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :use_screening_assessment, :boolean, default: false
    add_column :settings, :screening_assessment_form_id, :integer
  end
end
