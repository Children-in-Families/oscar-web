class AddFieldsToReferrals < ActiveRecord::Migration[5.2]
  def change
    add_column :referrals, :client_gender, :string, default: ""
    add_column :referrals, :client_date_of_birth, :date
    add_column :referrals, :village_code, :string, default: ""
  end
end
