class RemoveFieldServicesFromReferrals < ActiveRecord::Migration
  def change
    remove_column :referrals, :services, :string
  end
end
