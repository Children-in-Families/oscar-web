class IndexForeignKeysInDonorFamilies < ActiveRecord::Migration
  def change
    add_index :donor_families, :donor_id
    add_index :donor_families, :family_id
  end
end
