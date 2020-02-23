class ChangeRequiredToBeBooleanInMetaFields < ActiveRecord::Migration
  def change
    change_column :meta_fields, :required, 'boolean USING CAST(required AS boolean)', default: false
  end
end
