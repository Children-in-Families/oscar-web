class AddFieldCaseNoteDomainGroupIdToCaseNote < ActiveRecord::Migration
  def change
    add_column :case_notes, :selected_domain_group_ids, :string, array: true, default: []
  end
end
