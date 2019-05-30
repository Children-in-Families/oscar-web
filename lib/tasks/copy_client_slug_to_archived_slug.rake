namespace :client_archived_slug do
  desc 'copy client slug to archived_slug'
  task copy: :environment do |task, args|
    Organization.all.each do |org|
      Organization.switch_to org.short_name

      if short_name == 'shared'
        SharedClient.all.each do |client|
          next if client.archived_slug.present?
          client.archived_slug = client.slug
          client.save(validate: false)
        end
      else
        Client.all.each do |client|
          next if client.archived_slug.present?
          client.archived_slug = client.slug
          client.slug = client.id
          client.save(validate: false)
        end
      end
    end
  end
end
