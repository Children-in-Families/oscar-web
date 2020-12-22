class MigrateCurrentFamilyIdToClient < ActiveRecord::Migration[5.2]
  def up
    values = Client.joins('INNER JOIN cases ON cases.client_id = clients.id INNER JOIN families ON families.id = cases.family_id').distinct.select('clients.id, (SELECT cases.family_id FROM cases WHERE cases.client_id = clients.id ORDER BY cases.created_at DESC LIMIT 1) ORDER BY cases.created_at DESC LIMIT 1) as family_id').pluck(:id, :family_id).to_h.map do |id, family_id|
      "(#{id}, #{family_id || 'NULL'})"
    end.join(", ")
    ActiveRecord::Base.connection.execute("UPDATE clients SET current_family_id = mapping_values.family_id FROM (VALUES #{values}) AS mapping_values (client_id, family_id) WHERE clients.id = mapping_values.client_id") if values.present?
  end

  def down
    execute <<-SQL.squish
      UPDATE clients SET current_family_id = NULL WHERE current_family_id IS NOT NULL;
    SQL
  end
end
