class CreateReferralsServices < ActiveRecord::Migration[5.2]
  def change
    create_table :referrals_services, id: false do |t|
      t.belongs_to :referral
      t.belongs_to :service
    end
  end
end
