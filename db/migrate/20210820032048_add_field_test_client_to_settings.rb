class AddFieldTestClientToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :test_client, :boolean, default: false
  end
end
