namespace :client_global_id do
  desc "Migrate global ID for clients in all NGOs"
  task migrate: :environment do
    Organization.where.not(short_name: 'shared').pluck(:short_name).each do |short_name|
      Organization.switch_to short_name
      Referral.received.where(client_global_id: nil).each do |referral|
        referred_from = referral.referred_from
        referral_slug = referral.slug
        client_global_id = nil
        if Organization.find_by(short_name: referred_from || referral.slug.split('-').first).present?
          if referral_slug || referred_from
            begin
              Organization.switch_to(referred_from || referral.slug.split('-').first)
            rescue Apartment::TenantNotFound => e
              puts e
            end
            client = Client.find(referral_slug[/\d+/]) if Client.exists?(referral_slug[/\d+/])
            if client && client.global_id.nil?
              client.global_id = GlobalIdentity.create(ulid: ULID.generate).ulid
              client_global_id = client.global_id
              client.save(validate: false)
            end
          end
          Organization.switch_to short_name
          if referral.saved
            if Client.exists?(referral.client_id)
              client = Client.find(referral.client_id)
              client.global_id = client_global_id || GlobalIdentity.create(ulid: ULID.generate).ulid
              client.save(validate: false)
            end
          end
          next if (client&.global_id || client_global_id).nil?
          referral.update_column(:client_global_id, client&.global_id || client_global_id) if referral.client_global_id.nil?
          puts "Referral: #{referral.client_global_id}"
        end
      end

      Client.where(global_id: nil).each do |client|
        client.global_id = GlobalIdentity.create(ulid: ULID.generate).ulid
        client.save(validate: false)
        puts "Client: #{client.slug}"
      end
    end
  end
end
