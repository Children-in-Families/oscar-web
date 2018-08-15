namespace :update_rated_id_poor do
  desc 'match old rated id poor with the new format'
  task update: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      clients = []
      clients = Client.where('rated_for_id_poor ILIKE ?', '%1%').or(Client.where('rated_for_id_poor ILIKE ?', '%2%')).or(Client.where('rated_for_id_poor ILIKE ?', '%3%'))
      clients.each do |client|
        if client.rated_for_id_poor.squish == '1'
          client.rated_for_id_poor = 'Level 1'
        elsif client.rated_for_id_poor.squish == '2'
          client.rated_for_id_poor = 'Level 2'
        elsif client.rated_for_id_poor.squish == '3'
          client.rated_for_id_poor = 'Level 3'
        end
        client.save(validate: false)
      end
    end
    puts 'Done!!!'
  end
end
