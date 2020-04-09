namespace :client_global_id do
  desc "Migrate global ID for clients in all NGOs"
  task migrate: :environment do
    Organization.where.not(short_name: 'shared').pluck(:short_name).each do |short_name|
      Organization.switch_to short_name
        Referral.all.each do |referral|
          short_name = referral.referred_from
          referral_slug = referral.slug
          Organization.switch_to short_name
          if referral_slug
            client = Client.find(referral_slug[/\d+/])
            if client
              client.global_id = GlobalIdentity.create(ulid: ULID.generate).id
              client.save
              referral.client_global
            end
          end
        end

        Client.all.each do |client|
          if client.global_id.blank?
            client.global_id = GlobalIdentity.create(ulid: ULID.generate).id
            client.save!
          end
        end
      end
    end
  end

end
