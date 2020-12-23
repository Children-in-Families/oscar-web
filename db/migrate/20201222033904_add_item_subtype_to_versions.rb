class AddItemSubtypeToVersions < ActiveRecord::Migration[5.2]
  def change
    add_column :versions, :item_subtype, :string, null: true
  end
end
