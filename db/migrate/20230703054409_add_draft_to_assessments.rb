class AddDraftToAssessments < ActiveRecord::Migration
  def change
    # check if column exists before adding in case of previously deployed on staging
    add_column :assessments, :draft, :boolean, default: false unless column_exists?(:assessments, :draft)
    add_column :assessments, :last_auto_save_at, :datetime unless column_exists?(:assessments, :last_auto_save_at)
  end
end
