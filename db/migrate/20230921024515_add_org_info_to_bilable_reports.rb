class AddOrgInfoToBilableReports < ActiveRecord::Migration
  def change
    add_column :billable_reports, :organization_name, :string
    add_column :billable_reports, :organization_short_name, :string

    reversible do |dir|
      dir.up do
        BillableReport.find_each(&:touch)
      end
    end
  end
end
