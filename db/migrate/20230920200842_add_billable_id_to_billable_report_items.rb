class AddBillableIdToBillableReportItems < ActiveRecord::Migration
  def change
    add_column :billable_report_items, :billable_id, :integer
  end
end
