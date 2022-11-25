class IndexForeignKeysInCommunities < ActiveRecord::Migration[5.2]
  def change
    add_index :communities, :commune_id
    add_index :communities, :district_id
    add_index :communities, :province_id
    add_index :communities, :received_by_id
    add_index :communities, :referral_source_category_id
    add_index :communities, :referral_source_id
    add_index :communities, :user_id
    add_index :communities, :village_id
  end
end
