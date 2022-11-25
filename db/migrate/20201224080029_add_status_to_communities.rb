class AddStatusToCommunities < ActiveRecord::Migration[5.2]
  def change
    change_column :communities, :status, :string, null: false, default: 'accepted'
  end
end
