class IndexForeignKeysInCaseNoteDomainGroups < ActiveRecord::Migration
  def change
    add_index :case_note_domain_groups, :case_note_id
    add_index :case_note_domain_groups, :domain_group_id
  end
end
