class AddGenderFieldToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :gender, :string, default: ''
  end
end
