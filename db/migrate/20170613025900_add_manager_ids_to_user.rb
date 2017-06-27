class AddManagerIdsToUser < ActiveRecord::Migration
  def change
    add_column :users, :manager_ids, :integer, array: true, default: []
  end
end
