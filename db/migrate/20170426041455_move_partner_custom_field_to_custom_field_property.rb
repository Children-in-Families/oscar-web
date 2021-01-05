class MovePartnerCustomFieldToCustomFieldProperty < ActiveRecord::Migration[5.2]
  def change
    # unused table
    drop_table :partner_custom_fields
  end
end
