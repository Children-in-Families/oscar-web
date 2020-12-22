class AddTimestampsToSetting < ActiveRecord::Migration[5.2]
  def change
    add_timestamps :settings, null: true
  end
end
