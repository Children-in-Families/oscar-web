class AddFieldCompletedDateToAssessments < ActiveRecord::Migration
  def change
    add_column :assessments, :completed_date, :date
    add_index :assessments, :completed_date
    reversible do |dir|
      dir.up do
        execute "UPDATE assessments SET completed_date = DATE(created_at);"
      end
    end
  end
end
