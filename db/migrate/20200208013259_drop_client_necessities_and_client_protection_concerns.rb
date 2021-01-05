class DropClientNecessitiesAndClientProtectionConcerns < ActiveRecord::Migration[5.2]
  def change
    drop_table :client_necessities do |t|
      t.references :client, index: true, foreign_key: true
      t.references :necessity, index: true, foreign_key: true

      t.timestamps null: false
    end

    drop_table :client_protection_concerns do |t|
      t.references :client, index: true, foreign_key: true
      t.references :protection_concern, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
