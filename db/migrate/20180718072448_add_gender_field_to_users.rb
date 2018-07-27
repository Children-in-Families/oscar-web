class AddGenderFieldToUsers < ActiveRecord::Migration
  def change
    add_column :users, :gender, :string, default: ''
  end
end
