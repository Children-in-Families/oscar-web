namespace :global_identity_organizations do
  desc "create missing GlobalIdentityOrganization"
  task create: :environment do
    Organization.where.not(short_name: 'shared').pluck(:id, :short_name).each do |org_id, short_name|
      Apartment::Tenant.switch! short_name
      clients = Client.pluck(:id, :global_id)
      clients.each do |id, global_id|
        GlobalIdentityOrganization.find_or_create_by(global_id: global_id, organization_id: org_id, client_id: id)
      end
      puts "=============#{short_name}================="
    end
  end

end
