class AddFieldTestClientToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :test_client, :boolean, default: false
  end
end
