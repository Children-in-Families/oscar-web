class AddFieldToUser < ActiveRecord::Migration
  def change
    add_column :users, :created_from, :string, default: true
  end
end
