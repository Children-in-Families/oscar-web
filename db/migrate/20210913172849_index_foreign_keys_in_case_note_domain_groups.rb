class IndexForeignKeysInCaseNoteDomainGroups < ActiveRecord::Migration[5.2]
  def change
    add_index :case_note_domain_groups, :case_note_id unless index_exists? :case_note_domain_groups, :case_note_id
    add_index :case_note_domain_groups, :domain_group_id unless index_exists? :case_note_domain_groups, :domain_group_id
  end
end
