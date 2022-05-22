class RemoveClientIdConstrainFromAssessments < ActiveRecord::Migration
  def up
    if index_exists?(:assessments, :client_id, name: "index_assessments_on_client_id")
      execute <<-SQL.squish
        ALTER TABLE assessments DROP CONSTRAINT IF EXISTS fk_rails_119fabaaf8, ADD CONSTRAINT fk_rails_119fabaaf8 FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE SET NULL;
      SQL
    end
  end

  def down
    if index_exists?(:assessments, :client_id, name: "index_assessments_on_client_id")
      execute <<-SQL.squish
        ALTER TABLE assessments DROP CONSTRAINT IF EXISTS fk_rails_119fabaaf8, ADD CONSTRAINT fk_rails_119fabaaf8 FOREIGN KEY (client_id) REFERENCES clients(id);
      SQL
    end
  end
end
