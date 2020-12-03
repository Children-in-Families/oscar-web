namespace :client_archived_slug do
  desc 'copy client slug to archived_slug'
  task :copy, [:short_name]  => :environment do |task, args|
    short_name = args.short_name
    Organization.switch_to short_name
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
          slug = referral.slug
          next if referral.referred_from == short_name || !referral.referred_from.in?(Organization.pluck(:short_name))
          Organization.switch_to referral.referred_from
          begin
            client_slug = Client.find_by(archived_slug: slug).slug
          rescue Exception => e
            puts "not found client with  slug: #{slug}"
          ensure
            client_slug = slug
          end
          Organization.switch_to short_name
          client = referral.client
          client.slug = client_slug
          client.save(validate: false)
        end
      end
    end
  end
end
