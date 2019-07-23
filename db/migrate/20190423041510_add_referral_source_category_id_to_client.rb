class AddReferralSourceCategoryIdToClient < ActiveRecord::Migration
  def change
    add_column :clients, :referral_source_category_id, :integer
  end
end
