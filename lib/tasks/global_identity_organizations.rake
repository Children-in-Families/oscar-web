namespace :global_identity_organizations do
  desc "create missing GlobalIdentityOrganization"
  task :create, [:short_name]  => :environment do |task, args|
    short_name = args.short_name
    if args.short_name
      Apartment::Tenant.switch! short_name
      org_id = Organization.find_by(short_name: short_name).try(:id)
      return unless org_id

      clients = Client.where.not(global_id: nil).where.not(global_id: '').pluck(:id, :global_id)
      clients.each do |id, global_id|
        GlobalIdentityOrganization.find_or_create_by(global_id: global_id, organization_id: org_id, client_id: id)
      end
      puts "=============#{short_name}================="
    else
      Organization.where.not(short_name: 'shared').pluck(:id, :short_name).each do |org_id, short_name|
        Apartment::Tenant.switch! short_name
        clients = Client.where.not(global_id: nil).where.not(global_id: '').pluck(:id, :global_id)
        clients.each do |id, global_id|
          GlobalIdentityOrganization.find_or_create_by(global_id: global_id, organization_id: org_id, client_id: id)
        end
        puts "=============#{short_name}================="
      end
    end
  end

end
