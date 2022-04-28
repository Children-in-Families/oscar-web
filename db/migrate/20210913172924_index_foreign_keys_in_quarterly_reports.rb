class IndexForeignKeysInQuarterlyReports < ActiveRecord::Migration
  def change
    add_index :quarterly_reports, :staff_id
  end
end
