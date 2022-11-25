class AddManagerIdsToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :manager_ids, :integer, array: true, default: []
  end
end
