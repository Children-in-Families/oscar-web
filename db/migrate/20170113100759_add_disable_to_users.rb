class AddDisableToUsers < ActiveRecord::Migration
  def change
    add_column :users, :disable, :boolean, default: false
  end
end
