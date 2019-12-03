class MigrateCurrentFamilyIdToClient < ActiveRecord::Migration
  def up
    # Client.joins(:families).each do |client|
    #   next if client.current_family_id.present?
    #   if client.current_family_id.nil?
    #     if client.family_ids.last.present?
    #       client.current_family_id = client.family_ids.last
    #       client.save(validate: false)
    #     else
    #       client.current_family_id = client.family.id
    #       client.save(validate: false)
    #     end
    #   elsif client.family
    #     client.current_family_id = client.family.id
    #     client.save(validate: false)
    #   else
    #     next
    #   end
    #   puts "Client: #{client.slug}"
    # end
  end

  def down
    execute <<-SQL.squish
      UPDATE clients SET current_family_id = NULL WHERE current_family_id IS NOT NULL;
    SQL
  end
end
