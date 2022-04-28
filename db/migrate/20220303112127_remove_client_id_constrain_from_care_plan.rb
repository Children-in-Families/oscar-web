class RemoveClientIdConstrainFromCarePlan < ActiveRecord::Migration
  def up
    if index_exists?(:care_plans, :client_id, name: "index_care_plans_on_client_id")
      execute <<-SQL.squish
        ALTER TABLE care_plans DROP CONSTRAINT IF EXISTS fk_rails_0b8798bddb, ADD CONSTRAINT fk_rails_0b8798bddb FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE SET NULL;
      SQL
    end
  end

  def down
    if index_exists?(:care_plans, :client_id, name: "index_care_plans_on_client_id")
      execute <<-SQL.squish
        ALTER TABLE care_plans DROP CONSTRAINT IF EXISTS fk_rails_0b8798bddb, ADD CONSTRAINT fk_rails_0b8798bddb FOREIGN KEY (client_id) REFERENCES clients(id);
      SQL
    end
  end
end
