class AddReferredCountToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :referred_count, :integer, default: 0
    add_column :organizations, :exited_client, :integer, default: 0
  end
end
