class AddFieldLevelOfRiskToReferrals < ActiveRecord::Migration
  def change
    add_column :referrals, :level_of_risk, :string
  end
end
