class CreateSharedClients < ActiveRecord::Migration
  def change
    create_table :shared_clients do |t|
      t.references :client, index: true, foreign_key: 'slug'
      t.string :fields, array: true, default: []
      t.date :date_of_referral
      t.string :referred_to
      t.string :referred_from
      t.string :origin_ngo
      t.string :referral_reason
      t.string :name_of_referee
      t.string :referral_phone

      t.timestamps null: false
    end
  end
end
