class IndexForeignKeysInTasks < ActiveRecord::Migration[5.2]
  def change
    add_index :tasks, :case_note_domain_group_id unless index_exists? :tasks, :case_note_domain_group_id
    add_index :tasks, :case_note_id unless index_exists? :tasks, :case_note_id
    add_index :tasks, :domain_id unless index_exists? :tasks, :domain_id
    add_index :tasks, :user_id unless index_exists? :tasks, :user_id
  end
end
