class IndexForeignKeysInFamilies < ActiveRecord::Migration
  def change
    add_index :families, :followed_up_by_id
    add_index :families, :province_id
    add_index :families, :received_by_id
    add_index :families, :referral_source_category_id
    add_index :families, :referral_source_id
  end
end
