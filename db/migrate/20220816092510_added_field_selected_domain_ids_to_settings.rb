class AddedFieldSelectedDomainIdsToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :selected_domain_ids , :integer, array: true, default: []
  end
end
