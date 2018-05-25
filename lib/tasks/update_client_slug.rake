namespace 'client_slug' do
  desc 'update client slug'
  task update: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name

      Client.find_each do |client|
        unless client.slug.start_with?(org.short_name)
          slug = "#{org.short_name}-#{client.slug.split('-')[1]}"
          client.update_columns(slug: slug)
        end
      end
    end
  end
end

# the follwing code is for getting client's slug that does not start with the org's short_name
# delete this code when you're done with testing
# clients = []
# Organization.all.each do |org|
#   Organization.switch_to org.short_name
#   records = {org: org.short_name, slugs: []}
#   Client.find_each do |client|
#     records[:slugs] << client.slug unless client.slug.start_with?(org.short_name)
#   end
#   clients << records
# end
