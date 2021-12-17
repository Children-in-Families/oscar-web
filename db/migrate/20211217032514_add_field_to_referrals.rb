class AddFieldToReferrals < ActiveRecord::Migration
  def change
    add_column :referrals, :client_status, :string, default: 'Referred'
  end
end
