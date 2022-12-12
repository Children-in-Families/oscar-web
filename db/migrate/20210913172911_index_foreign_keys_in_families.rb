class IndexForeignKeysInFamilies < ActiveRecord::Migration[5.2]
  def change
    add_index :families, :followed_up_by_id unless index_exists? :families, :followed_up_by_id
    add_index :families, :province_id unless index_exists? :families, :province_id
    add_index :families, :received_by_id unless index_exists? :families, :received_by_id
    add_index :families, :referral_source_category_id unless index_exists? :families, :referral_source_category_id
    add_index :families, :referral_source_id unless index_exists? :families, :referral_source_id
  end
end
