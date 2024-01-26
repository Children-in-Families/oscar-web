class RemoveForeignKeyFromUsageReport < ActiveRecord::Migration
  def change
    remove_foreign_key :usage_reports, :organizations
  end
end
