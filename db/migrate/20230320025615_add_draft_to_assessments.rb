class AddDraftToAssessments < ActiveRecord::Migration
  def change
    add_column :assessments, :draft, :boolean, default: false, nil: false
  end
end
