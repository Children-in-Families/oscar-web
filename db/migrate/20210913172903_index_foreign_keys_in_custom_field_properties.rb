class IndexForeignKeysInCustomFieldProperties < ActiveRecord::Migration
  def change
    add_index :custom_field_properties, :custom_formable_id
    add_index :custom_field_properties, :user_id
  end
end
