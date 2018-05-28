class AddConsentFormToReferral < ActiveRecord::Migration
  def change
    add_column :referrals, :consent_form, :string
  end
end
