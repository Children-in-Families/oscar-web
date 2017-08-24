class MoveUserCustomFieldToCustomFieldProperty < ActiveRecord::Migration
  def change
    # unused table
    drop_table :user_custom_fields
  end
end
