class CreateInternalReferrals < ActiveRecord::Migration
  def change
    create_table :internal_referrals do |t|
      t.datetime :referral_date
      t.integer :client_id
      t.integer :user_id
      t.text :client_representing_problem
      t.text :emergency_note
      t.text :referral_reason
      t.text :referral_decision
      t.string :attachments, default: [], array: true

      t.timestamps null: false
    end
    add_index :internal_referrals, :referral_date
    add_index :internal_referrals, :client_id
    add_index :internal_referrals, :user_id
  end
end
