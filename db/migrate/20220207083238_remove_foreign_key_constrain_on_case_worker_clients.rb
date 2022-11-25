class RemoveForeignKeyConstrainOnCaseWorkerClients < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL.squish
      ALTER TABLE case_worker_clients
      DROP CONSTRAINT IF EXISTS fk_rails_00af3c21f4;

      ALTER TABLE case_worker_clients
      DROP CONSTRAINT IF EXISTS fk_rails_6e8da82196;
    SQL
  end
end
