class CreateReferrals < ActiveRecord::Migration
  def change
    create_table :referrals do |t|
      t.string :slug, default: ''
      t.date :date_of_referral
      t.string :referred_to, default: ''
      t.string :referred_from, default: ''
      t.text :referral_reason, default: ''
      t.string :name_of_referee, default: ''
      t.string :referral_phone, default: ''
      t.integer :referee_id
      t.string :client_name, default: ''
      t.string :consent_form
      t.boolean :saved, default: false
      t.references :client, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
