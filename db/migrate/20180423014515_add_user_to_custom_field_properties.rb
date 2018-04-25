class AddUserToCustomFieldProperties < ActiveRecord::Migration
  def change
    add_column :custom_field_properties, :user_id, :integer
  end
end
