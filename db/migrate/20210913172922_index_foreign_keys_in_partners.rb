class IndexForeignKeysInPartners < ActiveRecord::Migration
  def change
    add_index :partners, :province_id
  end
end
