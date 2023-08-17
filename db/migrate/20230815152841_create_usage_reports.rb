class CreateUsageReports < ActiveRecord::Migration
  def change
    create_table :usage_reports do |t|
      t.references :organization, index: true, foreign_key: true
      t.integer :month
      t.integer :year

      t.timestamps null: false
    end
  end
end
