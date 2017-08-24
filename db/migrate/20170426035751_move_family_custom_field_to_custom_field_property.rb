class MoveFamilyCustomFieldToCustomFieldProperty < ActiveRecord::Migration
  def change
    # unused table
    drop_table :family_custom_fields
  end
end
