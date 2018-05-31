class AddFieldRecieveReferralToUser < ActiveRecord::Migration
  def up
    add_column :users, :recieve_referral, :boolean, default: false
    User.admins.update_all(recieve_referral: true)
  end

  def down
    remove_column :users, :recieve_referral, :boolean
  end
end
