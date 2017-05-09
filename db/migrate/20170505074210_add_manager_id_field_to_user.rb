class AddManagerIdFieldToUser < ActiveRecord::Migration
  def change
    add_column :users, :manager_id, :integer
  end
end
