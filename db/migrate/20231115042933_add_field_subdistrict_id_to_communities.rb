class AddFieldSubdistrictIdToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :subdistrict_id, :integer
    add_index :communities, :subdistrict_id
  end
end
