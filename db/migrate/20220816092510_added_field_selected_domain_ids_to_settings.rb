class AddedFieldSelectedDomainIdsToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :selected_domain_ids , :integer, array: true, default: []
  end
end
