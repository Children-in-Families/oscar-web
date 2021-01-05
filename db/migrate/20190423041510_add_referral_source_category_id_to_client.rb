class AddReferralSourceCategoryIdToClient < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :referral_source_category_id, :integer
  end
end
