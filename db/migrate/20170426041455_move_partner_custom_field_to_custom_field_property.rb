class MovePartnerCustomFieldToCustomFieldProperty < ActiveRecord::Migration
  def change
    # unused table
    drop_table :partner_custom_fields
  end
end
