class AddFieldFromReferralId < ActiveRecord::Migration
  def change
    add_column :clients, :from_referral_id, :string
  end
end
