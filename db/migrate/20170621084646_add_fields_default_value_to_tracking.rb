class AddFieldsDefaultValueToTracking < ActiveRecord::Migration
  def change
    change_column :trackings, :fields, :jsonb, default: {}
  end
end
