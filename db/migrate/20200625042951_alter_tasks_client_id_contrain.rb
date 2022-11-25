class AlterTasksClientIdContrain < ActiveRecord::Migration[5.2]
  def up
    if index_exists?(:tasks, :client_id, name: "index_tasks_on_client_id")
      execute <<-SQL.squish
        ALTER TABLE tasks DROP CONSTRAINT IF EXISTS fk_rails_d3fa40fd45, ADD CONSTRAINT fk_rails_d3fa40fd45 FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE SET NULL;
      SQL
    end
  end

  def down
    if index_exists?(:tasks, :client_id, name: "index_tasks_on_client_id")
      execute <<-SQL.squish
        ALTER TABLE tasks DROP CONSTRAINT IF EXISTS fk_rails_d3fa40fd45, ADD CONSTRAINT fk_rails_d3fa40fd45 FOREIGN KEY (client_id) REFERENCES clients(id);
      SQL
    end
  end
end
