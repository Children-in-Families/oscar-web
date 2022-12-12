class IndexForeignKeysInCustomFieldProperties < ActiveRecord::Migration[5.2]
  def change
    add_index :custom_field_properties, :custom_formable_id unless index_exists? :custom_field_properties, :custom_formable_id
    add_index :custom_field_properties, :user_id unless index_exists? :custom_field_properties, :user_id
  end
end
