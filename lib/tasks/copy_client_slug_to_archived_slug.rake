namespace :client_archived_slug do
  desc 'copy client slug to archived_slug'
  task copy: :environment do |task, args|
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      next if org.short_name == 'shared'
      Client.all.each do |client|
        random_char = ('a'..'z').to_a.sample(3).join()

        if client.archived_slug.present?
          client.slug = "#{random_char}-#{client.id}"
        else
          client.archived_slug = client.slug
          client.slug = "#{random_char}-#{client.id}"
        end
        client.save(validate: false)

        referrals = client.referrals
        if referrals.present?
          referrals.each do |referral|
            next if referral.referred_from == org.short_name
            Organization.switch_to referral.referred_from
            client_slug = Client.find_by(archived_slug: referral.slug).slug
            Organization.switch_to org.short_name
            client = referral.client
            client.slug = client_slug
            client.save(validate: false)
          end
        end
      end
    end
  end
end
