class AddFieldCommunityDefaultColumnsToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :community_default_columns, :string, array: true, default: []
  end
end
