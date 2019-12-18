namespace :copy_field_data do
  desc 'Copy name_of_referee, referral_phone, live_with,telephone_number to name, phone on table carer and referee'
  task copy: :environment do
    Organization.where.not(short_name: 'shared').each do |org|
      Organization.switch_to org.short_name
      Client.all.each do |client|
        create_referee = Referee.new
        create_referee.name = client.name_of_referee
        create_referee.phone = client.referral_phone
        create_referee.save(validate:false)

        create_carer = Carer.new
        create_carer.name = client.live_with
        create_carer.phone = client.telephone_number
        create_carer.save(validate:false)

        client.referee_id = create_referee.id
        client.carer_id = create_carer.id
        client.save(validate:false)
      end
    end
  end
end
