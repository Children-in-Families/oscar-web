class AddStatusToCommunities < ActiveRecord::Migration
  def change
    change_column :communities, :status, :string, null: false, default: 'accepted'
  end
end
