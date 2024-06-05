class AlterClientFkInCaseNotes < ActiveRecord::Migration
  def up
    schema = schema_search_path.split(',').first.gsub(/\"/, '')
    execute <<-SQL.squish
      ALTER TABLE #{schema}."case_notes" DROP CONSTRAINT IF EXISTS "fk_rails_a48f1643b7",
      ADD CONSTRAINT "fk_rails_a48f1643b7" FOREIGN KEY ("client_id") REFERENCES #{schema}."clients"(id) ON DELETE CASCADE;
    SQL
  end

  def down
  end
end
