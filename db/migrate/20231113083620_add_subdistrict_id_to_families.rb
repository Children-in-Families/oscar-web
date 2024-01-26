class AddSubdistrictIdToFamilies < ActiveRecord::Migration
  def change
    add_column :families, :subdistrict_id, :integer
    add_index :families, :subdistrict_id
  end
end
