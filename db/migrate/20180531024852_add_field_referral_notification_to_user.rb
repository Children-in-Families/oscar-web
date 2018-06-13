class AddFieldReferralNotificationToUser < ActiveRecord::Migration
  def up
    add_column :users, :referral_notification, :boolean, default: false
    User.admins.update_all(referral_notification: true)
  end

  def down
    remove_column :users, :referral_notification, :boolean
  end
end
