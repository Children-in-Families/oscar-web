class AddFamilyIdToAssessments < ActiveRecord::Migration[5.2]
  def change
    add_column :assessments, :family_id, :integer
    add_index :assessments, :family_id
  end
end
