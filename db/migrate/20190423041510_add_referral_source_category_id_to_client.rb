class AddReferralSourceCategoryIdToClient < ActiveRecord::Migration
  def change
    add_column :organizations, :referral_source_category_id, :integer
  end
end
