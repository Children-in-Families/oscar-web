namespace 'archived_slug' do
  desc 'update archived slug'
  task update: :environment do
    Organization.all.each do |org|
      next if org.short_name == 'shared'
      next if org.short_name == 'fsc'
      Organization.switch_to org.short_name
      Client.skip_callback(:save, :after, :mark_referral_as_saved)
      Client.find_each do |client|
        old_archived_slug = client.archived_slug
        new_archived_slug = ''
        if client.referrals.present?
          short_name = client.referrals.first.try(:referred_from)
          new_archived_slug = "#{short_name}-#{client.archived_slug.split('-').last}"
        else
          new_archived_slug = "#{org.short_name}-#{client.archived_slug.split('-').last}"
        end
        client.archived_slug = new_archived_slug

        client.save(validate: false)
        puts "save client #{client.archived_slug}"
      end
    end
  end
end
