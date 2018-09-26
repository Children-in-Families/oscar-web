namespace :level_3_rated_for_id_poor do
  desc 'remove level 3 of rated_for_id_poor'
  task remove: :environment do
    client_ids_record = File.new("client_ids_record.txt", "w")
    Organization.visible.each do |org|
      Organization.switch_to org.short_name
      client_ids_record.write("======#{org.full_name}======\n")
      Client.where(rated_for_id_poor: 'Level 3').each do |client|
        client_ids_record.write("#{client.slug}, ")
        client.rated_for_id_poor = ''
        client.save(validate: false)
      end
    end
    client_ids_record.close
    puts 'Done!!!'
  end
end
