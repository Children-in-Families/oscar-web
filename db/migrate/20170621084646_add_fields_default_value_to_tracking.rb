class AddFieldsDefaultValueToTracking < ActiveRecord::Migration[5.2]
  def up
    change_column :trackings, :fields, :jsonb, default: {}
  end

  def down
    change_column :trackings, :fields, :jsonb
  end
end
