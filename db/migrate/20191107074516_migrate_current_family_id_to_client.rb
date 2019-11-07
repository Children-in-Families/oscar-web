class MigrateCurrentFamilyIdToClient < ActiveRecord::Migration
  def up
    Client.joins(:families).each do |client|
      if client.current_family_id.nil?
        if client.family_ids.last.present?
          client.current_family_id = client.family_ids.last
          client.save
        end
      elsif client.family
        client.current_family_id = client.family.id
        client.save
      else
        next
      end
    end
  end
end
