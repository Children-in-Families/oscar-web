class RemoveBillableReference < ActiveRecord::Migration
  def change
    remove_foreign_key :billable_reports, :organizations
  end
end
