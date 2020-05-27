class AddTypeToFieldSettings < ActiveRecord::Migration
  def change
    add_column :field_settings, :type, :string, default: :field, null: false
  end
end
