class AddLegacyBrcsIdToFieldSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :field_settings, :legacy_brcs_id, :string
  end
end
