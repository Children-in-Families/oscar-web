class CreateBillableReportItems < ActiveRecord::Migration
  def change
    create_table :billable_report_items do |t|
      t.references :billable_report, index: true, foreign_key: true
      t.integer :version_id, null: false, index: true
      t.string :billable_status, null: false
      t.datetime :billable_at
      t.datetime :accepted_at

      t.timestamps null: false
    end
  end
end
