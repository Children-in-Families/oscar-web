class MoveUserCustomFieldToCustomFieldProperty < ActiveRecord::Migration[5.2]
  def change
    # unused table
    drop_table :user_custom_fields
  end
end
