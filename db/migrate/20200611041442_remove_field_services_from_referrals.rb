class RemoveFieldServicesFromReferrals < ActiveRecord::Migration[5.2]
  def change
    remove_column :referrals, :services, :string
  end
end
