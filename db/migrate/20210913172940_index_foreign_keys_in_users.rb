class IndexForeignKeysInUsers < ActiveRecord::Migration[5.2]
  def change
    add_index :users, :department_id
    add_index :users, :manager_id
    add_index :users, :province_id
  end
end
