class AddFieldsDefaultValueToTracking < ActiveRecord::Migration
  def up
    add_column :trackings, :fields, :jsonb, default: {}
  end

  def down
    remove_column :trackings, :fields, :jsonb
  end
end
