class IndexForeignKeysInQuarterlyReports < ActiveRecord::Migration[5.2]
  def change
    add_index :quarterly_reports, :staff_id
  end
end
