class CreateBillableReports < ActiveRecord::Migration
  def change
    create_table :billable_reports do |t|
      t.references :organization, index: true, foreign_key: true
      t.integer :year
      t.integer :month

      t.timestamps null: false
    end
  end
end
