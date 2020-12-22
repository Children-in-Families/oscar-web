class MoveFamilyCustomFieldToCustomFieldProperty < ActiveRecord::Migration[5.2]
  def change
    # unused table
    drop_table :family_custom_fields
  end
end
