class ReindexUsersByEmailAndCreatedFrom < ActiveRecord::Migration
  def up
    remove_index :users, :email
    add_index :users, [:email, :created_from], :unique => true
  end
  
  def down
    remove_index :users, [:email, :created_from]
    add_index :users, :email, :unique => true
  end
end
