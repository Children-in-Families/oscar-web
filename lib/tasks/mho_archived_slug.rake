namespace :mho_archived_slug do
  desc 'fix mho archived slug'
  task fix: :environment do |task, args|
    Organization.switch_to 'mho'
    org = Organization.current
    Client.where(archived_slug: nil).each do |client|
      random_char = ('a'..'z').to_a.sample(3).join()

      client.archived_slug = client.slug
      client.slug = "#{random_char}-#{client.id}"

      client.save(validate: false)

      referrals = client.referrals
      if referrals.present?
        referrals.each do |referral|
          next if referral.referred_from == org.short_name || !referral.referred_from.in?(Organization.pluck(:short_name))
          Organization.switch_to referral.referred_from
          client_slug = Client.find_by(archived_slug: referral.slug).slug || Client.find_by(slug: referral.slug).slug
          Organization.switch_to org.short_name
          client = referral.client
          client.slug = client_slug
          client.save(validate: false)
        end
      end
    end
  end
end
