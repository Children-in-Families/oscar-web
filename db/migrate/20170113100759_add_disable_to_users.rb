class AddDisableToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :disable, :boolean, default: false
  end
end
