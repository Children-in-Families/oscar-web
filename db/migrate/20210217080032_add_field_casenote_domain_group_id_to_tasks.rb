class AddFieldCasenoteDomainGroupIdToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :casenote_domain_group_id, :string
    add_index :tasks, :casenote_domain_group_id
  end
end
