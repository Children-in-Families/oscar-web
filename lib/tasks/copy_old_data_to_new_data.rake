namespace :copy_field_data do
  desc 'Copy name_of_referee, referral_phone, live_with,telephone_number to name, phone on table carer and referee'
  task copy: :environment do
    Organization.where.not(short_name: 'shared').each do |org|
      Organization.switch_to org.short_name
      puts "#{org.short_name} Starting..."
      Client.all.each do |client|
        next if (client.referee_id && client.carer_id)
        if client.referee_id.nil? && (client.name_of_referee.present? || client.referral_phone.present?)
          create_referee = Referee.new
          create_referee.name = client.name_of_referee
          create_referee.phone = client.referral_phone
          create_referee.save(validate:false)
          client.referee_id = create_referee.id
        end
        if client.carer_id.nil? && (client.live_with.present? || client.telephone_number.present?)
          create_carer = Carer.new
          create_carer.name = client.live_with
          create_carer.phone = client.telephone_number
          create_carer.save()
          client.carer_id = create_carer.id
        end
        client.save(validate:false) if (client.carer_id_changed? || client.referee_id_changed?)
      end
      Referee.where("name = '' OR name ILIKE '%unknow%' OR name ILIKE '%unknown%' OR name ILIKE '%Unknown%' OR name ILIKE '%N/A%' OR name ILIKE '%Animus&'").update_all(name: 'Anonymous', anonymous: true)
    end
  end
end
