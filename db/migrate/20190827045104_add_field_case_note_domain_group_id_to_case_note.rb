class AddFieldCaseNoteDomainGroupIdToCaseNote < ActiveRecord::Migration[5.2]
  def change
    add_column :case_notes, :selected_domain_group_ids, :string, array: true, default: [] if !column_exists? :case_notes, :selected_domain_group_ids
  end
end
