class AddTimestampsToSetting < ActiveRecord::Migration
  def change
    add_timestamps :settings, null: true
  end
end
