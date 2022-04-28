class AddIndexByNameGroupToFieldSettings < ActiveRecord::Migration
  def change
    add_index :field_settings, [:name, :group], using: :btree
  end
end
