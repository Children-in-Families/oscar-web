class AddNameEnToReferralSource < ActiveRecord::Migration
  def change
    add_column :referral_sources, :name_en, :string, default: ''
  end
end
