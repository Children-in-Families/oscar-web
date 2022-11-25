class IndexForeignKeysInClients < ActiveRecord::Migration[5.2]
  def change
    add_index :clients, :birth_province_id
    add_index :clients, :carer_id
    add_index :clients, :concern_commune_id
    add_index :clients, :concern_district_id
    add_index :clients, :concern_province_id
    add_index :clients, :concern_village_id
    add_index :clients, :external_case_worker_id
    add_index :clients, :followed_up_by_id
    add_index :clients, :kid_id
    add_index :clients, :legacy_brcs_id
    add_index :clients, :national_id
    add_index :clients, :presented_id
    add_index :clients, :province_id
    add_index :clients, :received_by_id
    add_index :clients, :referee_id
    add_index :clients, :referral_source_category_id
    add_index :clients, :referral_source_id
    add_index :clients, :user_id
  end
end
