class CreateFamilyReferrals < ActiveRecord::Migration
  def change
    create_table :family_referrals do |t|
      t.string :slug, default: ''
      t.date :date_of_referral
      t.string :referred_to, default: ''
      t.string :referred_from, default: ''
      t.text :referral_reason, default: ''
      t.string :name_of_referee, default: ''
      t.string :referral_phone, default: ''
      t.string :name_of_family, default: ''
      t.string :ngo_name, default: ''
      t.integer :referee_id
      t.boolean :saved, default: false
      t.string :consent_form, array: true, default: []
      t.references :family, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
