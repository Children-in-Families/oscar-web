namespace :user_family do
  desc "Remove user from families that have no clients belong ot the user"
  task clean: :environment do
    Organization.where.not(short_name: 'shared').each do |org|
      next unless org.short_name == 'cfi'
      Organization.switch_to org.short_name
      Family.joins(:user).each do |family|
        clients = Client.joins(:users).where(current_family_id: family.id, case_worker_clients: {user_id: family.user_id})
        if clients.blank?
          family.user_id = nil
          family.save
          puts "#{org.short_name}: #{family.name}"
        end
      end
    end
  end

end
