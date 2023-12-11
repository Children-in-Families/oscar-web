class AddBillableReportIdToPaperTrailVersions < ActiveRecord::Migration
  def change
    add_column :versions, :billable_report_id, :integer
    add_column :versions, :billable_status, :string
    add_column :versions, :accepted_at, :datetime
    add_column :versions, :billable_at, :datetime
  end
end
