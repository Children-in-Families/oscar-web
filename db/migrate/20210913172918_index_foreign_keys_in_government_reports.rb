class IndexForeignKeysInGovernmentReports < ActiveRecord::Migration[5.2]
  def change
    add_index :government_reports, :client_id unless index_exists? :government_reports, :client_id
  end
end
