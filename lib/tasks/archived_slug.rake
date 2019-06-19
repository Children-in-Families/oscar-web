namespace 'archived slug' do
  desc 'update archived slug'
  task update: :environment do
    Organization.all.each do |org|
      next if org.short_name == 'shared'
      Organization.switch_to org.short_name

      Client.find_each do |client|
        old_archived_slug = client.archived_slug
        new_archived_slug = ''

        if client.referrals.present?
          short_name = client.referrals.first.try(:referred_from)
          new_archived_slug = "#{short_name}-#{client.archived_slug.split('-').last}"
        else
          new_archived_slug = "#{org.short_name}-#{client.archived_slug.split('-').last}"
        end
        client.update(archived_slug: new_archived_slug)
        
        Organization.switch_to 'shared'
        shared_client = SharedClient.find_by(archived_slug: old_archived_slug)
        shared_client.update(archived_slug: new_archived_slug) if shared_client.present?
      end
    end
  end
end
