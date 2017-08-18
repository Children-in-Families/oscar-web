class AddFieldsDefaultValueToTracking < ActiveRecord::Migration
  def up
    change_column :trackings, :fields, :jsonb, default: {}
  end

  def down
    change_column :trackings, :fields, :jsonb
  end
end
