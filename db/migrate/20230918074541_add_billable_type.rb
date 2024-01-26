class AddBillableType < ActiveRecord::Migration
  def change
    add_column :billable_report_items, :billable_type, :string
  end
end
