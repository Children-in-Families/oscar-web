class AddFieldAssessmentDateToAssessments < ActiveRecord::Migration
  def change
    add_column :assessments, :assessment_date, :date
    add_index :assessments, :assessment_date
    reversible do |dir|
      dir.up do
        execute <<-SQL.squish
          UPDATE assessments SET assessment_date = created_at;
        SQL
      end
    end
  end
end
