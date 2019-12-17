namespace :copy_field_data do
  desc 'Copy name_of_referee, referral_phone, live_with,telephone_number to name, phone on table carer and referee'
  task copy: :environment do
    Organization.where.not(short_name: 'shared').each do |org|
      Organization.switch_to org.short_name
      Client.where(referee_id: nil).or(Client.where(carer_id: nil)).each do |client|
        create_referee = Referee.new
        create_carer = Carer.new

        if client.name_of_referee.present?
          create_referee.name = client.name_of_referee
          create_referee.save
        elsif client.referral_phone.present?
          create_referee.phone = client.referral_phone
          create_referee.save
        end

        if client.live_with.present?
          create_carer.name = client.live_with
          create_carer.save
        elsif client.telephone_number.present?
          create_carer.phone = client.telephone_number
          create_carer.save
        end

        client.referee_id = create_referee.id
        client.carer_id = create_carer.id
        client.save(validate:false)
      end
    end
  end
end
