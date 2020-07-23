class AddFielToUsers < ActiveRecord::Migration
  def change
    add_column :users, :from_ngo, :string
  end
end
