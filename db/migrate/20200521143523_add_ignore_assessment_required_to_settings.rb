class AddIgnoreAssessmentRequiredToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :disable_required_fields, :boolean, default: false, null: false
  end
end
