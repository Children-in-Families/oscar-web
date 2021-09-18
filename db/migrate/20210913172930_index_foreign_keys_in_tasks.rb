class IndexForeignKeysInTasks < ActiveRecord::Migration
  def change
    add_index :tasks, :case_note_domain_group_id
    add_index :tasks, :case_note_id
    add_index :tasks, :domain_id
    add_index :tasks, :user_id
  end
end
