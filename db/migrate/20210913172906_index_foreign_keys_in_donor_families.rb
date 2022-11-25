class IndexForeignKeysInDonorFamilies < ActiveRecord::Migration[5.2]
  def change
    add_index :donor_families, :donor_id
    add_index :donor_families, :family_id
  end
end
