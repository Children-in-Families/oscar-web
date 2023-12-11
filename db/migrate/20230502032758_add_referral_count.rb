class AddReferralCount < ActiveRecord::Migration
  def change
    add_column :clients, :referral_count, :integer, default: 0
  end
end
