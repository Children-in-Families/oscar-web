class IndexForeignKeysInPartners < ActiveRecord::Migration[5.2]
  def change
    add_index :partners, :province_id unless index_exists? :partners, :province_id
  end
end
