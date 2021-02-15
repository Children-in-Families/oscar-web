class AddHideCommunityToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :hide_community, :boolean, default: true, null: false
  end
end
