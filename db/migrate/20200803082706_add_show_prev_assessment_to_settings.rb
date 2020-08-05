class AddShowPrevAssessmentToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :show_prev_assessment, :boolean, default: false
  end
end
