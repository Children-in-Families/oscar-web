class AddReferralSourceCategoryIdToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :referral_source_category_name, :string
  end
end
