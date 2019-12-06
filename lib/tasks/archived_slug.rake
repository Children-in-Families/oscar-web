namespace 'archived_slug' do
  desc 'update archived slug'
  task :update, [:short_name]  => :environment do |task, args|
    short_name = args.short_name
    Organization.switch_to short_name
    Client.skip_callback(:save, :after, :mark_referral_as_saved)
    Client.find_each do |client|
      old_archived_slug = client.archived_slug
      new_archived_slug = ''
      next if old_archived_slug.present? && old_archived_slug[/\w+\-\d+/]
      if client.referrals.present?
        short_name = client.referrals.first.try(:referred_from)
        new_archived_slug = "#{short_name}-#{client.id}"
      else
        new_archived_slug = "#{short_name}-#{client.id}"
      end
      client.archived_slug = new_archived_slug

      client.save(validate: false)
      puts "save client #{short_name} - #{client.archived_slug}"
    end
  end
end
