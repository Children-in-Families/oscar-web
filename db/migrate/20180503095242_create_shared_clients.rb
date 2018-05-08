class CreateSharedClients < ActiveRecord::Migration
  def change
    create_table :shared_clients do |t|
      t.references :client, index: true, foreign_key: 'slug'
      t.string :fields, array: true, default: []
      t.string :destination_ngo
      t.string :origin_ngo
      t.string :referral_reason

      t.timestamps null: false
    end
  end
end
