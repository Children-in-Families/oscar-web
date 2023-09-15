class AddFieldEnabledHeaderCountToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :enabled_header_count, :boolean, default: false
  end
end
