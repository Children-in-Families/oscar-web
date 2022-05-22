class RemoveClientIdConstrainFromGoal < ActiveRecord::Migration
  def up
    if index_exists?(:goals, :client_id, name: "index_goals_on_client_id")
      execute <<-SQL.squish
        ALTER TABLE goals DROP CONSTRAINT IF EXISTS fk_rails_0b294b3ff3, ADD CONSTRAINT fk_rails_0b294b3ff3 FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE SET NULL;
      SQL
    end
  end

  def down
    if index_exists?(:goals, :client_id, name: "index_goals_on_client_id")
      execute <<-SQL.squish
        ALTER TABLE goals DROP CONSTRAINT IF EXISTS fk_rails_0b294b3ff3, ADD CONSTRAINT fk_rails_0b294b3ff3 FOREIGN KEY (client_id) REFERENCES clients(id);
      SQL
    end
  end
end
