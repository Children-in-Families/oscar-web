class MoveClientCustomFieldToCustomFieldProperty < ActiveRecord::Migration
  def change
    # unused table
    drop_table :client_custom_fields
  end
end
