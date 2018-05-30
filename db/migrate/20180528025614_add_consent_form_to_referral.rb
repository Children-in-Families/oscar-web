class AddConsentFormToReferral < ActiveRecord::Migration
  def change
    add_column :referrals, :consent_forms, :string, array: true, default: []
  end
end
