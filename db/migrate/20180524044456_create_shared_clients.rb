class CreateSharedClients < ActiveRecord::Migration
  def change
    create_table :shared_clients do |t|
      t.string :slug, default: ''
      t.string :given_name, default: ''
      t.string :family_name, default: ''
      t.string :local_given_name, default: ''
      t.string :local_family_name, default: ''
      t.string :gender, default: ''
      t.date :date_of_birth
      t.string :live_with, default: ''
      t.string :telephone_number, default: ''
      t.integer :birth_province_id

      t.timestamps null: false
    end

    add_index :shared_clients, :slug, unique: true
  end
end
