class AddFieldCommunityDefaultColumnsToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :community_default_columns, :string, array: true, default: []
  end
end
