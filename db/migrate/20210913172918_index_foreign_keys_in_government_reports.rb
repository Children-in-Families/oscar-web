class IndexForeignKeysInGovernmentReports < ActiveRecord::Migration
  def change
    add_index :government_reports, :client_id
  end
end
