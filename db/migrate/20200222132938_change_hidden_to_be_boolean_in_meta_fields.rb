class ChangeHiddenToBeBooleanInMetaFields < ActiveRecord::Migration
  def change
    change_column :meta_fields, :hidden, 'boolean USING CAST(hidden AS boolean)', default: true
  end
end
