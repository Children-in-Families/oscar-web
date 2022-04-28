class RemoveClientIdConstrainFromSponsors < ActiveRecord::Migration
  def up
    if index_exists?(:sponsors, :client_id, name: "index_sponsors_on_client_id")
      execute <<-SQL.squish
        ALTER TABLE sponsors DROP CONSTRAINT IF EXISTS fk_rails_59b0121f34, ADD CONSTRAINT fk_rails_59b0121f34 FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE SET NULL;
      SQL
    end
  end

  def down
    if index_exists?(:sponsors, :client_id, name: "index_sponsors_on_client_id")
      execute <<-SQL.squish
        ALTER TABLE sponsors DROP CONSTRAINT IF EXISTS fk_rails_59b0121f34, ADD CONSTRAINT fk_rails_59b0121f34 FOREIGN KEY (client_id) REFERENCES clients(id);
      SQL
    end
  end
end
