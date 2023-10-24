class AddFieldEnabledHeaderCountToSettings1 < ActiveRecord::Migration
  def change
    add_column :settings, :enabled_header_count, :boolean, default: false unless column_exists?(:settings, :enabled_header_count)
  end
end
