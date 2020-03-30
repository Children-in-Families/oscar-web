class AddLegacyBrcsIdToClients < ActiveRecord::Migration
  def change
    remove_column :field_settings, :legacy_brcs_id, :string
    add_column :clients, :legacy_brcs_id, :string
  end
end
