namespace :client_current_family do
  desc "Remove current_family_id from client if family is not found"
  task remove: :environment do
    Organization.where.not(short_name: 'shared').pluck(:short_name).map do |short_name|
      sql     = "UPDATE #{short_name}.clients SET current_family_id = NULL where #{short_name}.clients.current_family_id IN ((SELECT #{short_name}.clients.current_family_id FROM #{short_name}.clients LEFT OUTER JOIN #{short_name}.families ON #{short_name}.families.id = #{short_name}.clients.current_family_id WHERE #{short_name}.families.id IS NULL AND #{short_name}.clients.current_family_id IS NOT NULL))"
      results = ActiveRecord::Base.connection.execute(sql)
      puts "#{short_name}: #{results.cmd_status}"
    end
  end

end
