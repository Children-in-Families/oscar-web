class AddHideCommunityToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :hide_community, :boolean, default: true, null: false
  end
end
