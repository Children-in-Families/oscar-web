class AddRefereeEmailToReferrals < ActiveRecord::Migration
  def change
    add_column :referrals, :referee_email, :string
  end
end
