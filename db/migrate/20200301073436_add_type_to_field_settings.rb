class AddTypeToFieldSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :field_settings, :type, :string, default: :field, null: false
  end
end
