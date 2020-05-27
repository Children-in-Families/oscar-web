class AddLegacyBrcsIdToFieldSettings < ActiveRecord::Migration
  def change
    add_column :field_settings, :legacy_brcs_id, :string
  end
end
